#if canImport(SwiftUI)
#if os(macOS)
import SwiftUI

@available(macOS 11, *)
public struct StorybookCollection: View {
    
    @State var selectedItem: StorybookPage?
    @State var selectedView: StoryBookView?
    @State var collection: StorybookCollectionData = Storybook.build()
    @State var searchText = ""
    let embedInNav: Bool
    
    public init(embedInNav: Bool = true) {
        self.embedInNav = embedInNav
    }
    
    public var body: some View {
        if collection.sortedEntries.count == 0 {
            noPagesMessage()
        } else {
            if embedInNav {
                NavigationView {
                    pageContent()
                }
            } else {
                pageContent()
            }
        }
    }
    
    private func noPagesMessage() -> some View {
        Text("No pages were found :( check the docs to make sure you set things up properly.")
    }
    
    private func pageContent() -> some View {
        listContent()
    }
    
    private func navLink(for entry: StorybookEntry) -> some View {
        NavigationLink(destination: {
            StorybookDestinationView(destinations: entry.destinations)
        }, label: {
            rowLabel(title: entry.title, file: entry.file)
        })
    }
    
    private func rowLabel(title: String, file: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title)
            .font(.headline)
            if let file = file {
                Text(file)
                .font(.caption)
            }
        }
    }
    
    private func navLink(for view: StoryBookView) -> some View {
        NavigationLink(destination: {
            previewContent(for: view)
        }, label: {
            rowLabel(title: view.title, file: view.file)
        })
    }
    
    func previewContent(for view: StoryBookView) -> some View {
        view.view()
        .storybookAddControls(.custom(.init(id: ControlConstant.rootId, view: { EmptyView() })))
    }
    
    @ViewBuilder
    func destinationContent(for destination: StorybookEntry.Destination) -> some View {
        switch destination {
        case .entry(let nestedEntry):
            navContent(for: nestedEntry)
        case .view(let view):
            NavigationLink(destination: {
                previewContent(for: view)
            }, label: {
                rowLabel(title: view.title, file: view.file)
            })
        }
    }
    
    @ViewBuilder
    func navContent(for entry: StorybookEntry) -> some View {
        DisclosureGroup(content: {
            ForEach(entry.destinations) { destination in
                destinationContent(for: destination)
            }
        }, label: {
            rowLabel(title: entry.title, file: entry.file)
        })
    }
        
    private func listContent() -> some View {
        VStack {
            SearchBar(searchText: $searchText)
            List {
                ForEach(collection.entriesMatchingSearch(searchText)) { entry in
                    navContent(for: entry)
                }
            }
        }
        .sheet(item: $selectedView, onDismiss: nil, content: { view in
            previewContent(for: view)
        })
    }
}
#endif
#endif
