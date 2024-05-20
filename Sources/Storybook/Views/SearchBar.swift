#if canImport(SwiftUI)
import SwiftUI

#if os(iOS)
@available(iOS 13.0, *)
struct SearchBar: UIViewRepresentable {
    
    @Binding var searchText: String
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        
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
        searchBar.delegate = context.coordinator
        context.coordinator.searchBar = searchBar
        return searchBar
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        
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
