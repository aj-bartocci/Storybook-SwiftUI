#if canImport(SwiftUI)
#if os(iOS)
import SwiftUI

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func navbarItem<T: View>(@ViewBuilder _ item: () -> T) -> some View {
        if #available(iOS 14, *) {
            self.toolbar {
                item()
            }
        } else {
            self.navigationBarItems(trailing: item())
        }
    }
}

@available(iOS 13.0, *)
private struct _StorybookCollection: View {
    @EnvironmentObject private var viewModel: StorybookCollectionViewModel
    @Environment(\.storybookControls) private var envControls
    let embedInNav: Bool
        
    public init(embedInNav: Bool = true) {
        self.embedInNav = embedInNav
    }
    
    public var body: some View {
        if viewModel.showNoPagesError {
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
        .navbarItem {
            Button(action: {
                viewModel.showTagsSelector = true
            }, label: {
                Image(systemName: "tag")
            })
        }
    }
        
    private func navLink(for entry: StorybookEntry) -> some View {
        NavigationLink(destination: {
            StorybookDestinationView(destinations: entry.destinations)
                .environment(\.storybookControls, envControls)
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
            viewModel.selectedView = view
        }
    }
    
    func previewContent(for view: StoryBookView) -> some View {
        view.view()
        .storybookAddControls(.custom(.init(id: ControlConstant.rootId, view: { EmptyView() })))
    }
        
    private func listContent() -> some View {
        VStack {
            SearchBar(searchText: $viewModel.searchText)
            List {
                if !viewModel.isSearching {
                    ForEach(viewModel.entries) { entry in
                        navLink(for: entry)
                    }
                } else {
                    ForEach(viewModel.entries) { entry in
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
        .sheet(item: $viewModel.selectedView, onDismiss: nil, content: { view in
            previewContent(for: view)
                .environment(\.storybookControls, envControls)
        })
        .sheet(isPresented: $viewModel.showTagsSelector) {
            TagsView(selectedTags: $viewModel.selectedTags, tags: viewModel.allTags)
        }
    }
}

@available(iOS 13.0, *)
public struct StorybookCollection: View {
    @State private var viewModel = StorybookCollectionViewModel()
    let embedInNav: Bool
        
    public init(embedInNav: Bool = true) {
        self.embedInNav = embedInNav
    }
    
    public var body: some View {
        _StorybookCollection(embedInNav: embedInNav)
            .environmentObject(viewModel)
    }
}
#endif
#endif
