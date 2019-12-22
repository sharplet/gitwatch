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

signal(SIGINT, SIG_IGN)

let interruptHandler = DispatchSource.makeSignalSource(
  signal: SIGINT,
  queue: .main
)

interruptHandler.setEventHandler { [unowned interruptHandler] in
  watcher.cancel()
  interruptHandler.cancel()

  fputs("Stopping...\n", stderr)

  let deadline = Date() + 0.1

  Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
    if watcher.isFinished {
      timer.invalidate()
      CFRunLoopStop(CFRunLoopGetCurrent())
    } else if Date() >= deadline {
      fputs("warning: File System Events stream did not stop cleanly; exiting.\n", stderr)
      exit(1)
    }
  }
}

interruptHandler.resume()

CFRunLoopRun()

do {
  try FileManager.default.removeItem(at: dir)
} catch {
  fputs("fatal: Unable to remove temporary directory at path: \(dir.path)\n", stderr)
  exit(1)
}
