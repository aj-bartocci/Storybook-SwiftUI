//
//  ControlHelpers.swift
//
//
//  Created by AJ Bartocci on 5/6/24.
//

import SwiftUI

@available(iOS 13, *)
@available(macOS 10.15, *)
public struct StorybookControlView {
    let controlId: String
    let view: AnyView
    
    public init<T: View>(controlId: String, @ViewBuilder view: () -> T) {
        self.controlId = controlId
        self.view = AnyView(view())
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsKey: EnvironmentKey {
    static var defaultValue: [StorybookControlType] = []
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsEmbedEnvKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookContextEmbedKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

@available(iOS 13, *)
@available(macOS 10.15, *)
struct StorybookControlsEmbedPrefKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
extension EnvironmentValues {
    var storybookControls: [StorybookControlType] {
        get { self[StorybookControlsKey.self] }
        set { self[StorybookControlsKey.self] = newValue }
    }
    
    var isEmbeddedInControls: Bool {
        get { self[StorybookControlsEmbedEnvKey.self] }
        set { self[StorybookControlsEmbedEnvKey.self] = newValue }
    }
    
    var isEmbeddedInStorybookContext: Bool {
        get { self[StorybookContextEmbedKey.self] }
        set { self[StorybookContextEmbedKey.self] = newValue }
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsEmbedCountPrefKey: PreferenceKey {
    static var defaultValue: Int = 0
    
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsPrefKey: PreferenceKey {
    static var defaultValue: [StorybookControlType] = []
    
    static func reduce(value: inout [StorybookControlType], nextValue: () -> [StorybookControlType]) {
        value += nextValue()
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
private struct AppendControlsModifier: ViewModifier {
    @Environment(\.storybookControls) var controls
    let appendedControls: [StorybookControlType]
    
    func body(content: Content) -> some View {
        content
            .environment(\.storybookControls, controls + appendedControls)
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
private struct AppendControlsModifier2: ViewModifier {
    @Environment(\.isEmbeddedInControls) var isEmbeddedInControls
    
    let appendedControls: [StorybookControlType]
    
    @State private var prefControls = [StorybookControlType]()
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if !isEmbeddedInControls {
                // root
//                SimpleControlsWrapper(controls: prefControls + appendedControls) {
                SimpleControlsWrapper(controls: []) {
                    content
                        .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
                            prefControls = value
                        })
                        .preference(key: StorybookControlsPrefKey.self, value: prefControls + appendedControls)
                }
//                .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
//                    prefControls = value
//                })
//                .preference(key: StorybookControlsPrefKey.self, value: prefControls + appendedControls)
//                Text("root pref: \(prefControls.count), appended: \(appendedControls.count), count: \(prefCount)")
//                    .background(Color.red)
            } else {
                content
                .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
                    prefControls = value
                })
                .preference(key: StorybookControlsPrefKey.self, value: prefControls + appendedControls)
            }
        }
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
private struct GlobalControlsModifier: ViewModifier {
    let controls: [StorybookControlType]
    @State private var prefControls = [StorybookControlType]()
    
    func body(content: Content) -> some View {
        content
        .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
            prefControls = value
        })
        .environment(\.storybookControls, controls + prefControls)
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
private struct AppendControlsWrapper<Content: View>: View {
    @Environment(\.storybookControls) var controls
    @Environment(\.isEmbeddedInControls) var isEmbeddedInControls
    
    let appendedControls: [StorybookControlType]
    let content: Content
    
    var body: some View {
        if isEmbeddedInControls {
            content
                .preference(key: StorybookControlsEmbedCountPrefKey.self, value: controls.count + appendedControls.count)
        } else {
            // this is what the root hits?
            SimpleControlsWrapper {
                content
                    .preference(key: StorybookControlsEmbedCountPrefKey.self, value: controls.count + appendedControls.count)
            }
            .environment(\.isEmbeddedInControls, true)
            .environment(\.storybookControls, controls + appendedControls)
        }
    }
}

//@available(iOS 13, *)
//struct EnvModifier: ViewModifier {
//    
//    @Environment(\.isEmbeddedInControlWrapper) var isEmbeddedInControlWrapper
//    @State private var prefCount: Int = 0
//    
//    let id: String
//    let count: Int
//    
//    func body(content: Content) -> some View {
//        VStack(spacing: 0) {
//            if !isEmbeddedInControlWrapper {
//                // root
//                content
//                    .onPreferenceChange(EnvCountPrefKey.self, perform: { value in
//                        prefCount = value
//                    })
//                    .environment(\.isEmbeddedInControlWrapper, true)
//                Text("root: \(id) count: \(prefCount + count)")
//            } else {
//                content
//                .onPreferenceChange(EnvCountPrefKey.self, perform: { value in
//                    prefCount = value
//                })
//                .preference(key: EnvCountPrefKey.self, value: count + prefCount)
//            }
//        }
//    }
//}

@available(iOS 14, *)
@available(macOS 11, *)
public extension View {
    
    /**
     Applies global controls that will be used in every preview generated by Storybook.
     */
    func applyGlobalControls(_ controls: StorybookControlType...) -> some View {
//        self.environment(\.storybookControls, controls)
        self.modifier(GlobalControlsModifier(controls: controls))
    }
    
    /**
     Embeds preview content in storybook overlay. Global controls will be pulled in automatically.
     */
    func storybookControlOverlay() -> some View {
        SimpleControlsWrapper {
            self
        }
    }
    
    /**
     Appends the specified controls to the global controls. This should be set on the preview content itself.
     */
    func storybookAppendControls(_ controls: StorybookControlType...) -> some View {
        SimpleControlsWrapper {
            self
        }
        .modifier(AppendControlsModifier(appendedControls: controls))
    }
    
    /**
     Sets the controls to exactly what is provided and ignores global controls. This should be set on the preview content itself.
     */
    func storybookSetControls(_ controls: StorybookControlType...) -> some View {
        SimpleControlsWrapper {
            self
        }
        .environment(\.storybookControls, controls)
    }
    
    func storybookAppendControlsEmbedIfNeeded(_ controls: StorybookControlType...) -> some View {
        self.modifier(AppendControlsModifier2(appendedControls: controls))
//        AppendControlsWrapper(appendedControls: controls, content: self)
    }
}
