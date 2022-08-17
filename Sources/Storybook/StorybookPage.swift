#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct StoryBookView: Identifiable {
    public let id = UUID()
    let title: String
    let view: AnyView
    
    public init<T: View>(title: String, view: T) {
        self.title = title
        self.view = AnyView(view)
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
@objc
public class StorybookPage: NSObject, Identifiable {
    public let id = UUID()
    let title: String
    let views: [StoryBookView]
    let file: String
    let chapter: String
    
    public convenience init<T: View>(
        title: String,
        chapter: String? = nil,
        view: T,
        file: String = #file
    ) {
        self.init(
            title: title,
            chapter: chapter,
            views: [StoryBookView(title: title, view: view)],
            file: file
        )
    }
    
    public init(
        title: String,
        chapter: String? = nil,
        views: [StoryBookView],
        file: String = #file
    ) {
        self.title = title
        self.chapter = chapter ?? "Uncategorized"
        self.views = views
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "uknown"
    }
}

#endif
