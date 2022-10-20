#if DEBUG
import Combine
import SwiftUI

struct ControlConstant {
    static let titleSize: CGFloat = 16
    static let subtitleSize: CGFloat = 12
    static let tinyText: CGFloat = 10
}

@available(iOS 13, *)
public struct TextFieldControl: View {
    
    let placeholder: String
    @Binding var text: String
    
    public init(
        placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(placeholder):").font(.system(size: ControlConstant.subtitleSize))
            TextField(placeholder, text: $text).font(.system(size: ControlConstant.titleSize))
            Color(UIColor.label).frame(height: 1)
        }
    }
}

public enum ColorScheme {
    case light
    case dark
}

class ColorSchemeControlModel: ObservableObject {
    @Published var isDarkMode = false
    @Published var didAdjust = false
    @Published var test = false
}

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

//@available(iOS 13, *)
//struct ColorSchemeView: View {
//
//    @EnvironmentObject var model: ColorSchemeControlModel
//    @Environment(\.colorScheme) var colorScheme
//
//    var isDarkBinding: Binding<Bool> {
//        Binding(get: {
//            if model.didAdjust {
//                return model.isDarkMode
//            } else {
//                return colorScheme == .dark
//            }
//        }, set: {
//            model.isDarkMode = $0
//        })
//    }
//
//    var body: some View {
//        VStack {
//            Toggle(isOn: isDarkBinding, label: {
//                Text("Dark Mode").font(.system(size: ControlConstant.titleSize))
//            })
//            Color(UIColor.label).frame(height: 1)
//        }
//        .onReceive(model.$isDarkMode.dropFirst(), perform: { _ in
//            model.didAdjust = true
//        })
//        .preference(key: DarkModePreferenceKey.self, value: isDarkBinding.wrappedValue)
//    }
//}

@available(iOS 13, *)
struct ColorSchemeView: View {
    
    @EnvironmentObject var model: ColorSchemeControlModel
    @Environment(\.colorScheme) var colorScheme
    
    var isDarkBinding: Binding<Bool> {
        Binding(get: {
            if model.didAdjust {
                return model.isDarkMode
            } else {
                return colorScheme == .dark
            }
        }, set: {
            model.isDarkMode = $0
        })
    }
    
    var body: some View {
        VStack {
            Toggle(isOn: isDarkBinding, label: {
                Text("Dark Mode").font(.system(size: ControlConstant.titleSize))
            })
            Color(UIColor.label).frame(height: 1)
        }
        .onReceive(model.$isDarkMode.dropFirst(), perform: { _ in
            model.didAdjust = true
        })
        .preference(key: DarkModePreferenceKey.self, value: isDarkBinding.wrappedValue)
    }
}

@available(iOS 13, *)
public struct ColorSchemeControl: View {
    public init() { }
    
    public var body: some View {
        ViewModelWrapper(contentView: ColorSchemeView(), vm: ColorSchemeControlModel())
    }
}

@available(iOS 13, *)
public struct DynamicFontControl: View {
    enum ContentSize: Int {
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
    @State private var fontSize: ContentSize = .large
    var intProxy: Binding<Double>{
            Binding<Double>(get: {
                return Double(fontSize.rawValue)
            }, set: {
                fontSize = ContentSize(rawValue: Int($0))!
            })
        }
    
    public init() { }
    
    public var body: some View {
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
                    Text(fontSize.title)
                },
                minimumValueLabel: {
                    Text("Extra\nSmall")
                        .multilineTextAlignment(.center)
                        .font(.system(size: ControlConstant.tinyText))
                },
                maximumValueLabel: {
                    Text("Accessibility\nXXXL")
                        .multilineTextAlignment(.center)
                        .font(.system(size: ControlConstant.tinyText))
                }
            )
            Text(fontSize.title).font(.system(size: ControlConstant.subtitleSize))
            Color(UIColor.label).frame(height: 1)
        }
        .font(.system(size: ControlConstant.titleSize))
        .preference(key: ContentSizePreferenceKey.self, value: fontSize.contentSize())
    }
    
    private func createToggle(title: String, value: Binding<Bool>) -> some View {
        Toggle(isOn: value, label: {
            Text(title)
        })
    }
}

#endif
