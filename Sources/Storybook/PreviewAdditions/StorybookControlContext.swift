import SwiftUI

// Lazy copy paste for 13 vs 14 since @StateObject is only 14
// @ObservedObject should be fine since it is at the root but
// @StateObject is better in case Storybook is not at the root
// for some reason or another

@available(iOS 13, *)
@available(macOS 11, *)
private struct StorybookControlContext13<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var colorSchemeModel = ColorSchemeControlModel()
    @ObservedObject private var dynamicTypeControlModel = DynamicTypeControlModel()
    @ObservedObject private var screenSizeControlModel = ScreenSizeControlModel()
    
    var controlledColorScheme: SwiftUI.ColorScheme {
        if let isDarkMode = colorSchemeModel.isDarkMode {
            return isDarkMode ? .dark : .light
        } else {
            return colorScheme
        }
    }
    
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(colorSchemeModel)
            .environmentObject(dynamicTypeControlModel)
            .environmentObject(screenSizeControlModel)
            .environment(\.sizeCategory, dynamicTypeControlModel.fontSize.contentSize())
            .environment(\.colorScheme, controlledColorScheme)
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
private struct StorybookControlContext14<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var colorSchemeModel = ColorSchemeControlModel()
    @StateObject private var dynamicTypeControlModel = DynamicTypeControlModel()
    @StateObject private var screenSizeControlModel = ScreenSizeControlModel()
    
    var controlledColorScheme: SwiftUI.ColorScheme {
        if let isDarkMode = colorSchemeModel.isDarkMode {
            return isDarkMode ? .dark : .light
        } else {
            return colorScheme
        }
    }
    
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(colorSchemeModel)
            .environmentObject(dynamicTypeControlModel)
            .environmentObject(screenSizeControlModel)
            .environment(\.sizeCategory, dynamicTypeControlModel.fontSize.contentSize())
            .environment(\.colorScheme, controlledColorScheme)
    }
}

/**
 The context required for storybook controls. This must be the container of any views that use ColorSchemeControlModel,
 DynamicTypeControlModel, or ScreenSizeControlModel. 
 
 ControlledPreviews wrap themselves in the context so you don't need to.
 StorybookControlContext is only needed if you are doing something custom without ControlledPreview being the container.
 */
@available(iOS 13, *)
@available(macOS 11, *)
public struct StorybookControlContext<Content: View>: View {
    
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @ViewBuilder
    var contextualizedContent: some View {
        #if os(iOS)
        if #available(iOS 14, *) {
            StorybookControlContext14 {
                content
            }
        } else {
            StorybookControlContext13 {
                content
            }
        }
        #elseif os(macOS)
        if #available(macOS 11, *) {
            StorybookControlContext14 {
                content
            }
        } else {
            StorybookControlContext13 {
                content
            }
        }
        #else
        Text("Unsupported platform")
        #endif
    }
        
    public var body: some View {
        contextualizedContent
            .environment(\.isEmbeddedInStorybookContext, true)
            .environment(\.isEmbeddedInControls, true)
            .preference(key: StorybookControlsEmbedPrefKey.self, value: true)
    }
}
