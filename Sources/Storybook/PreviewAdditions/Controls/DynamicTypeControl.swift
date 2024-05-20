#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, *)
@available(macOS 11, *)
public class DynamicTypeControlModel: ObservableObject {
    @Published public var fontSize: DynamicTypeControl.ContentSize = .large
}

@available(iOS 13, *)
@available(macOS 11, *)
public struct DynamicTypeControl: View {
    public enum ContentSize: Int {
        case extraSmall
        case small
        case medium
        case large
        case extraLarge
        case extraExtraLarge
        case extraExtraExtraLarge
        case accessibilityMedium
        case accessibilityLarge
        case accessibilityExtraLarge
        case accessibilityExtraExtraLarge
        case accessibilityExtraExtraExtraLarge
        
        var title: String {
            switch self {
            case .extraSmall:
                return "Extra Small"
            case .small:
                return "Small"
            case .medium:
                return "Medium"
            case .large:
                return "Large"
            case .extraLarge:
                return "XL"
            case .extraExtraLarge:
                return "XXL"
            case .extraExtraExtraLarge:
                return "XXXL"
            case .accessibilityMedium:
                return "Accessibility Medium"
            case .accessibilityLarge:
                return "Accessibility Large"
            case .accessibilityExtraLarge:
                return "Accessibility XL"
            case .accessibilityExtraExtraLarge:
                return "Accessibility XXL"
            case .accessibilityExtraExtraExtraLarge:
                return "Accessibility XXXL"
            }
        }
        
        func contentSize() -> ContentSizeCategory {
            switch self {
            case .extraSmall:
                return .extraSmall
            case .small:
                return .small
            case .medium:
                return .medium
            case .large:
                return .large
            case .extraLarge:
                return .extraLarge
            case .extraExtraLarge:
                return .extraExtraLarge
            case .extraExtraExtraLarge:
                return .extraExtraExtraLarge
            case .accessibilityMedium:
                return .accessibilityMedium
            case .accessibilityLarge:
                return .accessibilityLarge
            case .accessibilityExtraLarge:
                return .accessibilityExtraLarge
            case .accessibilityExtraExtraLarge:
                return .accessibilityExtraExtraLarge
            case .accessibilityExtraExtraExtraLarge:
                return .accessibilityExtraExtraExtraLarge
            }
        }
    }
    
    @EnvironmentObject var viewModel: DynamicTypeControlModel
    
    var intProxy: Binding<Double> {
        Binding<Double>(get: {
            return Double(viewModel.fontSize.rawValue)
        }, set: {
            viewModel.fontSize = ContentSize(rawValue: Int($0))!
        })
    }
    
    public init() { }
    
    public var body: some View {
        #if os(iOS)
        VStack {
            HStack {
                Text("Dynamic Font Size:")
                Spacer()
            }
            Slider(
                value: intProxy,
                in: Double(ContentSize.extraSmall.rawValue)...Double(ContentSize.accessibilityExtraExtraExtraLarge.rawValue),
                step: 1.0,
                label: {
                    Text(viewModel.fontSize.title)
                },
                minimumValueLabel: {
                    Text("Extra\nSmall")
                        .multilineTextAlignment(.center)
                        .internalTinyFont()
                },
                maximumValueLabel: {
                    Text("Accessibility\nXXXL")
                        .multilineTextAlignment(.center)
                        .internalTinyFont()
                }
            )
            Text(viewModel.fontSize.title).internalSubtitleFont()
            systemDividerColor.frame(height: 1)
        }
        .padding(.top, ControlConstant.rowSpacing)
        .internalTitleFont()
        #else
        // For some reason dynamic type doesn't work on mac
        // even in the previews in xcode Apple doesn't provide
        // a control for it...
        Text("Dynamic type is not supported")
        #endif
    }
}
#endif
