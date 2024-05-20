//
//  Storybook.swift
//
//
//  Created by AJ Bartocci on 4/14/22.
//

import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11, *)
public class Storybook: NSObject {
    
    /// Renders the storybook, alternatively you can use StorybookCollection() direclty
    public static func render() -> some View {
        StorybookCollection()
    }
        
    static func build() -> StorybookCollectionData {
        var count: CUnsignedInt = 0
        let data = StorybookCollectionData()
        guard let methods = class_copyPropertyList(object_getClass(Storybook.self), &count) else {
            print("No previews were found as static members")
            return data
        }
        for i in 0 ..< count {
            let selector = property_getName(methods.advanced(by: Int(i)).pointee)
            if let key = String(cString: selector, encoding: .utf8) {
                guard let preview = Storybook.value(forKey: key) as? StorybookPage else {
                    print("Cannot load view: \(key)")
                    continue
                }
                if let directory = preview.directory {
                    data.addEntry(folder: directory, views: preview.views, file: preview.file)
                } else {
                    data.addEntry(folder: "\(preview.chapter)/\(preview.title)", views: preview.views, file: preview.file)
                }
            }
        }
        return data
    }
}
