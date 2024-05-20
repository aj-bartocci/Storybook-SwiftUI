import SwiftUI

@available(iOS 13, *)
@available(macOS 11, *)
public class ScreenSizeControlModel: ObservableObject {
    @Published fileprivate var screenSize: ScreenSizeControl.PhoneModel = .current
    @Published var count = 0
    
    var screenWidth: CGFloat? {
        switch screenSize {
        case .current: return nil
        default: return screenSize.screenSize().width
        }
    }
    
    var screenHeight: CGFloat? {
        switch screenSize {
        case .current: return nil
        default: return screenSize.screenSize().height
        }
    }
}

@available(iOS 13, *)
@available(macOS 11, *)
public struct ScreenSizeControl: View {
    
    public enum PhoneModel: Int {
        case current
        case se
        case eleven
        case twelve
        case thirteen
        case fourteen
        case fourteenPro
        
        static let largest = PhoneModel.fourteenPro
        static let smallest = PhoneModel.current
        
        var title: String {
            switch self {
            case .current:
                return "Current"
            case .se:
                return "SE"
            case .eleven:
                return "11"
            case .twelve:
                return "12"
            case .thirteen:
                return "13"
            case .fourteen:
                return "14"
            case .fourteenPro:
                return "14 Pro"
            }
        }
        
        func screenSize() -> CGSize {
            switch self {
            case .current:
                return .zero
            case .se:
                return CGSize(width: 375, height: 667)
            case .twelve, .thirteen, .fourteen:
                return CGSize(width: 390, height: 844)
            case .eleven:
                return CGSize(width: 414, height: 896)
            case .fourteenPro:
                return CGSize(width: 393, height: 852)
            }
        }
        
    }
    
    @EnvironmentObject private var viewModel: ScreenSizeControlModel
    
    var intProxy: Binding<Double> {
        Binding<Double>(get: {
            return Double(viewModel.screenSize.rawValue)
        }, set: {
            viewModel.screenSize = PhoneModel(rawValue: Int($0))!
            viewModel.count += 1
        })
    }
    
    public init() { }
    
    public var body: some View {
        VStack {
            HStack {
                Text("Phone Size:")
                Spacer()
            }
            Slider(
                value: intProxy,
                in: Double(PhoneModel.smallest.rawValue)...Double(PhoneModel.largest.rawValue),
                step: 1.0,
                label: {
                    Text(viewModel.screenSize.title)
                },
                minimumValueLabel: {
                    Text(PhoneModel.smallest.title)
                        .multilineTextAlignment(.center)
                        .internalTinyFont()
                },
                maximumValueLabel: {
                    Text(PhoneModel.largest.title)
                        .multilineTextAlignment(.center)
                        .internalTinyFont()
                }
            )
            Text(viewModel.screenSize.title).internalSubtitleFont()
            systemDividerColor.frame(height: 1)
        }
        .padding(.top, ControlConstant.rowSpacing)
        .internalTitleFont()
    }
}
