//
//  ControlledPreview+Utils.swift
//
//
//  Created by AJ Bartocci on 5/17/24.
//

import SwiftUI

@available(iOS 13, *)
@available(macOS 10.15, *)
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

@available(iOS 13, *)
@available(macOS 10.15, *)
class GenericObservableObject<T>: ObservableObject {
    @Published var value: T {
        didSet {
            updateId += 1
        }
    }
    @Published fileprivate var updateId = 0
    
    init(_ value: T) {
        self.value = value
    }
}

public protocol ControlledPreviewContext { }

public class NoContext: ControlledPreviewContext { }

public enum ControlledPreviewConfiguration {
    case overlay
    case inline
}