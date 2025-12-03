//
//  StorybookFolder.swift
//  Storybook
//
//  Created by AJ Bartocci on 6/26/25.
//

#if canImport(SwiftUI)
import Foundation

@available(iOS 13.0, *)
@available(macOS 11, *)
public extension Storybook {
    struct Folder {
        let path: String
        let tags: Set<String>
        
        init(_ path: String, tags: Set<String>) {
            self.path = path
            self.tags = tags
        }
        
        public init(name path: String, tags: String...) {
            self.init(path, tags: Set(tags))
        }
        
        public func addingPath(_ path: String, tags: String...) -> Folder {
            Folder(self.path + path, tags: self.tags.union(Set(tags)))
        }
    }
}
#endif
