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
    
    public convenience init<T: View>(
        title: String,
        view: T,
        file: String = #file
    ) {
        self.init(
            title: title,
            views: [StoryBookView(title: title, view: view)],
            file: file
        )
    }
    
    public init(
        title: String,
        views: [StoryBookView],
        file: String = #file
    ) {
        self.title = title
        self.views = views
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "uknown"
    }
}
