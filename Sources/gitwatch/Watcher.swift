import CoreServices
import Foundation

final class Watcher: Thread {
  private var stream: FSEventStreamRef!
  private var runLoop: CFRunLoop!

  init?<URLs: Sequence>(urls: URLs, latency: TimeInterval = 0.01) where URLs.Element == URL {
    guard let stream = FSEventStreamCreate(
      nil,
      Watcher.callback,
      nil,
      urls.map { $0.path } as CFArray,
      FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
      latency,
      FSEventStreamCreateFlags(
        kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes
      )
    ) else { return nil }

    self.stream = stream
    super.init()
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
  static let callback: FSEventStreamCallback = { stream, info, count, paths, flags, ids in
    let flags = UnsafeBufferPointer(start: flags, count: count)
    // swiftlint:disable:next force_cast
    let paths = Unmanaged<CFArray>.fromOpaque(paths).takeUnretainedValue() as! [String]

    for (path, flags) in zip(paths, flags) {
      let flags = EventFlags(rawValue: flags)
      print(path, terminator: "")

      for flag in EventFlags.allCases where flags.contains(flag) {
        switch flags {
        case Contains(.itemCreated):
          print(" itemCreated", terminator: "")
        case Contains(.itemRemoved):
          print(" itemRemoved", terminator: "")
        case Contains(.itemInodeMetadataModified):
          print(" itemInodeMetadataModified", terminator: "")
        case Contains(.itemRenamed):
          print(" itemRenamed", terminator: "")
        case Contains(.itemModified):
          print(" itemModified", terminator: "")
        default:
          print(" \(flags)", terminator: "")
        }
      }

      print()
    }
  }
}
