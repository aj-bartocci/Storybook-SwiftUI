#if DEBUG
import SwiftUI

@available(iOS 13, *)
class GenericObservableObject<T>: ObservableObject {
    @Published var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

@available(iOS 13, *)
public class PreviewActions: ObservableObject {
    @Published private (set) var message: String?
    
    public func tappedButton(message: String) {
        self.message = message
    }
}

struct ButtonMessage: Identifiable {
    let message: String
    var id: String {
        return message
    }
}

public protocol ControlledPreviewContext { }

public class NoContext: ControlledPreviewContext { }

// TODO: add different configurations for rendering the controls
// - for small views putting the controls in a scrollview underneath might be fine
// - for larger screens overlaying the controls is probably better but needs to be
    // triggered from the UI somehow - either a button or action

//@available(iOS 13, *)
//public struct ControlledPreview<StateValue, KnobView: View, Component: View, Context: ControlledPreviewContext>: View {
//
//    public enum Configuration {
//        case overlay
//        case inline
//    }
//
//    @ObservedObject var valueContainer: GenericObservableObject<StateValue>
//    private let configuration: Configuration
//    private let knobs: (Binding<StateValue>) -> KnobView
//    private let component: (Binding<StateValue>, PreviewActions, Context) -> Component
//    @State var buttonMessage: ButtonMessage?
//    @ObservedObject private var actions = PreviewActions()
//    @State var isDarkMode = false
//    @State var contentSize = ContentSizeCategory.large
//    @State var didAdjustColorScheme = false
//    @State var context: Context
//    @State var showControlsOverlay = false
//    @Environment(\.colorScheme) var colorScheme
//
//    public init(
//        configuration: Configuration = .overlay,
//        initialState: StateValue,
//        context: Context,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
//        @ViewBuilder knobs: @escaping (Binding<StateValue>) -> KnobView
//    ) {
//        self.configuration = configuration
//        self._context = State(initialValue: context)
//        self.valueContainer = GenericObservableObject(initialState)
//        self.knobs = knobs
//        self.component = component
//    }
//
//    public init(
//        configuration: Configuration = .overlay,
//        initialState: StateValue,
//        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
//        @ViewBuilder knobs: @escaping (Binding<StateValue>) -> KnobView
//    ) where Context == NoContext {
//        self.init(
//            configuration: configuration,
//            initialState: initialState,
//            context: NoContext(),
//            component: { state, actions, _ in
//                component(state, actions)
//            },
//            knobs: knobs
//        )
//    }
//
//    public var body: some View {
//        ZStack {
//            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
//            controlOverlay()
//            content()
//        }
//        .overlay(buttonModal().animation(.easeOut))
//        .environment(\.colorScheme, isDarkMode ? .dark : .light)
//        .environment(\.sizeCategory, contentSize)
//        .onReceive(actions.$message, perform: { message in
//            guard let message = message else {
//                return
//            }
//            buttonMessage = ButtonMessage(message: message)
//        })
//        .onAppear(perform: {
//            self.isDarkMode = colorScheme == .dark
//        })
//    }
//
//    @ViewBuilder
//    private func content() -> some View {
//        switch configuration {
//        case .overlay:
//            componentContent()
//        case .inline:
//            ScrollView {
//                componentContent()
//                Color(UIColor.label).frame(height: 2)
//                controlContent()
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func controlOverlay() -> some View {
//        if configuration == .overlay {
//            ZStack {
//                VStack {
//                    HStack {
//                        Spacer()
//                        Button(action: {
//                            self.showControlsOverlay = true
//                        }, label: {
//                            Text("Controls")
//                        })
//                        .opacity(0.65)
//                    }
//                    Spacer()
//                }
//                controlPanel()
//            }
//        }
//    }
//
//    private func controlPanel() -> some View {
//        VStack {
//            HStack {
//                Button(action: {
//                    self.showControlsOverlay = false
//                }, label: {
//                    Text("Close")
//                })
//            }
//            ScrollView {
//                controlContent()
//            }
//        }
//        .background(Color(UIColor.systemBackground).opacity(0.7))
//        .opacity(showControlsOverlay ? 1.0 : 0.0)
//    }
//
//    private func componentContent() -> some View {
//        component($valueContainer.value, actions, context).id(UUID()) // id for UIKit views to update
//    }
//
//    private func controlContent() -> some View {
//        knobs($valueContainer.value).padding(.horizontal)
////        for some reason prefrence key breaks when using overlay but works with inline
//        .onPreferenceChange(DarkModePreferenceKey.self) { isDarkMode in
//            self.isDarkMode = isDarkMode
//        }
//        .onPreferenceChange(ContentSizePreferenceKey.self, perform: { newSize in
//            self.contentSize = newSize
//        })
//    }
//
//    @ViewBuilder
//    func buttonModal() -> some View {
//        if let message = buttonMessage?.message {
//            Text(message)
//            .font(.system(size: ControlConstant.titleSize))
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

/*
For some reason onPreferenceChange gets messed up when content is rendered inside of a scrollview
 if the content render is deferred until after the scrollview appears then it works. Using this hack for now
 to get around preferences not updating but it might not be a foolproof solution.
 
 based off of S.O. answer: https://stackoverflow.com/a/61765994
 
*/
@available(iOS 13, *)
struct DeferredScrollView<T: View>: View {
    @State private var showContent = false
    
    let content: () -> T
    init(@ViewBuilder content: @escaping () -> T) {
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            if showContent {
                content()
            }
        }
        .onAppear {
            self.showContent = true
        }
    }
}

@available(iOS 13, *)
public struct ControlledPreview<StateValue, KnobView: View, Component: View, Context: ControlledPreviewContext>: View {
    
    public enum Configuration {
        case overlay
        case inline
    }
    
    @ObservedObject var valueContainer: GenericObservableObject<StateValue>
    private let configuration: Configuration
    private let knobs: (Binding<StateValue>) -> KnobView
    private let component: (Binding<StateValue>, PreviewActions, Context) -> Component
    @State var buttonMessage: ButtonMessage?
    @ObservedObject private var actions = PreviewActions()
    @State var isDarkMode = false
    @State var contentSize = ContentSizeCategory.large
    @State var didAdjustColorScheme = false
    @State var context: Context
    @State var showControlsOverlay = false
    @Environment(\.colorScheme) var colorScheme
    
    public init(
        configuration: Configuration = .overlay,
        initialState: StateValue,
        context: Context,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions, Context) -> Component,
        @ViewBuilder knobs: @escaping (Binding<StateValue>) -> KnobView
    ) {
        self.configuration = configuration
        self._context = State(initialValue: context)
        self.valueContainer = GenericObservableObject(initialState)
        self.knobs = knobs
        self.component = component
    }
    
    public init(
        configuration: Configuration = .overlay,
        initialState: StateValue,
        @ViewBuilder component: @escaping (Binding<StateValue>, PreviewActions) -> Component,
        @ViewBuilder knobs: @escaping (Binding<StateValue>) -> KnobView
    ) where Context == NoContext {
        self.init(
            configuration: configuration,
            initialState: initialState,
            context: NoContext(),
            component: { state, actions, _ in
                component(state, actions)
            },
            knobs: knobs
        )
    }
    
    func containerView<Child: View>(@ViewBuilder child: () -> Child) -> some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            child()
        }
        .overlay(buttonModal().animation(.easeOut))
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .environment(\.sizeCategory, contentSize)
        .onAppear(perform: {
            self.isDarkMode = colorScheme == .dark
        })
        .onReceive(actions.$message, perform: { message in
            guard let message = message else {
                return
            }
            buttonMessage = ButtonMessage(message: message)
        })
    }
    
    public var body: some View {
        switch configuration {
        case .overlay:
            containerView {
                componentContent()
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showControlsOverlay = true
                        }, label: {
                            Text("Controls")
                        })
                        .opacity(0.65)
                    }
                    Spacer()
                }
                controlPanel()
            }
        case .inline:
            containerView {
                ScrollView {
                    componentContent()
                    Color(UIColor.label).frame(height: 2)
                    controlContent()
                }
            }
        }
    }
    
    private func controlPanel() -> some View {
        VStack {
            HStack {
                Button(action: {
                    self.showControlsOverlay = false
                }, label: {
                    Text("Close")
                })
            }
            DeferredScrollView {
                controlContent()
            }
        }
        .background(Color(UIColor.systemBackground).opacity(0.7))
        .opacity(showControlsOverlay ? 1.0 : 0.0)
    }
    
    private func componentContent() -> some View {
        component($valueContainer.value, actions, context).id(UUID()) // id for UIKit views to update
    }
    
    private func controlContent() -> some View {
        knobs($valueContainer.value).padding(.horizontal)
        .onPreferenceChange(DarkModePreferenceKey.self) { isDarkMode in
            self.isDarkMode = isDarkMode
        }
        .onPreferenceChange(ContentSizePreferenceKey.self, perform: { newSize in
            self.contentSize = newSize
        })
    }
    
    // TODO: fix button modal not disappearing after rapid taps
    @ViewBuilder
    func buttonModal() -> some View {
        if let message = buttonMessage?.message {
            Text(message)
            .font(.system(size: ControlConstant.titleSize))
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

#endif
