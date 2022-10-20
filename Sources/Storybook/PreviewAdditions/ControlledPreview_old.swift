//#if DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//class GenericObservableObject<T>: ObservableObject {
//    @Published var value: T {
//        didSet {
//            updateId += 1
//        }
//    }
//    @Published fileprivate var updateId = 0
//    
//    init(_ value: T) {
//        self.value = value
//    }
//}
//
//@available(iOS 13, *)
//public class PreviewActions: ObservableObject {
//    @Published private (set) var message: String?
//    
//    public func tappedButton(message: String) {
//        self.message = message
//    }
//}
//
//struct ButtonMessage: Identifiable {
//    let message: String
//    var id: String {
//        return message
//    }
//}
//
//public protocol ControlledPreviewContext { }
//
//public class NoContext: ControlledPreviewContext { }
//
//@available(iOS 14, *)
//@available(macOS 11, *)
//private struct _ControlledPreview<StateValue, Controls: View, Component: View, Context: ControlledPreviewContext>: View {
//    
//    @ObservedObject var valueContainer: GenericObservableObject<StateValue>
//    private let configuration: ControlledPreviewConfiguration
//    private let controls: (Binding<StateValue>) -> Controls
//    private let component: (Binding<StateValue>, PreviewActions, Context) -> Component
//    @State private var context: Context
//    @State private var showControlsOverlay = false
//    @State private var buttonMessage: ButtonMessage?
//    @ObservedObject private var actions = PreviewActions()
//    @Environment(\.colorScheme) private var colorScheme
//    @EnvironmentObject private var screenSizeControlModel: ScreenSizeControlModel
//    
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        context: Context,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) {
//        self.configuration = configuration
//        self._context = State(initialValue: context)
//        self.valueContainer = GenericObservableObject(initialState)
//        self.controls = controls
//        self.component = component
//    }
//    
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) where Context == NoContext {
//        self.init(
//            configuration: configuration,
//            initialState: initialState,
//            context: NoContext(),
//            component: { state, actions, _ in
//                component(state, actions)
//            },
//            controls: controls
//        )
//    }
//    
//    func containerView<Child: View>(@ViewBuilder child: @escaping (GeometryProxy) -> Child) -> some View {
//        GeometryReader { proxy in
//            ZStack {
//                systemBackgroundColor.edgesIgnoringSafeArea(.all)
//                child(proxy)
//            }
//        }
//        .overlay(buttonModal().animation(.easeOut))
//        .onReceive(actions.$message, perform: { message in
//            guard let message = message else {
//                return
//            }
//            buttonMessage = ButtonMessage(message: message)
//        })
//    }
//    
//    @ViewBuilder
//    var content: some View {
//        switch configuration {
//        case .overlay:
//            ZStack {
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            self.showControlsOverlay = true
//                        }, label: {
//                            Image(packageResource: "storybook_icon", ofType: "pdf")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 20)
//                                .padding(.horizontal, 20)
//                        })
//                        .opacity(0.95)
//                    }
//                    Spacer()
//                }
//                controlPanel()
//            }
//            .background(componentContent())
//            .background(systemBackgroundColor.edgesIgnoringSafeArea(.all))
//            .overlay(buttonModal().animation(.easeOut))
//            .onReceive(actions.$message, perform: { message in
//                guard let message = message else {
//                    return
//                }
//                buttonMessage = ButtonMessage(message: message)
//            })
//        case .inline:
//            containerView { proxy in
//                ScrollView {
//                    componentContent()
//                    systemDividerColor.frame(height: 2)
//                    controlContent()
//                }
//            }
//        }
//    }
//    
//    public var body: some View {
//        content
//            .environment(\.isEmbeddedInControls, true)
//    }
//    
//    private func controlPanel() -> some View {
//        VStack {
//            ZStack {
//                HStack {
//                    Button(action: {
//                        self.showControlsOverlay = false
//                    }, label: {
//                        Image(systemName: "xmark.circle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30, height: 30)
//                    })
//                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
//                    Spacer()
//                }
//                Text(verbatim: "Storybook iOS").internalTitleFont()
//            }
//            
//            ScrollView {
//                controlContent()
//            }
//        }
//        .background(systemBackgroundColor.opacity(0.7))
//        .opacity(showControlsOverlay ? 1.0 : 0.0)
//    }
//    
//    private func componentContent() -> some View {
//        ZStack {
//            component($valueContainer.value, actions, context)
//                .id(valueContainer.updateId)
////                .id(UUID()) // id for UIKit views to update
//        }
//            .frame(width: screenSizeControlModel.screenWidth, height: screenSizeControlModel.screenHeight)
////            .environment(\.colorScheme, controlledColorScheme)
//    }
//    
//    private func controlContent() -> some View {
//        controls($valueContainer.value).padding(.horizontal)
//    }
//    
//    // TODO: fix button modal not disappearing after rapid taps
//    @ViewBuilder
//    func buttonModal() -> some View {
//        if let message = buttonMessage?.message {
//            Text(message)
//            .internalTitleFont()
//            .padding()
//            .background(Color.gray)
//            .cornerRadius(20)
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                    buttonMessage = nil
//                }
//            }
//        }
//    }
//}
//
//@available(iOS 14, *)
//@available(macOS 11, *)
//private struct _ControlledPreview2<StateValue, Controls: View, Component: View, Context: ControlledPreviewContext>: View {
//    
//    @ObservedObject var valueContainer: GenericObservableObject<StateValue>
//    private let configuration: ControlledPreviewConfiguration
//    private let controls: (Binding<StateValue>) -> Controls
//    private let component: (Binding<StateValue>, PreviewActions, Context) -> Component
//    @State private var context: Context
//    @State private var showControlsOverlay = false
//    @State private var buttonMessage: ButtonMessage?
//    @ObservedObject private var actions = PreviewActions()
//    @Environment(\.colorScheme) private var colorScheme
//    @EnvironmentObject private var screenSizeControlModel: ScreenSizeControlModel
//    
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        context: Context,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) {
//        self.configuration = configuration
//        self._context = State(initialValue: context)
//        self.valueContainer = GenericObservableObject(initialState)
//        self.controls = controls
//        self.component = component
//    }
//    
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) where Context == NoContext {
//        self.init(
//            configuration: configuration,
//            initialState: initialState,
//            context: NoContext(),
//            component: { state, actions, _ in
//                component(state, actions)
//            },
//            controls: controls
//        )
//    }
//    
//    func containerView<Child: View>(@ViewBuilder child: @escaping (GeometryProxy) -> Child) -> some View {
//        GeometryReader { proxy in
//            ZStack {
//                systemBackgroundColor.edgesIgnoringSafeArea(.all)
//                child(proxy)
//            }
//        }
//        .overlay(buttonModal().animation(.easeOut))
//        .onReceive(actions.$message, perform: { message in
//            guard let message = message else {
//                return
//            }
//            buttonMessage = ButtonMessage(message: message)
//        })
//    }
//    
//    @ViewBuilder
//    var content: some View {
//        switch configuration {
//        case .overlay:
//            componentContent()
////            ZStack {
////                VStack {
////                    HStack {
////                        Spacer()
////                        Button(action: {
////                            self.showControlsOverlay = true
////                        }, label: {
////                            Image(packageResource: "storybook_icon", ofType: "pdf")
////                                .resizable()
////                                .aspectRatio(contentMode: .fit)
////                                .frame(width: 20)
////                                .padding(.horizontal, 20)
////                        })
////                        .opacity(0.95)
////                    }
////                    Spacer()
////                }
////                controlPanel()
////            }
////            .background(componentContent())
////            .background(systemBackgroundColor.edgesIgnoringSafeArea(.all))
////            .overlay(buttonModal().animation(.easeOut))
////            .onReceive(actions.$message, perform: { message in
////                guard let message = message else {
////                    return
////                }
////                buttonMessage = ButtonMessage(message: message)
////            })
//        case .inline:
//            containerView { proxy in
//                ScrollView {
//                    componentContent()
//                    systemDividerColor.frame(height: 2)
//                    controlContent()
//                }
//            }
//        }
//    }
//    
//    public var body: some View {
//        content
////        component($valueContainer.value, actions, context)
//    }
//    
//    private func controlPanel() -> some View {
//        VStack {
//            ZStack {
//                HStack {
//                    Button(action: {
//                        self.showControlsOverlay = false
//                    }, label: {
//                        Image(systemName: "xmark.circle")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30, height: 30)
//                    })
//                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
//                    Spacer()
//                }
//                Text(verbatim: "Storybook iOS").internalTitleFont()
//            }
//            
//            ScrollView {
//                controlContent()
//            }
//        }
//        .background(systemBackgroundColor.opacity(0.7))
//        .opacity(showControlsOverlay ? 1.0 : 0.0)
//    }
//    
//    private func componentContent() -> some View {
//        ZStack {
//            component($valueContainer.value, actions, context)
//            // the id breaks preference keys, gotta think of a better way for uikit
////                .id(UUID()) // id for UIKit views to update
//        }
//            .frame(width: screenSizeControlModel.screenWidth, height: screenSizeControlModel.screenHeight)
////            .environment(\.colorScheme, controlledColorScheme)
//    }
//    
//    private func controlContent() -> some View {
//        controls($valueContainer.value).padding(.horizontal)
//    }
//    
//    // TODO: fix button modal not disappearing after rapid taps
//    @ViewBuilder
//    func buttonModal() -> some View {
//        if let message = buttonMessage?.message {
//            Text(message)
//            .internalTitleFont()
//            .padding()
//            .background(Color.gray)
//            .cornerRadius(20)
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                    buttonMessage = nil
//                }
//            }
//        }
//    }
//}
//
//public enum ControlledPreviewConfiguration {
//    case overlay
//    case inline
//}
//
//@available(iOS 14, *)
//@available(macOS 11, *)
//public struct ControlledPreview<StateValue, Controls: View, Component: View, Context: ControlledPreviewContext>: View {
//    
//    private let preview: _ControlledPreview<StateValue, Controls, Component, Context>
//        
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        context: Context,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) {
//        self.preview = _ControlledPreview(
//            configuration: configuration,
//            initialState: initialState,
//            context: context,
//            component: component,
//            controls: controls
//        )
//    }
//    
//    public init(
//        configuration: ControlledPreviewConfiguration = .overlay,
//        initialState: StateValue,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
//        @ViewBuilder controls: @escaping (Binding<StateValue>) -> Controls
//    ) where Context == NoContext {
//        self.init(
//            configuration: configuration,
//            initialState: initialState,
//            context: NoContext(),
//            component: { state, actions, _ in
//                component(state, actions)
//            },
//            controls: controls
//        )
//    }
//    
//    public var body: some View {
//        StorybookControlContext {
//            preview
//        }
//    }
//}
//
//#endif
