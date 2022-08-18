# Storybook for iOS

This package is a micro framework for rendering previews of components in a Storybook like fashion. It takes advantage of objc runtime and SwiftUI to make using it as seamless as possible. You do not need to be using SwiftUI in your app to use this, UIKit apps can also take advantage of this framework ([UIKit helper library](https://github.com/aj-bartocci/SwiftUIPreviewHelpers)). 

This is a work in progress.

## Project Requirements 
- Swift 5+
- iOS 10+
- macOS 10.15+ (might be able to go lower)
- Xcode 11+

## Demo Project
A demo project that targets iOS 11 can be found [here](https://github.com/aj-bartocci/Storybook-iOS-Demo).

Demo Video: 

https://user-images.githubusercontent.com/16612478/185280246-6512760d-1f80-4b46-9a66-e215e3f5f3eb.mp4


## Goals

- Not intrusive 
    - The previews use objc runtime to dynamically pull in views to render. This means you don't need to change your existing code, simply add a @objc static vars onto the Storybook class to see it render. This means each component file can extend the Storybook class to add components. 
- No building
    - The StorybookCollection is simply a SwiftUI view so you can throw it in a PreviewProvider and browse through your app views without having to build the app.
- Debug Only
    - All code is wrapped in the DEBUG macro so it will not ship with your production code.
- Backwards compatible
    - You don't need to be using SwiftUI in your production app. Simply mark the previews with @available and you are good to go.

## Roadmap

- Configurable components
    - To be more like storyboard there should be the ability to configure components on the fly. I.e. setting text values, number values, etc. One possible way could be through reflection.
- Be able to ship storybook with staging builds for designers to view alongside the app. Current work for this happening on the experimental branch.
- TBD

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
        StorybookCollection()
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
    @objc static let someView = StorybookPage(title: "Text View", view: SomeView())
}

#endif
```

## Models 

__Storybook__

The `Storybook` class uses objc runtime to mirror it's static properties that are of the type `StorybookPage` and generate previews for them. In order to add previews to the storybook create an extension on `Storybook` with a static property pointing to a `StorybookPage`. 

__StorybookPage__

The `StorybookPage` class is used to render content you want to appear in the `StorybookCollection`. 

```swift
public convenience init<T: View>(
    title: String,
    view: T,
    file: String = #file
)
```
```swift
public init(
    title: String,
    views: [StoryBookView],
    file: String = #file
)
```

There are 2 initializers for creating a page. The title and file arguments are used when rendering the list of Storybook pages. Sometimes the name of a component in code doesn't accurately describe what it is. So the title can be a more human readable description of the component, while the file tells you where that component is located in code. The file has a default argument which will take the file of wherever the intializer is called from, or you can supply the file manually if you choose (not recommended). 

__StoryBookView__

The `StoryBookView` struct is a SwiftUI wrapper view used for rendering the views within a `StorybookPage`. You supply a title and view to be rendered. 

__StorybookCollection__

The `StorybookCollection` struct is a SwiftUI view that renders all of the Storybook pages. This should be used in a PreviewProvider so that you can easily browse without having to run anything. 


