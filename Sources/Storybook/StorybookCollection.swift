#if DEBUG

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 10.15, *)
struct StorybookItemView: View {
    
    @State private var showIsolatedView = false
    let preview: StorybookPage
    init(preview: StorybookPage) {
        self.preview = preview
    }
    
    var body: some View {
        if preview.views.count == 0 {
            Text("Error: No views provided")
        } else if preview.views.count == 1 {
            viewWithTitle(preview.title, view: preview.views[0].view)
        } else {
            viewWithTitle(
                preview.title,
                view: List(preview.views) { item in
                    rowView(for: item)
                }
            )
        }
    }
    
    private func viewWithTitle<T: View>(_ title: String, view: T) -> some View {
        #if os(macOS)
        view
        #else
        view
        .navigationBarTitle(
            Text(title),
            displayMode: .inline
        )
        #endif
    }
    
    private func rowView(for item: StoryBookView) -> some View {
        NavigationLink(isActive: .constant(false), destination: { EmptyView() }, label: { Text(item.title) })
        .contentShape(Rectangle())
        .onTapGesture {
            showIsolatedView = true
        }
        .sheet(isPresented: $showIsolatedView, onDismiss: nil, content: {
            item.view
        })
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct StorybookCollection: View {
    
    @State var showIsolatedView = false
    let embedInNav: Bool
    let chapters: [StorybookChapter]
    public init(embedInNav: Bool = true) {
        self.embedInNav = embedInNav
        self.chapters = Storybook.build()
    }
    
    public var body: some View {
        if chapters.count == 0 {
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
        #if os(macOS)
            listContent()
        #else
            listContent()
            .navigationBarTitle("Storybook", displayMode: .inline)
        #endif
    }
    
    private func rowContent(for item: StorybookPage) -> some View {
        VStack(alignment: .leading) {
            Text(item.title)
            .font(.headline)
            Text("(\(item.file))")
            .font(.caption)
        }
    }
        
    private func listContent() -> some View {
        List(chapters) { chapter in
            Section(content: {
                ForEach(chapter.pages, content: { item in
                    if item.views.count > 1 {
                        NavigationLink(destination: {
                            StorybookItemView(preview: item)
                        }, label: {
                            rowContent(for: item)
                        })
                    } else {
                        NavigationLink(isActive: .constant(false), destination: { EmptyView() }, label: {
                            rowContent(for: item)
                        })
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showIsolatedView = true
                        }
                        .sheet(isPresented: $showIsolatedView, onDismiss: nil, content: {
                            StorybookItemView(preview: item)
                        })
                    }
                })
            }, header: {
                Text(chapter.title)
            })
        }
    }
}

#endif
