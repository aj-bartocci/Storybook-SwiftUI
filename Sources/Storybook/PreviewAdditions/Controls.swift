import Combine
import SwiftUI

// workaround for @StateObject
@available(iOS 13, *)
struct ViewModelWrapper<V: View, ViewModel: ObservableObject>: View {
    private let contentView: V
    @State private var contentViewModel: ViewModel

    init(contentView: @autoclosure () -> V, vm: @autoclosure () -> ViewModel) {
        self._contentViewModel = State(initialValue: vm())
        self.contentView = contentView()
    }

    var body: some View {
        contentView
        .environmentObject(contentViewModel)
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
public enum StorybookControlType: Identifiable, Equatable {
    public enum IconType {
        case figma
        case jira
        case custom(Image)
    }
    case colorScheme
    case dynamicType
    case screenSize
    case documentationLink(title: String, url: String, icon: IconType? = nil)
    case custom(control: StorybookControlView)
    
    public var id: String {
        switch self {
        case .colorScheme:
            return "com.ajbartocci.storybook.colorScheme"
        case .dynamicType:
            return "com.ajbartocci.storybook.dynamicType"
        case .screenSize:
            return "com.ajbartocci.storybook.screenSize"
        case let .documentationLink(title: title, url: url, icon: _):
            return "doc-\(title)-\(url)"
        case .custom(let control):
            return control.controlId
        }
    }
    
    public static func == (lhs: StorybookControlType, rhs: StorybookControlType) -> Bool {
        // this probably might not work for dynamic controls?
        return lhs.id == rhs.id
    }
    
    @ViewBuilder
    public func render() -> some View {
        switch self {
        case .colorScheme:
            ColorSchemeControl()
        case .dynamicType:
            DynamicTypeControl()
        case .screenSize:
            ScreenSizeControl()
        case .documentationLink(let title, let url, let icon):
            DocumentationControl(icon: icon?.icon, title: title, url: url)
        case .custom(let control):
            control.view
        }
    }
}
