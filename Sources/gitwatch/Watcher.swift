import CoreServices
import Foundation

protocol WatcherDelegate: AnyObject {
  func watcher(_ watcher: Watcher, willHandle event: Event) -> EventAction?
}

final class Watcher: Thread {
  static let fileSystemEventNotification = Notification.Name("WatcherFileSystemEvent")
  static let fileSystemEventsKey = "WatcherFileSystemEvents"

  private var stream: FSEventStreamRef!
  private var runLoop: CFRunLoop!

  var coalesceEventPaths: Bool = true
  weak var delegate: WatcherDelegate?

  init?<URLs: Sequence>(urls: URLs, latency: TimeInterval = 0.01) where URLs.Element == URL {
    super.init()

    var context = FSEventStreamContext()
    context.info = Unmanaged.passUnretained(self).toOpaque()

    guard let stream = FSEventStreamCreate(
      nil,
      Watcher.callback,
      &context,
      urls.map { $0.path } as CFArray,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
      latency,
      FSEventStreamCreateFlags(
        kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes
      )
    ) else { return nil }

    self.stream = stream
    self.name = "me.sharplet.gitwatch.Watcher"
  }

  override func cancel() {
    super.cancel()

    CFRunLoopStop(runLoop)
  }

  override func main() {
    runLoop = CFRunLoopGetCurrent()

    FSEventStreamScheduleWithRunLoop(stream, runLoop, CFRunLoopMode.defaultMode.rawValue)
    FSEventStreamStart(stream)

    watch: do {
      let result = autoreleasepool {
        CFRunLoopRunInMode(.defaultMode, 10, true)
      }

      switch (isCancelled, result) {
      case (true, _), (_, .finished):
        break watch
      case (_, .handledSource), (_, .stopped), (_, .timedOut):
        continue watch
      @unknown default:
        continue watch
      }
    }

    FSEventStreamStop(stream)
    FSEventStreamInvalidate(stream)
    FSEventStreamRelease(stream)
    stream = nil
  }
}

private extension Watcher {
  static let callback: FSEventStreamCallback = { stream, info, count, paths, flags, ids in
    guard let info = info else { return }
    let flags = UnsafeBufferPointer(start: flags, count: count).lazy.map(EventFlags.init)
    // swiftlint:disable:next force_cast
    let paths = Unmanaged<CFArray>.fromOpaque(paths).takeUnretainedValue() as! [String]
    let events = zip(paths, flags).lazy.map(Event.init)
    let watcher = Unmanaged<Watcher>.fromOpaque(info).takeUnretainedValue()
    watcher.handleEvents(events)
  }

  private func handleEvents<Events: Sequence>(_ events: Events) where Events.Element == Event {
    var notificationEvents: [Event] = []

    for event in events {
      let action: EventAction

      if let delegate = delegate {
        guard let delegateAction = delegate.watcher(self, willHandle: event) else { continue }
        action = delegateAction
      } else {
        action = .notify
      }

      switch action {
      case .notify:
        if coalesceEventPaths, let index = notificationEvents.firstIndex(where: { $0.path == event.path }) {
          notificationEvents[index].flags.formUnion(event.flags)
        } else {
          notificationEvents.append(event)
        }
      }
    }

    if let events = notificationEvents.nonEmpty {
      NotificationCenter.default.post(
        name: Watcher.fileSystemEventNotification,
        object: self,
        userInfo: [
          Watcher.fileSystemEventsKey: events,
        ]
      )
    }
  }
}
