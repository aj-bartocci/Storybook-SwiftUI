#if canImport(SwiftUI)
#if os(iOS)
import SwiftUI

@available(iOS 13.0, *)
public struct StorybookCollection: View {
    
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
        .navigationBarTitle("Storybook", displayMode: .inline)
    }
        
    private func navLink(for entry: StorybookEntry) -> some View {
        NavigationLink(destination: {
            StorybookDestinationView(destinations: entry.destinations)
                .navigationBarTitle(entry.title)
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
        NavigationLink(
            isActive: .constant(false),
            destination: {
                EmptyView()
            }, label: {
                rowLabel(title: view.title, file: view.file)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedView = view
        }
    }
    
    func previewContent(for view: StoryBookView) -> some View {
        view.view()
        .storybookAddControls(.custom(.init(id: ControlConstant.rootId, view: { EmptyView() })))
    }
        
    private func listContent() -> some View {
        VStack {
            SearchBar(searchText: $searchText)
            List {
                if searchText.isEmpty {
                    ForEach(collection.entriesMatchingSearch(searchText)) { entry in
                        navLink(for: entry)
                    }
                } else {
                    ForEach(collection.entriesMatchingSearch(searchText)) { entry in
                        if entry.destinations.count == 1 {
                            switch entry.destinations[0] {
                            case .entry(let entry):
                                navLink(for: entry)
                            case .view(let storybookView):
                                navLink(for: storybookView)
                            }
                        } else {
                            navLink(for: entry)
                        }
                    }
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
