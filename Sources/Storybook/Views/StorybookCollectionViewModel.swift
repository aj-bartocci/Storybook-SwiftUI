//
//  StorybookCollectionViewModel.swift
//  Storybook
//
//  Created by AJ Bartocci on 12/2/25.
//

import Combine
import Foundation

@available(iOS 13.0, *)
@available(macOS 11, *)
class StorybookCollectionViewModel: ObservableObject {
    @Published var selectedView: StoryBookView?
    @Published var searchText = ""
    @Published var selectedTags = Set<String>()
    @Published var showTagsSelector = false
    @Published private(set) var entries = [StorybookEntry]()
    private var isUpdatingFromSearch = false
    private var collection: StorybookCollectionData = Storybook.build()
    private var cancellables = Set<AnyCancellable>()
    
    var allTags: [String] {
        collection.sortedTags
    }
    
    var showNoPagesError: Bool {
        entries.isEmpty && searchText.isEmpty
    }
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    init() {
        $selectedTags.sink { [weak self] selectedTags in
            self?.updateSearchFromTags(selectedTags)
        }
        .store(in: &cancellables)
        
        $searchText
        .debounce(for: 0.2, scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { [weak self] searchText in
            self?.updateFromTextInput(searchText)
        }
        .store(in: &cancellables)
        
        // When text clears, immediately update UI rather than debouncing
        $searchText.sink { [weak self] searchText in
            if searchText.isEmpty {
                self?.updateFromTextInput(searchText)
            }
        }
        .store(in: &cancellables)
        
        self.entries = collection.sortedEntries
    }
    
    private func updateFromTextInput(_ searchText: String) {
        isUpdatingFromSearch = true
        updateTagsFromSearch(searchText)
        let isTagSearch = searchText.trimmingCharacters(in: .whitespaces).first == "#"
        collection.search(searchText, completion: { [weak self] entries in
            self?.entries = entries

            // Auto-navigate to single result when searching by tag
            if isTagSearch && entries.count == 1 {
                let entry = entries[0]
                // Check if this single entry has only one view
                if entry.views.count == 1, let view = entry.views.first {
                    self?.selectedView = view
                }
            }
        })
        isUpdatingFromSearch = false
    }
    
    private func updateSearchFromTags(_ tags: Set<String>) {
        // Ugly logic here but can clean it up later
        guard !isUpdatingFromSearch else {
            return
        }
        let searchTags = parseTags(from: searchText)
        // For adding new tag selections to search text
        for tag in tags {
            // if the tag is not in the search text already then append it
            if !searchTags.contains(tag) {
                let prefix: String = {
                    if searchText.isEmpty {
                        return "#"
                    } else {
                        return ",#"
                    }
                }()
                searchText.append(prefix + tag)
            }
        }
        // For removing tags from search text
        var newSearch = searchText
        for tag in searchTags {
            if !tags.contains(tag) {
                newSearch = newSearch.replacingOccurrences(of: ", #"+tag, with: "")
                newSearch = newSearch.replacingOccurrences(of: ",#"+tag, with: "")
                newSearch = newSearch.replacingOccurrences(of: "#"+tag, with: "")
            }
        }
        searchText = newSearch
    }
    
    private func parseTags(from search: String) -> Set<String> {
        let potentialTags = search.split(separator: ",")
        var tags = Set<String>()
        potentialTags.forEach { value in
            let value = value.trimmingCharacters(in: .whitespaces)
            if value.first == "#" {
                let trimmed = value.dropFirst()
                if !trimmed.isEmpty {
                    tags.insert(String(trimmed))
                }
            }
        }
        return tags
    }
    
    private func updateTagsFromSearch(_ search: String) {
        let newTags = parseTags(from: search)
        guard selectedTags != newTags else {
            return
        }
        selectedTags = newTags
    }
}
