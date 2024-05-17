//
//  ControlConstants.swift
//  
//
//  Created by AJ Bartocci on 5/6/24.
//

import SwiftUI

struct ControlConstant {
    static let titleSize: CGFloat = 16
    static let subtitleSize: CGFloat = 12
    static let tinyText: CGFloat = 10
    static let rowSpacing: CGFloat = 8
    static let rootId = "com.ajbartocci.storybook.rootId"
}

@available(iOS 13, *)
@available(macOS 10.15, *)
extension View {
    func internalTitleFont() -> some View {
        self.font(.system(size: ControlConstant.titleSize))
    }
    
    func internalSubtitleFont() -> some View {
        self.font(.system(size: ControlConstant.subtitleSize))
    }
    
    func internalTinyFont() -> some View {
        self.font(.system(size: ControlConstant.tinyText))
    }
    
    var systemBackgroundColor: some View {
        #if os(macOS)
        Color(NSColor.textBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }
    
    var systemDividerColor: some View {
        #if os(macOS)
        Color(NSColor.textColor)
        #else
        Color(UIColor.label)
        #endif
    }
}
