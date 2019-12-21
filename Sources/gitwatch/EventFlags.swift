import CoreServices

struct EventFlags: OptionSet {
  var rawValue: FSEventStreamEventFlags

  static let none = EventFlags(rawValue: .init(kFSEventStreamEventFlagNone))

  static let mustScanSubdirectories = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagMustScanSubDirs))
  static let userDropped = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagUserDropped))
  static let kernelDropped = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagKernelDropped))
  static let eventIDsWrapped = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagEventIdsWrapped))
  static let historyDone = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagHistoryDone))
  static let rootChanged = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagRootChanged))
  static let mount = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagMount))
  static let unmount = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagUnmount))
  static let itemCreated = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemCreated))
  static let itemRemoved = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemRemoved))
  static let itemInodeMetadataModified = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemInodeMetaMod))
  static let itemRenamed = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemRenamed))
  static let itemModified = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemModified))
  static let itemFinderInfoModified = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemFinderInfoMod))
  static let itemChangedOwner = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemChangeOwner))
  static let itemXattrModified = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemXattrMod))
  static let itemIsFile = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemIsFile))
  static let itemIsDirectory = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemIsDir))
  static let itemIsSymlink = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemIsSymlink))
  static let ownEvent = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagOwnEvent))
  static let itemIsHardlink = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemIsHardlink))
  static let itemIsLastHardlink = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemIsLastHardlink))
  @available(macOS 10.13, *)
  static let itemCloned = EventFlags(rawValue: numericCast(kFSEventStreamEventFlagItemCloned))
}

extension EventFlags: CaseIterable {
  static var allCases: [EventFlags] {
    var allCases: [EventFlags] = [
      .mustScanSubdirectories,
      .userDropped,
      .kernelDropped,
      .eventIDsWrapped,
      .historyDone,
      .rootChanged,
      .mount,
      .unmount,
      .itemCreated,
      .itemRemoved,
      .itemInodeMetadataModified,
      .itemRenamed,
      .itemModified,
      .itemFinderInfoModified,
      .itemChangedOwner,
      .itemXattrModified,
      .itemIsFile,
      .itemIsDirectory,
      .itemIsSymlink,
      .ownEvent,
      .itemIsHardlink,
      .itemIsLastHardlink,
    ]
    if #available(macOS 10.13, *) {
      allCases.append(.itemCloned)
    }
    return allCases
  }
}
