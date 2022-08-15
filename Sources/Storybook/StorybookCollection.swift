#if DEBUG || ALLOW_STORYBOOK_RELEASE

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct StorybookCollection: View {
    
    @State var selectedItem: StorybookPage?
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
            .sheet(item: $selectedItem, onDismiss: nil, content: { item in
                StorybookItemView(preview: item)
            })
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
    
    private func navLink(for item: StorybookPage) -> some View {
        #if os(macOS)
            return NavigationLink(
                destination: {
                    StorybookItemView(preview: item)
                }, label: {
                    rowContent(for: item)
                }
            )
        #else
            return NavigationLink(
                isActive: .constant(false),
                destination: {
                    EmptyView()
                }, label: {
                    rowContent(for: item)
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedItem = item
            }
        #endif
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
                        navLink(for: item)
                    }
                })
            }, header: {
                Text(chapter.title)
            })
        }
    }
}

//// For visually testing things out
//
//@available(iOS 13, *)
//struct ContentView: View {
//
//    let title: String
//    init(title: String = "Hello, world!") {
//        self.title = title
//    }
//
//    var body: some View {
//        Text(title)
//    }
//}
//
//@available(iOS 13, *)
//extension Storybook {
//    @objc static let view = StorybookPage(title: "Foo", chapter: "1", view: ContentView(title: "Foo"))
//    @objc static let otherView = StorybookPage(title: "Baz", chapter: "1", view: ContentView(title: "Baz!!!"))
//    @objc static let otherViews = StorybookPage(title: "Bar", chapter: "2", views: [
//        StoryBookView(title: "One", view: ContentView(title: "One!")),
//        StoryBookView(title: "Two", view: ContentView(title: "Two!!!"))
//    ])
//}
//
//@available(iOS 13, *)
//struct StorybookPreviews: PreviewProvider {
//    static var previews: some View {
//        StorybookCollection()
//    }
//}

#endif
