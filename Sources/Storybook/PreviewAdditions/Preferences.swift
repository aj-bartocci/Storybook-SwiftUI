#if DEBUG
import SwiftUI

struct DarkModePreferenceKey: PreferenceKey {
    static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

@available(iOS 13, *)
struct ContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: ContentSizeCategory = .large

    static func reduce(value: inout ContentSizeCategory, nextValue: () -> ContentSizeCategory) {
        value = nextValue()
    }
}

#endif
