#if canImport(SwiftUI)

import Foundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
struct StorybookChapter: Identifiable {
    let title: String
    let pages: [StorybookPage]
    var id: String {
        return title
    }
}

#endif
