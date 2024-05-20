import SwiftUI

public enum ColorScheme {
    case light
    case dark
}

@available(iOS 13, *)
@available(macOS 11, *)
public class ColorSchemeControlModel: ObservableObject {
    @Published public var isDarkMode: Bool?
}

@available(iOS 13, *)
@available(macOS 11, *)
public struct ColorSchemeControl: View {
    
    @EnvironmentObject var model: ColorSchemeControlModel
    @Environment(\.colorScheme) var colorScheme
    
    public init() { }
    
    var isDarkBinding: Binding<Bool> {
        Binding(get: {
            if let value = model.isDarkMode {
                return value
            } else {
                return colorScheme == .dark
            }
        }, set: {
            model.isDarkMode = $0
        })
    }
    
    public var body: some View {
        VStack {
            Toggle(isOn: isDarkBinding, label: {
                Text("Dark Mode").internalTitleFont()
            })
            systemDividerColor.frame(height: 1)
        }
    }
}
