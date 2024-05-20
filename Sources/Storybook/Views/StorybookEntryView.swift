import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11, *)
struct StorybookDestinationView: View {
    
    let destinations: [StorybookEntry.Destination]
    @State private var selectedView: StoryBookView?
    
    func rowLabel(title: String, file: String?) -> some View {
        VStack(alignment: .leading) {
            Text(title)
            .font(.headline)
            if let file = file {
                Text(file)
                .font(.caption)
            }
        }
    }
    
    func leafView(for view: StoryBookView) -> some View {
        #if os(macOS)
            NavigationLink(destination: {
                previewContent(for: view)
            }, label: {
                rowLabel(title: view.title, file: view.file)
            })
        #else
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
        #endif
    }
    
    func previewContent(for view: StoryBookView) -> some View {
        view.view()
        .storybookAddControls(.custom(.init(id: ControlConstant.rootId, view: { EmptyView() })))
    }
    
    func entryDestination(for entry: StorybookEntry) -> some View {
        NavigationLink(destination: {
            #if os(iOS)
                StorybookDestinationView(destinations: entry.destinations)
                    .navigationBarTitle(entry.title)
            #else
                StorybookDestinationView(destinations: entry.destinations)
            #endif
        }, label: {
            rowLabel(title: entry.title, file: entry.file)
        })
    }
    
    var body: some View {
        List {
            ForEach(destinations) { destination in
                switch destination {
                case .entry(let entry):
                    entryDestination(for: entry)
                case .view(let view):
                    leafView(for: view)
                }
            }
        }
        .sheet(item: $selectedView, onDismiss: nil, content: { view in
            previewContent(for: view)
        })
    }
}
