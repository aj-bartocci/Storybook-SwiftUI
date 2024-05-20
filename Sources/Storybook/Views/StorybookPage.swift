import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11, *)
public struct StoryBookView: Identifiable {
    public let id = UUID()
    let title: String
    let file: String
    let view: () -> AnyView
    
    public init<T: View>(
        title: String,
        view: @autoclosure @escaping () -> T,
        file: String = #file
    ) {
        self.init(
            title: title, 
            view: {
                return AnyView(view())
            }, 
            file: file
        )
    }
    
    init(
        title: String,
        view: @escaping () -> AnyView,
        file: String = #file
    ) {
        self.title = title
        self.view = view
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "unknown"
    }
}

@available(iOS 13.0, *)
@available(macOS 11, *)
public typealias StorybookView = StoryBookView // made a dumb typo in v1

@available(iOS 13.0, *)
@available(macOS 11, *)
public extension View {
    /// Wraps the view for use with Storybook.
    func storybookTitle(_ title: String, file: String = #file) -> StoryBookView {
        StoryBookView(title: title, view: self, file: file)
    }
}

@available(iOS 13.0, *)
@available(macOS 11, *)
@objc
public class StorybookPage: NSObject, Identifiable {
    public let id = UUID()
    let title: String
    let views: [StoryBookView]
    let file: String
    let chapter: String
    /// If directory exists then ignore title and chapter
    let directory: String?
    
    @available(*, deprecated, message: "Use init(folder: ...) for better experience")
    public convenience init<T: View>(
        title: String,
        chapter: String? = nil,
        view: @autoclosure @escaping () -> T,
        file: String = #file
    ) {
        self.init(
            title: title,
            chapter: chapter,
            views: [
                StoryBookView(
                    title: title,
                    view: {
                        return AnyView(view())
                    },
                    file: file
                )
            ],
            file: file
        )
    }
    
    @available(*, deprecated, message: "Use init(folder: ...) for better experience")
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
        self.file = fileComponents.last ?? "unknown"
        self.directory = nil
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The path to the folder that should contain the views. ex: path/to/folder/
       - views: The views to host inside the specified folder
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    public init(
        folder directory: String,
        views: [StoryBookView],
        file: String = #file
    ) {
        self.chapter = ""
        self.title = ""
        self.views = views
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "unknown"
        self.directory = directory
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The path to the folder that should contain the view. ex: path/to/folder/
       - view: The view to host inside the specified folder
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    convenience
    public init(
        folder directory: String,
        view: StoryBookView,
        file: String = #file
    ) {
        self.init(folder: directory, views: [view], file: file)
    }
}
