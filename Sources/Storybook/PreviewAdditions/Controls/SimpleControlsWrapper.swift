//
//  SimpleControlsWrapper.swift
//  
//
//  Created by AJ Bartocci on 5/15/24.
//

import SwiftUI

@available(iOS 14, *)
@available(macOS 11, *)
struct TestWrapper<Content: View, Controls: View>: View {
    
    let content: () -> Content
    let controls: () -> Controls
    
    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder controls: @escaping () -> Controls) {
        self.content = content
        self.controls = controls
    }
    
    var body: some View {
        content()
    }
}

@available(iOS 14, *)
@available(macOS 11, *)
struct SimpleControlsWrapper<Content: View>: View {
    
    @Environment(\.storybookControls) private var envControls
//    private let controls: [StorybookControlType]
    @State var prefControls = [StorybookControlType]()
    
    let content: Content
    init(controls: [StorybookControlType] = [], @ViewBuilder content: () -> Content) {
//        self.controls = controls
        self.content = content()
    }
    
    var body: some View {
//        TestWrapper(content: { content }, controls: {
//            VStack(spacing: 0) {
//                Text("control count at root: \(envControls.count + controls.count)")
//                ForEach(envControls + controls, id: \.id, content: { control in
//                    switch control {
//                    case .colorScheme:
//                        ColorSchemeControl()
//                    case .dynamicType:
//                        DynamicTypeControl()
//                    case .screenSize:
//                        ScreenSizeControl()
//                    case let .documentationLink(title, url, icon):
//                        DocumentationControl(icon: icon?.icon, title: title, url: url)
//                    case .custom(control: let control):
//                        control.view
//                    case .test:
//                        Text("Test")
//                    }
//                })
//            }
//        })
        VStack {
            Text("pref count: \(prefControls.count)").background(Color.red)
            ControlledPreview(
                configuration: .overlay,
                initialState: Void(),
                component: { _, _ in
                    content
                },
                controls: { _ in
                    VStack(spacing: 0) {
    //                    Text("control count at root: \(envControls.count + controls.count)")
                        ForEach(envControls + prefControls, id: \.id, content: { control in
                            switch control {
                            case .colorScheme:
                                ColorSchemeControl()
                            case .dynamicType:
                                DynamicTypeControl()
                            case .screenSize:
                                ScreenSizeControl()
                            case let .documentationLink(title, url, icon):
                                DocumentationControl(icon: icon?.icon, title: title, url: url)
                            case .custom(control: let control):
                                control.view
                            case .test:
                                Text("Test")
                            }
                        })
                    }
                }
            )
            .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
                prefControls = value
            })
        }
    }
}
