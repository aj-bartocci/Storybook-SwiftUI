#if canImport(SwiftUI)
import SwiftUI

#if os(iOS)
@available(iOS 13.0, *)
struct SearchBar: UIViewRepresentable {
    
    @Binding var searchText: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search - use # for tags"
        searchBar.delegate = context.coordinator

        // Accessibility
        searchBar.isAccessibilityElement = true
        searchBar.accessibilityLabel = "Search components"
        searchBar.accessibilityIdentifier = "storybook.searchBar"
        searchBar.accessibilityTraits = .searchField

        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        if searchBar.text != searchText {
            searchBar.text = searchText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onTextChange: { text in
            searchText = text
        })
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        let onTextChange: (String) -> Void
        init(onTextChange: @escaping (String) -> Void) {
            self.onTextChange = onTextChange
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            onTextChange(searchText)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            
        }
    }
}
#endif

#if os(macOS)
@available(macOS 11, *)
struct SearchBar: NSViewRepresentable {
    
    @Binding var searchText: String
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchBar = NSSearchField()
        searchBar.placeholderString = "Search - use # for tags"
        searchBar.delegate = context.coordinator
        context.coordinator.searchBar = searchBar
        return searchBar
    }
    
    func updateNSView(_ searchBar: NSSearchField, context: Context) {
        if searchBar.stringValue != searchText {
            searchBar.stringValue = searchText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onTextChange: { text in
                searchText = text
            }
        )
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        
        var searchBar: NSSearchField?
        let onTextChange: (String) -> Void
        init(onTextChange: @escaping (String) -> Void) {
            self.onTextChange = onTextChange
        }
        
        func controlTextDidChange(_ obj: Notification) {
            onTextChange(searchBar?.stringValue ?? "")
        }
    }
}
#endif
#endif
