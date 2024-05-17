#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 10.15, *)
struct StorybookItemView: View {
    
    @State private var selectedItem: StoryBookView?
    let preview: StorybookPage
    init(preview: StorybookPage) {
        self.preview = preview
    }
    
    var body: some View {
        if preview.views.count == 0 {
            Text("Error: No views provided")
        } else if preview.views.count == 1 {
            viewWithTitle(preview.title, view: preview.views[0].view())
        } else {
            nestedViewWithTitle(
                preview.title,
                view: List(preview.views) { item in
                    rowView(for: item)
                }
            )
            .sheet(item: $selectedItem, onDismiss: nil, content: { item in
                controlWrappedView(item.view())
            })
        }
    }
    
    private func rowView(for item: StoryBookView) -> some View {
        navLink(for: item)
    }
    
    @ViewBuilder
    private func controlWrappedView<T: View>(_ view: T) -> some View {
        view.storybookAddControls(.custom(control: .init(controlId: ControlConstant.rootId, view: { EmptyView() })))
    }
    
    #if os(macOS)
    private func nestedViewWithTitle<T: View>(_ title: String, view: T) -> some View {
        NavigationView {
            viewWithTitle(title, view: view)
        }
    }
    
    private func viewWithTitle<T: View>(_ title: String, view: T) -> some View {
        view
    }
    
    private func navLink(for item: StoryBookView) -> some View {
//        return NavigationLink(
//            destination: {
//                item.view
//            },
//            label: {
//                Text(item.title)
//            }
//        )
        EmptyView()
    }
    
    #else
    
    private func nestedViewWithTitle<T: View>(_ title: String, view: T) -> some View {
        viewWithTitle(title, view: view)
    }
    
    private func viewWithTitle<T: View>(_ title: String, view: T) -> some View {
        controlWrappedView(view)
        .navigationBarTitle(
            Text(title),
            displayMode: .inline
        )
    }
    
    private func navLink(for item: StoryBookView) -> some View {
        return NavigationLink(
            isActive: .constant(false),
            destination: {
                EmptyView()
            },
            label: {
                Text(item.title)
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedItem = item
        }
    }
    #endif
}

#endif
