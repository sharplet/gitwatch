import Foundation

let dir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("gitwatch", isDirectory: true)

do {
  try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
} catch {
  fputs("fatal: Unable to create temporary directory at path: \(dir.path)\n", stderr)
  exit(1)
}

guard let watcher = Watcher(url: dir) else {
  fputs("fatal: Unable to create FSEvents stream at path: \(dir.path)\n", stderr)
  exit(1)
}

print("Watching for file system events in directory: \(dir.path)")

watcher.start()

InterruptHandler.register(withTimeout: 0.1, watcher: watcher) { isFinished in
  if isFinished {
    CFRunLoopStop(CFRunLoopGetCurrent())
  } else {
    fputs("warning: File System Events stream did not stop cleanly; exiting.\n", stderr)
    exit(1)
  }
}

CFRunLoopRun()

do {
  try FileManager.default.removeItem(at: dir)
} catch {
  fputs("fatal: Unable to remove temporary directory at path: \(dir.path)\n", stderr)
  exit(1)
}
