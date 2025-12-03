#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11, *)
public struct StoryBookView: Identifiable {
    public let id = UUID()
    let title: String
    let file: String
    let tags: Set<String>
    let view: () -> AnyView
    
    public init<T: View>(
        title: String,
        tags: Set<String> = Set(),
        view: @autoclosure @escaping () -> T,
        file: String = #file
    ) {
        self.init(
            title: title,
            tags: tags,
            view: {
                return AnyView(view())
            }, 
            file: file
        )
    }
    
    init(
        title: String,
        tags: Set<String> = Set(),
        view: @escaping () -> AnyView,
        file: String = #file
    ) {
        self.title = title
        self.view = view
        self.tags = tags
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "unknown"
    }
    
    public func storybookTags(_ tags: String...) -> StorybookView {
        let tags = Set(tags).union(self.tags)
        return StorybookView(title: self.title, tags: tags, view: self.view, file: self.file)
    }
    
    func _storybookTags(tags: [String]) -> StorybookView {
        let tags = Set(tags).union(self.tags)
        return StorybookView(title: self.title, tags: tags, view: self.view, file: self.file)
    }
}

@available(iOS 13.0, *)
@available(macOS 11, *)
extension Array where Element == StoryBookView {
    public func storybookTags(_ tags: String...) -> [StorybookView] {
        return self.map({ $0._storybookTags(tags: tags) })
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
    let tags: Set<String>
    
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
        self.tags = Set()
    }
    
    private init(
        folder directory: String,
        views: [StoryBookView],
        tags: Set<String>,
        file: String
    ) {
        self.chapter = ""
        self.title = ""
        self.views = views
        let fileComponents = file.components(separatedBy: "/")
        self.file = fileComponents.last ?? "unknown"
        self.directory = directory
        self.tags = tags
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The path to the folder that should contain the views. ex: path/to/folder/
       - views: The views to host inside the specified folder
       - tags: The tags to match against when searching
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    convenience
    public init(
        folder directory: String,
        views: [StoryBookView],
        tags: String...,
        file: String = #file
    ) {
        // for some reason doing Set(tags) does not work
        // it compiles fine but does not function, as if
        // the tags are empty
        var tagSet = Set<String>()
        tags.forEach { tag in
            tagSet.insert(tag)
        }
        self.init(folder: directory, views: views, tags: tagSet, file: file)
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The path to the folder that should contain the view. ex: path/to/folder/
       - view: The view to host inside the specified folder
       - tags: The tags to match against when searching
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    convenience
    public init(
        folder directory: String,
        view: StoryBookView,
        tags: String...,
        file: String = #file
    ) {
        // for some reason doing Set(tags) does not work
        // it compiles fine but does not function, as if
        // the tags are empty
        var tagSet = Set<String>()
        tags.forEach { tag in
            tagSet.insert(tag)
        }
        self.init(folder: directory, views: [view], tags: tagSet, file: file)
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The folder object that should contain the views
       - views: The views to host inside the specified folder
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    convenience
    public init(
        folder: Storybook.Folder,
        views: [StoryBookView],
        file: String = #file
    ) {
        self.init(folder: folder.path, views: views, tags: folder.tags, file: file)
    }
    
    /**
     Creates a path to the specified views via the folder string. The fodler path with merge with other views using the same folder.
     - Parameters:
       - folder: The folder object that should contain the view
       - view: The view to host inside the specified folder
       - file: The file that contains the views. Normally you do not need to specify the file unless it is different than the one that holds the views.
     */
    convenience
    public init(
        folder: Storybook.Folder,
        view: StoryBookView,
        file: String = #file
    ) {
        self.init(folder: folder, views: [view], file: file)
    }
}
#endif
