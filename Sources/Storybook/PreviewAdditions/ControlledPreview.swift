#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, *)
@available(macOS 11, *)
struct ControlledPreview<
    StateValue, Controls: View, Component: View, Context: ControlledPreviewContext
>: View {
    
    @Environment(\.isEmbeddedInStorybookContext) var isEmbeddedInStorybookContext
    private let preview: _ControlledPreview<StateValue, Controls, Component, Context>
    
    init(
        configuration: ControlledPreviewConfiguration = .overlay,
        initialState: StateValue,
        context: Context,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
    ) {
        self.preview = _ControlledPreview(
            configuration: configuration,
            initialState: initialState,
            context: context,
            component: component,
            controls: controls
        )
    }
    
    init(
        configuration: ControlledPreviewConfiguration = .overlay,
        initialState: StateValue,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
    ) where Context == NoContext {
        self.init(
            configuration: configuration,
            initialState: initialState,
            context: NoContext(),
            component: { state, actions, _ in
                component(state, actions)
            },
            controls: controls
        )
    }
    
    var body: some View {
        if isEmbeddedInStorybookContext {
            preview
                .preference(key: StorybookControlsEmbedPrefKey.self, value: true)
        } else {
            StorybookControlContext {
                preview
                    .preference(key: StorybookControlsEmbedPrefKey.self, value: true)
            }
        }
    }
}

@available(iOS 13, *)
@available(macOS 11, *)
struct _ControlledPreview<
    StateValue, Controls: View, Component: View, Context: ControlledPreviewContext
>: View {
    
    @Environment(\.storybookControls) var globalControls: [StorybookControlType]
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var screenSizeControlModel: ScreenSizeControlModel
    @ObservedObject var valueContainer: GenericObservableObject<StateValue>
    @ObservedObject private var actions = PreviewActions()
    @State private var context: Context
    @State private var showControlsOverlay = false
    @State private var buttonMessage: ButtonMessage?
    @State private var preferenceControls = [StorybookControlType]()
    
    private let configuration: ControlledPreviewConfiguration
    private let controls: (Binding<StateValue>) -> Controls
    private let component: (Binding<StateValue>, PreviewActions, Context) -> Component
    
    public init(
        configuration: ControlledPreviewConfiguration = .overlay,
        initialState: StateValue,
        context: Context,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
    ) {
        self.configuration = configuration
        self._context = State(initialValue: context)
        self.valueContainer = GenericObservableObject(initialState)
        self.controls = controls
        self.component = component
    }
    
    public init(
        configuration: ControlledPreviewConfiguration = .overlay,
        initialState: StateValue,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
    ) where Context == NoContext {
        self.init(
            configuration: configuration,
            initialState: initialState,
            context: NoContext(),
            component: { state, actions, _ in
                component(state, actions)
            },
            controls: controls
        )
    }
    
    var renderedControls: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: {
                        self.showControlsOverlay = false
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    })
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                    Spacer()
                }
                Text(verbatim: "Storybook iOS").internalTitleFont()
            }
            
            ScrollView {
                VStack {
                    controls($valueContainer.value)
                    ForEach(preferenceControls) { control in
                        renderControl(control)
                    }
                    ForEach(globalControls) { control in
                        renderControl(control)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(systemBackgroundColor.opacity(0.7))
        .opacity(showControlsOverlay ? 1.0 : 0.0)
    }
    
    var renderedComponent: some View {
        ZStack {
            component($valueContainer.value, actions, context)
            // the id breaks preference keys, gotta think of a better way for uikit
//                .id(UUID()) // id for UIKit views to update
        }
        .frame(width: screenSizeControlModel.screenWidth, height: screenSizeControlModel.screenHeight)
    }
    
    @ViewBuilder
    var content: some View {
        switch configuration {
        case .overlay:
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showControlsOverlay = true
                        }, label: {
                            Image(packageResource: "storybook_icon", ofType: "png")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20)
                                .padding(.horizontal, 20)
                        })
                        .opacity(0.95)
                    }
                    Spacer()
                }
                renderedControls
            }
            .background(renderedComponent)
            .background(systemBackgroundColor.edgesIgnoringSafeArea(.all))
        case .inline:
            ZStack {
                systemBackgroundColor.edgesIgnoringSafeArea(.all)
                ScrollView {
                    renderedComponent
                    systemDividerColor.frame(height: 2)
                    renderedControls
                }
            }
        }
    }
    
    var body: some View {
        content
        .onPreferenceChange(StorybookControlsPrefKey.self, perform: { controls in
            preferenceControls = controls
        })
        .overlay(buttonModal().animation(.easeOut))
        .onReceive(actions.$message, perform: { message in
            guard let message = message else {
                return
            }
            buttonMessage = ButtonMessage(message: message)
        })
    }
    
    @ViewBuilder
    private func renderControl(_ control: StorybookControlType) -> some View {
        control.render()
    }
    
    // TODO: fix button modal not disappearing after rapid taps
    @ViewBuilder
    func buttonModal() -> some View {
        if let message = buttonMessage?.message {
            Text(message)
            .internalTitleFont()
            .padding()
            .background(Color.gray)
            .cornerRadius(20)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    buttonMessage = nil
                }
            }
        }
    }
}

@available(iOS 13, *)
@available(macOS 11, *)
struct AppendControlsModifier: ViewModifier {
    
    @Environment(\.storybookControls) var envControls: [StorybookControlType]
    // Using a preference to determine if the view is already embedded within
    // a ControlledPreview container, if it is then do nothing otherwise embed
    // it so the controls will render. This is kinda hacky and will cause the
    // UI to flicker when it reloads, unsure what side effects this will have
    @State private var isEmbedded = false
    @State private var prefControls = [StorybookControlType]()
    let controls: [StorybookControlType]
    
    @ViewBuilder
    func renderContent(_ content: Content) -> some View {
        if !isEmbedded {
            ControlledPreview(initialState: Void(), component: { _, _ in
                content.onPreferenceChange(StorybookControlsEmbedPrefKey.self, perform: { value in
                    isEmbedded = value
                })
                
            }, controls: { _ in
                
            })
            .environment(\.storybookControls, controls + envControls)
        } else {
            content
                .environment(\.storybookControls, controls + envControls)
                .onPreferenceChange(StorybookControlsPrefKey.self, perform: { value in
                    prefControls = value
                })
                .preference(key: StorybookControlsPrefKey.self, value: prefControls + controls)
        }
    }
    
    func body(content: Content) -> some View {
        renderContent(content)
    }
}

@available(iOS 13, *)
@available(macOS 11, *)
public extension View {
    
    /**
     Used to set the controls that apply to all views in Storybook. This should be set on the root StorybookCollection
     */
    func storybookSetGlobalControls(_ controls: StorybookControlType...) -> some View {
        self.environment(\.storybookControls, controls)
    }
    
    /**
     Used to add controls to the current preview context.
     */
    func storybookAddControls(_ controls: StorybookControlType...) -> some View {
        self.modifier(AppendControlsModifier(controls: controls))
    }
}
#endif
