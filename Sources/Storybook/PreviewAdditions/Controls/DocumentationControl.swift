//
//  DocumentationControl.swift
//  
//
//  Created by AJ Bartocci on 5/15/24.
//

import SwiftUI

@available(iOS 13, *)
@available(macOS 10.15, *)
extension StorybookControlType.IconType {
    var icon: Image {
        switch self {
        case .figma:
            return Image(packageResource: "figma_icon", ofType: "png")
        case .jira:
            return Image(packageResource: "jira_icon", ofType: "png")
        case .custom(let image):
            return image
        }
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
extension View {
    // since the environment value is 14+ just fall back to 13 functionality
    // can clean this up if problems come up
    func openURL(_ url: URL) {
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
public struct DocumentationControl: View {
    
    let icon: Image
    let title: String
    let url: URL?
    
    init(icon: Image?, title: String, url: String) {
        self.icon = icon ?? Image(systemName: "link")
        self.title = title
        self.url = URL(string: url)
    }
    
    private var urlString: String {
        if let url = url {
            return url.absoluteString
        } else {
            return "Invalid URL"
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                icon.resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20)
                Text(title).internalTitleFont()
                Spacer()
            }
            .padding(.vertical, ControlConstant.rowSpacing)
            systemDividerColor.frame(height: 1)
        }
        .onTapGesture {
            if let url = url {
                openURL(url)
            }
        }
    }
}
