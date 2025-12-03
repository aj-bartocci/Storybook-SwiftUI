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
    let tags: Set<String>
    var files = Set<String>()
    var isFolder = false
    
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
                return StorybookEntry(
                    id: view.id.uuidString,
                    title: view.title,
                    children: [:],
                    views: [view],
                    tags: tags.union(view.tags),
                    file: view.file
                )
            case .entry(let entry):
                return entry
            }
        }
    }()
    
    let id: String
    
    init(
        id: String,
        title: String,
        children: [String: StorybookEntry],
        views: [StoryBookView],
        tags: Set<String>,
        file: String? = nil
    ) {
        self.id = id
        self.title = title
        self.children = children
        self.views = views
        let _tags = tags.map({ $0.lowercased() })
        self.tags = Set(_tags)
        if let file = file {
            self.files.insert(file)
        }
    }
}

private extension DispatchQueue {
    static let storybookCollection = DispatchQueue(label: "com.ajbartocci.storybookCollection.queue")
}

@available(iOS 13.0, *)
@available(macOS 11, *)
class StorybookCollectionData {
    private var root = [String: StorybookEntry]()
    private var tags = Set<String>()
    
    lazy var sortedTags: [String] = {
        tags.sorted()
    }()
    
    // TODO: rename this to rootEntries
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
                        id: storyBookView.id.uuidString,
                        title: storyBookView.title,
                        children: [:],
                        views: [storyBookView],
                        tags: storyBookView.tags,
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
        return flattened.sorted(by: { $0.title < $1.title }) 
    }()
    
    func addEntry(
        folder directory: String,
        views: [StoryBookView],
        tags: Set<String>,
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
        // could combine tags here by recreating the views with the tags
        let views = views.map { view in
            return StorybookView(title: view.title, tags: view.tags.union(tags), view: view.view, file: view.file)
        }
        self.tags.formUnion(tags)
        addEntry(
            paths: paths,
            entryDirectory: &root,
            views: views,
            tags: tags,
            file: file
        )
    }
    
    private func addEntry(
        paths: [String],
        entryDirectory: inout [String: StorybookEntry],
        views: [StoryBookView],
        tags: Set<String>,
        file: String = #file
    ) {
        let entry: StorybookEntry
        let title = paths[0]
        if let existing = entryDirectory[title] {
            entry = existing
        } else {
            entry = StorybookEntry(
                id: UUID().uuidString,
                title: title,
                children: [:],
                views: [],
                tags: tags
            )
            entryDirectory[title] = entry
        }
        entry.files.insert(file)
        entry.isFolder = true
        if paths.count == 1 {
            // at the leaf node so append the views
            entry.views.append(contentsOf: views)
        } else {
            // continue building the path
            addEntry(
                paths: Array(paths.dropFirst()),
                entryDirectory: &entry.children,
                views: views,
                tags: tags,
                file: file
            )
        }
    }
    
    func search(_ keyword: String, completion: @escaping ([StorybookEntry]) -> Void) {
        let keyword = keyword.lowercased()
        if keyword.isEmpty {
            completion(sortedEntries)
        } else {
            DispatchQueue.storybookCollection.async { [weak self] in
                guard let self = self else {
                    return
                }
                let entries: [StorybookEntry]
                if keyword.first == "#" {
                    let tags = Set(keyword.split(separator: ",").compactMap({
                        let keyword: String
                        if $0.first == "#" {
                            keyword = $0.dropFirst().trimmingCharacters(in: .whitespaces)
                        } else {
                            keyword = $0.trimmingCharacters(in: .whitespaces)
                        }
                        if !keyword.isEmpty {
                            return keyword
                        } else {
                            return nil
                        }
                    }))
                    if tags.isEmpty {
                        // show all with tags
                        entries = flattenedEntries.filter { entry in
                            return !entry.isFolder && !entry.tags.isEmpty
                        }
                    } else if tags.count == 1, let tag = tags.first {
                        // single tag
                        // show only matching tags
                        entries = flattenedEntries.filter { entry in
                            return !entry.isFolder && entry.tags.contains(where: { $0.contains(tag) })
                        }
                    } else {
                        // multi tag
                        // nested for loops are not ideal but whatever for now
                        entries = flattenedEntries.filter { entry in
                            return !entry.isFolder && entry.tags.contains(where: { entryTag in
                                tags.contains { tag in
                                    entryTag.contains(tag)
                                }
                            })
                        }
                    }
                } else {
                    entries = flattenedEntries.filter { entry in
                        return entry.title.lowercased().contains(keyword.lowercased())
                    }
                }
                DispatchQueue.main.async {
                    completion(entries)
                }
            }
        }
    }
}
