import Foundation

let arguments = CommandLine.arguments.dropFirst().nonEmpty ?? ["."]
let urls = arguments.lazy.map(URL.init(fileURLWithPath:))

guard let watcher = Watcher(urls: urls) else {
  fputs("fatal: Unable to create FSEvents stream.\n", stderr)
  exit(1)
}

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
