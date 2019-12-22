import CoreServices
import Foundation

final class Watcher: Thread {
  private var stream: FSEventStreamRef!
  private var runLoop: CFRunLoop!

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
      let result = CFRunLoopRunInMode(.defaultMode, 10, true)
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
  struct Event {
    var path: String
    var flags: EventFlags
  }

  func handleEvents<Events: Sequence>(_ events: Events) where Events.Element == Event {
    let events = Array(events)
    print(events)
  }

  static let callback: FSEventStreamCallback = { stream, info, count, paths, flags, ids in
    guard let info = info else { return }
    let flags = UnsafeBufferPointer(start: flags, count: count).lazy.map(EventFlags.init)
    // swiftlint:disable:next force_cast
    let paths = Unmanaged<CFArray>.fromOpaque(paths).takeUnretainedValue() as! [String]
    let events = zip(paths, flags).lazy.map(Event.init)
    let watcher = Unmanaged<Watcher>.fromOpaque(info).takeUnretainedValue()
    watcher.handleEvents(events)
  }
}
