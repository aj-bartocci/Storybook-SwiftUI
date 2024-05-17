//
//  ControlHelpers.swift
//
//
//  Created by AJ Bartocci on 5/6/24.
//

import SwiftUI

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsKey: EnvironmentKey {
    static var defaultValue: [StorybookControlType] = []
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsEmbedEnvKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookContextEmbedKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

@available(iOS 13, *)
@available(macOS 10.15, *)
struct StorybookControlsEmbedPrefKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
enum StorybookControlsPrefKey: PreferenceKey {
    static var defaultValue: [StorybookControlType] = []
    
    static func reduce(value: inout [StorybookControlType], nextValue: () -> [StorybookControlType]) {
        value += nextValue()
    }
}

@available(iOS 13, *)
@available(macOS 10.15, *)
extension EnvironmentValues {
    var storybookControls: [StorybookControlType] {
        get { self[StorybookControlsKey.self] }
        set { self[StorybookControlsKey.self] = newValue }
    }
    
    var isEmbeddedInControls: Bool {
        get { self[StorybookControlsEmbedEnvKey.self] }
        set { self[StorybookControlsEmbedEnvKey.self] = newValue }
    }
    
    var isEmbeddedInStorybookContext: Bool {
        get { self[StorybookContextEmbedKey.self] }
        set { self[StorybookContextEmbedKey.self] = newValue }
    }
}
