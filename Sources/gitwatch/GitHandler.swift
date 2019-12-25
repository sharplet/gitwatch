import Foundation
import Regex

final class GitHandler: WatcherDelegate {
  let branch = Regex(#".git/refs/heads/[^/]+$"#)
  let head = Regex(#".git/HEAD$"#)
  let lockFile = Regex(#"\.lock$"#)

  private var observation: Any!

  init(watcher: Watcher) {
    var observation: Any?

    observation = NotificationCenter.default.addObserver(
      forName: Watcher.fileSystemEventNotification,
      object: watcher,
      queue: nil,
      using: { [weak self] notification in
        guard let self = self else {
          if let observation = observation {
            NotificationCenter.default.removeObserver(observation)
          }
          return
        }

        guard let events = notification.userInfo?[Watcher.fileSystemEventsKey] as? [Event] else {
          return
        }

        DispatchQueue.main.async {
          self.handleEvents(events)
        }
      }
    )

    self.observation = observation
    watcher.delegate = self
  }

  deinit {
    NotificationCenter.default.removeObserver(observation!)
  }

  func handleEvents(_ events: [Event]) {
    for event in events {
      print(event)
    }
  }

  func watcher(_ watcher: Watcher, willHandle event: Event) -> EventAction? {
    switch event.path {
    case lockFile:
      return nil
    case branch, head:
      return .notify
    default:
      return nil
    }
  }
}
