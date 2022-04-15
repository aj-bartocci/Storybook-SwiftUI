#if DEBUG

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 10.15, *)
struct StorybookItemView: View {
    
    let preview: StorybookPage
    init(preview: StorybookPage) {
        self.preview = preview
    }
    
    var body: some View {
        if preview.views.count == 0 {
            Text("Error: No views provided")
        } else if preview.views.count == 1 {
            viewWithTitle(for: preview.views[0])
        } else {
            List(preview.views) { item in
                rowView(for: item)
            }
        }
    }
    
    private func viewWithTitle(for item: StoryBookView) -> some View {
        #if os(macOS)
        item.view
        #else
        item.view
        .navigationBarTitle(
            Text(item.title),
            displayMode: .inline
        )
        #endif
    }
    
    private func rowView(for item: StoryBookView) -> some View {
        NavigationLink(destination: {
            viewWithTitle(for: item)
        }, label: {
            Text(item.title)
        })
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct StorybookCollection: View {
    
    let pages: [StorybookPage]
    public init() {
        self.pages = Storybook.build()
    }
    
    public var body: some View {
        if pages.count == 0 {
            noPagesMessage()
        } else {
            pageContent()
        }
    }
    
    private func noPagesMessage() -> some View {
        Text("No pages were found :( check the docs to make sure you set things up properly.")
    }
    
    private func pageContent() -> some View {
        #if os(macOS)
        NavigationView {
            List(Storybook.build()) { item in
                NavigationLink(destination: {
                    StorybookItemView(preview: item)
                }, label: {
                    VStack(alignment: .leading) {
                        Text(item.title)
                        .font(.headline)
                        Text("(\(item.file))")
                        .font(.caption)
                    }
                })
            }
        }
        #else
        NavigationView {
            List(Storybook.build()) { item in
                NavigationLink(destination: {
                    StorybookItemView(preview: item)
                }, label: {
                    VStack(alignment: .leading) {
                        Text(item.title)
                        .font(.headline)
                        Text("(\(item.file))")
                        .font(.caption)
                    }
                })
            }
            .navigationBarTitle("Storybook", displayMode: .inline)
        }
        #endif
    }
}

#endif
