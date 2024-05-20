import Combine
import SwiftUI

@available(iOS 13, *)
@available(macOS 11, *)
public struct StorybookControl {
    let controlId: String
    let view: AnyView
    
    public init<T: View>(id: String, @ViewBuilder view: () -> T) {
        self.controlId = id
        self.view = AnyView(view())
    }
}

@available(iOS 13, *)
@available(macOS 11, *)
public enum StorybookControlType: Identifiable, Equatable {
    public enum IconType {
        case figma
        case jira
        case custom(Image)
    }
    #if os(iOS)
    case dynamicType
    case screenSize
    #endif
    case colorScheme
    case documentationLink(title: String, url: String, icon: IconType? = nil)
    case custom(_ control: StorybookControl)
    
    public var id: String {
        switch self {
        #if os(iOS)
        case .dynamicType:
            return "com.ajbartocci.storybook.dynamicType"
        case .screenSize:
            return "com.ajbartocci.storybook.screenSize"
        #endif
        case .colorScheme:
            return "com.ajbartocci.storybook.colorScheme"
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
        #if os(iOS)
        case .dynamicType:
            DynamicTypeControl()
        case .screenSize:
            ScreenSizeControl()
        #endif
        case .colorScheme:
            ColorSchemeControl()
        case .documentationLink(let title, let url, let icon):
            DocumentationControl(icon: icon?.icon, title: title, url: url)
        case .custom(let control):
            control.view
        }
    }
}
