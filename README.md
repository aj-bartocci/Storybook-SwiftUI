# Storybook for iOS

This package is a micro framework for rendering previews of components in a Storybook like fashion. It takes advantage of objc runtime and SwiftUI to make using it as seamless as possible. You do not need to be using SwiftUI in your app to use this, UIKit apps can also take advantage of this framework ([UIKit helper library](https://github.com/aj-bartocci/SwiftUIPreviewHelpers)).

Version 2.0.0 is now ready. This brings some major new features and quality of life improments. These include:

- Preview controls. Previews now come with an overlay for controls that interact with the previews. Built in controls include a dark mode toggle, dynamic font sizing, and adjusting the preview screen size. You can add your own custom controls as well.
- New folder based system for organizing previews. When building out a lot of components it was difficult to keep things organized with the old system. You can now specify folder paths (path/to/some/component) in order to easily organize where the previews live in the Storybook UI.
- **Removing the DEBUG restriction.** It has been handy to be able to ship Storybook with non production builds so designers can spot check individual components without needing to navigate into certain situations within a live app. It is now your responsibility to wrap Storybook related code in whatever macro you choose so that will prevent it from going to production.

## Project Requirements 
- Swift 5+
- iOS 10+
- macOS 11+
- Xcode 11+

## Demo Project
A demo project that targets iOS 11 can be found [here](https://github.com/aj-bartocci/Storybook-iOS-Demo).

Demo Videos: 

V2: 

https://github.com/aj-bartocci/Storybook-iOS-Demo/assets/16612478/65db4be6-d074-40bf-a608-0a6a8cd80a1d

V1: 

https://user-images.githubusercontent.com/16612478/185280246-6512760d-1f80-4b46-9a66-e215e3f5f3eb.mp4


## Goals

- Not intrusive 
    - The previews use objc runtime to dynamically pull in views to render. This means you don't need to change your existing code, simply add a @objc static vars onto the Storybook class to see it render. This means each component file can extend the Storybook class to add components. 
- No building
    - The StorybookCollection is simply a SwiftUI view so you can throw it in a PreviewProvider and browse through your app views without having to build the app.
- Backwards compatible
    - You don't need to be using SwiftUI in your production app. Simply mark the previews with @available and you are good to go.

## Roadmap

✅ Configurable components
- To be more like storyboard there should be the ability to configure components on the fly. I.e. setting text values, number values, etc. One possible way could be through reflection.

✅ Be able to ship storybook with staging builds for designers to view alongside the app. Current work for this happening on the experimental branch.
- This means storybook is no longer behind a DEBUG flag, it is up to you to make sure it does not ship with your production code

🔲 Visual regression testing with snapshots like storybook js: https://storybook.js.org/tutorials/intro-to-storybook/react/en/test/

🔲 TBD...

## Upgrading from version 1.x.x to 2.0.0
Version 2.0 has been released with many improvements, however in doing so some of the exisitng functionality may no longer work the same. 
1. MacOS must be 11+, previously it was recommended but still worked back to 10.15. There is now a hard requirement to be 11+
2. StorybookPage was updated to use a folder system. The old initializers still exist but are deprecated. Without updating the UI will not look as optimal but will still funciton 

## Recommended Setup

Create a file called `Storybook` and add a preview provider to it to render the `StorybookCollection`

Note you will need to use `@available(iOS 13, *)` if your app's minimum version is less than iOS 13. The previews will still render and you will not get any compile errors. If you are targeting iOS 13+ you don't need to put the `@available(iOS 13, *)`.

```swift
// Storybook.swift

#if DEBUG

import Storybook
import SwiftUI

@available(iOS 13, *)
struct StorybookPreview: PreviewProvider {
    
    static var previews: some View {
        Storybook.render()
    }
}

#endif 

```

In order to add pages to the storybook simply create extensions on the `Storybook` class with the views you want to render. It is recommended to add these extensions in the files that the components live. This will make it easier to find where you components live when browsing the storybook and if you delete a component file completely it will automatically be removed from the storybook. 

__Important:__ The static properties must be marked with @objc in order to be found and rendered by Storybook.

```swift 
// SomeView.swift 

#if DEBUG

import Storybook

@available(iOS 13.0, *)
extension Storybook {
    @objc static let someView = StorybookPage(
        folder: "/Design System/Views/Some View",
        views: [
            SomeView().storybookTitle("Primary")
            SomeView().storybookTitle("Secondary")
        ]
    )
}

#endif
```

## Controls
With version 2.0.0+ you can render a control panel within the storybook that can modify the current View being looked at. Controls are powered by the `StorybookControlType` enum which allows you to use prebuilt controls or your own custom ones.

In order to take advantage of controls you must add them to your Storybook context. Since storybook takes advantage of SwiftUI's Environment this means that you can apply controls to individual Views or cascade to every view within Storybook. By default Storybook will wrap all views in a control context that picks up controls from the environment so that you do not need to specify the same controls over and over again. 

```swift
func storybookSetGlobalControls(_ controls: StorybookControlType...) -> some View
```

To apply controls to all views within Storybook set the global controls at the root. In this example controls for colorScheme, dynamicType, screenSize, and a custom control will be applied to all views. 

```swift 
Storybook.render()
    .storybookSetGlobalControls(
        .colorScheme,
        .dynamicType,
        .screenSize,
        .custom(StorybookControl(id: "MyCustomControl", view: {
            CustomControl()
        }))
    )
```

To add individual controls to views you can use another function for adding controls to the context. The following will add a jira documentation link to the control menu for this specific view. 

```swift
extension Storybook {
    @objc static let someView = StorybookPage(
        folder: "/Design System/Views/Some View",
        view: SomeView()
            .storybookAddControls(
                .documentationLink(
                    title: "Jira", 
                    url: "https://jira.com/123", 
                    icon: .jira
                )
            )
            .storybookTitle("Primary")
    )
}
```

### Example custom Control
Custom controls can easily be added to the Storybook control overlay. Here is an example of a control to change the title of a view. 

```swift
// The View used in the App
@available(iOS 13.0, *)
struct SomeView: View {
    let title: String
    
    var body: some View {
        Text(title)
    }
}

// A wrapper around SomeView to control it
@available(iOS 13.0, *)
struct ControlledSomeView: View {
    @State var title = "Hello, World!"
    
    var body: some View {
        SomeView(title: title)
            .storybookAddControls(
                .custom(StorybookControl(
                    id: "SomeViewControl",
                    view: {
                        TextField("Title", text: $title)
                    }
                ))
            )
    }
}

@available(iOS 13.0, *)
extension Storybook {
    @objc static let someView = StorybookPage(
        folder: "/Views",
        view: ControlledSomeView().storybookTitle("Some View")
    )
}
```

## Models 

__Storybook__

The `Storybook` class uses objc runtime to mirror it's static properties that are of the type `StorybookPage` and generate previews for them. In order to add previews to the storybook create an extension on `Storybook` with a static property pointing to a `StorybookPage`. 

__StorybookPage__

The `StorybookPage` class is used to render content you want to appear in the `StorybookCollection`. 

```swift
public init(
    folder directory: String,
    view: StoryBookView,
    file: String = #file
)
```
```swift
public init(
    folder directory: String,
    views: [StoryBookView],
    file: String = #file
)
```

There are 2 initializers for creating a page. The title and file arguments are used when rendering the list of Storybook pages. Sometimes the name of a component in code doesn't accurately describe what it is. So the title can be a more human readable description of the component, while the file tells you where that component is located in code. The file has a default argument which will take the file of wherever the intializer is called from, or you can supply the file manually if you choose (not recommended). 

__StorybookView__

The `StoryBookView` struct is a SwiftUI wrapper view used for rendering the views within a `StorybookPage`. You supply a title and view to be rendered. 

View has an extension that wraps itself inside `StorybookView` for a cleaner API.

```swift
func storybookTitle(_ title: String, file: String = #file) -> StoryBookView

// Usage 

SomeView().storybookTitle("My View")
```

__StorybookCollection__

The `StorybookCollection` struct is a SwiftUI view that renders all of the Storybook pages. This should be used in a PreviewProvider so that you can easily browse without having to run anything. 

A convience function on Storybook called render, makes it a little easier to remember how to render things. 

```swift
Storybook.render() is the same as StorybookCollection()
```


