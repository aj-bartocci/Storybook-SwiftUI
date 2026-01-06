//
//  TagsView.swift
//  Storybook
//
//  Created by AJ Bartocci on 7/3/25.
//

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13.0, *)
@available(macOS 11, *)
struct TagsView: View {
    @Binding var selectedTags: Set<String>
    let tags: [String]
    
    var body: some View {
        NavigationView {
            List(tags, id: \.self) { tag in
                HStack {
                    if selectedTags.contains(tag) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.blue)
                    }
                    Text(tag)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .internalSubtitleFont()
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitle("Tags")
            #endif
        }
    }
}
#endif
