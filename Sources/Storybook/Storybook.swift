#if canImport(SwiftUI)

import Foundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class Storybook: NSObject {
    static func build() -> [StorybookChapter] {
        var count: CUnsignedInt = 0
        guard let methods = class_copyPropertyList(object_getClass(Storybook.self), &count) else {
            print("No previews were found as static members")
            return []
        }
        var chapters = [String: [StorybookPage]]()
        for i in 0 ..< count {
            let selector = property_getName(methods.advanced(by: Int(i)).pointee)
            if let key = String(cString: selector, encoding: .utf8) {
                guard let preview = Storybook.value(forKey: key) as? StorybookPage else {
                    print("Cannot load view: \(key)")
                    continue
                }
                if var pages = chapters[preview.chapter] {
                    pages.append(preview)
                    chapters[preview.chapter] = pages
                } else {
                    chapters[preview.chapter] = [preview]
                }
            }
        }
        return chapters.map { (title, pages) in
            return StorybookChapter(title: title, pages: pages.sorted(by: { $0.title < $1.title }))
        }.sorted(by: { $0.title < $1.title })
    }
}

#endif
