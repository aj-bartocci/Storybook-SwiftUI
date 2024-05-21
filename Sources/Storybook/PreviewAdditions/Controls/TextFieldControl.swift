#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, *)
@available(macOS 11, *)
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
            Text("\(placeholder):").internalSubtitleFont()
            TextField(placeholder, text: $text).internalTitleFont()
            systemDividerColor.frame(height: 1)
        }
    }
}
#endif
