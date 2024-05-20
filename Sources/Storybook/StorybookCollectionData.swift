import Foundation

@available(iOS 13.0, *)
@available(macOS 11, *)
class StorybookEntry: Identifiable {
    enum Destination: Identifiable {
        case view(StoryBookView)
        case entry(StorybookEntry)
        
        var id: String {
            switch self {
            case .view(let storyBookView):
                return storyBookView.id.uuidString
            case .entry(let storybookEntry):
                return storybookEntry.id
            }
        }
        
        var title: String {
            switch self {
            case .view(let storyBookView):
                return storyBookView.title
            case .entry(let storybookEntry):
                return storybookEntry.title
            }
        }
        
        var file: String? {
            switch self {
            case .view(let storyBookView):
                return storyBookView.file
            case .entry(let storybookEntry):
                return storybookEntry.file
            }
        }
    }
    let title: String
    var children: [String: StorybookEntry]
    var views: [StoryBookView]
    var file: String? {
//        return files.sorted().joined(separator: ",")
        return nil
    }
    var files = Set<String>()
    
    /// Used for rendering UI after the data has been built up
    lazy var destinations: [Destination] = {
        let dest: [Destination] = views.map({ .view($0) }) + children.values.map({ .entry($0) })
        return dest.sorted { lhs, rhs in
            return lhs.title < rhs.title
        }
    }()
    
    lazy var childDestinations: [StorybookEntry]? = {
        return destinations.map { destination in
            switch destination {
            case .view(let view):
                return StorybookEntry(title: view.title, children: [:], views: [view], file: view.file)
            case .entry(let entry):
                return entry
            }
        }
    }()
    
    let id = UUID().uuidString
    
    init(
        title: String,
        children: [String: StorybookEntry],
        views: [StoryBookView],
        file: String? = nil
    ) {
        self.title = title
        self.children = children
        self.views = views
        if let file = file {
            self.files.insert(file)
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 11, *)
class StorybookCollectionData {
    var root = [String: StorybookEntry]()
    
    /// Used for rendering UI after the data has been built up
    lazy var sortedEntries: [StorybookEntry] = {
        return root.values.sorted { lhs, rhs in
            if lhs.title == rhs.title {
                return lhs.id < rhs.id
            }
            return lhs.title < rhs.title
        }
    }()
    
    /// Used for searching a flattened list of entries, not the most efficient but a good starting point
    private lazy var flattenedEntries: [StorybookEntry] = {
        var flattened = [StorybookEntry]()
        var addedIds = Set<String>()
        func flattenEntry(_ entry: StorybookEntry, into arr: inout [StorybookEntry]) {
            arr.append(entry)
            for destination in entry.destinations {
                switch destination {
                case .view(let storyBookView):
                    arr.append(StorybookEntry(
                        title: storyBookView.title,
                        children: [:],
                        views: [storyBookView],
                        file: storyBookView.file
                    ))
                case .entry(let storybookEntry):
                    flattenEntry(storybookEntry, into: &arr)
                }
            }
        }
        for entry in sortedEntries {
            flattenEntry(entry, into: &flattened)
        }
        return flattened
    }()
    
    func addEntry(
        folder directory: String,
        views: [StoryBookView],
        file: String = #file
    ) {
        var directory = directory.trimmingCharacters(in: .whitespacesAndNewlines)
        if directory.hasPrefix("/") {
            directory = String(directory.dropFirst())
        }
        if directory.hasSuffix("/") {
            directory = String(directory.dropLast())
        }
        var paths = directory.split(separator: "/").map({ String($0) })
        if paths.count == 0 || paths.first?.isEmpty == true {
            // nothing provided, need to show error
            paths = ["* Uncategorized"]
        }
        addEntry(
            paths: paths,
            entryDirectory: &root,
            views: views,
            file: file
        )
    }
    
    private func addEntry(
        paths: [String],
        entryDirectory: inout [String: StorybookEntry],
        views: [StoryBookView],
        file: String = #file
    ) {
        let entry: StorybookEntry
        let title = paths[0]
        if let existing = entryDirectory[title] {
            entry = existing
        } else {
            entry = StorybookEntry(
                title: title,
                children: [:],
                views: []
            )
            entryDirectory[title] = entry
        }
        entry.files.insert(file)
        if paths.count == 1 {
            // at the leaf node so append the views
            entry.views.append(contentsOf: views)
        } else {
            // continue building the path
            addEntry(
                paths: Array(paths.dropFirst()),
                entryDirectory: &entry.children,
                views: views,
                file: file
            )
        }
    }
    
    func entriesMatchingSearch(_ keyword: String) -> [StorybookEntry] {
        if keyword.isEmpty {
            return sortedEntries
        } else {
            return flattenedEntries.filter { entry in
                return entry.title.lowercased().contains(keyword.lowercased())
            }
        }
    }
}
