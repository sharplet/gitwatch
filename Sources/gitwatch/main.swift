import CoreServices
import Foundation

let callback: FSEventStreamCallback = { stream, info, count, paths, flags, ids in
  let flags = UnsafeBufferPointer(start: flags, count: count)
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

let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("gitwatch", isDirectory: true)
try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
print("Watching for file system events in directory: \(dir.path)")

guard let stream = FSEventStreamCreate(
  nil,
  callback,
  nil,
  [dir.path] as CFArray,
  FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
  1,
  FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
) else {
  fputs("fatal: Unable to create FSEvents stream at path: \(dir.path)\n", stderr)
  exit(1)
}

FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
FSEventStreamStart(stream)

CFRunLoopRun()
