import Foundation

enum InterruptHandler {
  static func register(
    withTimeout timeout: TimeInterval,
    watcher: Watcher,
    completion: @escaping (Bool) -> Void
  ) {
    signal(SIGINT, SIG_IGN)

    let source = DispatchSource.makeSignalSource(
      signal: SIGINT,
      queue: .main
    )

    source.setEventHandler {
      let deadline = Date() + timeout
      watcher.cancel()
      source.cancel()

      fputs("Stopping...\n", stderr)

      Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
        func finish(_ isFinished: Bool) {
          timer.invalidate()
          completion(isFinished)
          signal(SIGINT, SIG_DFL)
        }

        if watcher.isFinished {
          finish(true)
        } else if Date() >= deadline {
          finish(false)
        }
      }
    }

    source.resume()
  }
}
