struct Contains<T> {
  var element: T

  init(_ element: T) {
    self.element = element
  }
}

extension Contains where T: OptionSet {
  static func ~= (pattern: Contains, value: T) -> Bool {
    value.isSuperset(of: pattern.element)
  }
}
