#if os(iOS)
import XCTest
import SwiftUI
@testable import Storybook

@available(iOS 13.0, *)
final class StorybookCollectionDataTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_addEntry_IgnoresLeadingTrailingSlash() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "root/path1",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/root/path1",
            views: [
                Text("Foo").storybookTitle("Preview 3")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 4"),
            ],
            tags: Set()
        )
        let destination = sut.root["root"]?.children["path1"]
        XCTAssertEqual(destination?.views.count, 4)
    }
    
    func test_addEntry_EmptyString_AddsToDefaultFolder() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/",
            views: [ Text("Foo").storybookTitle("Preview 1") ],
            tags: Set()
        )
        sut.addEntry(
            folder: "",
            views: [ Text("Foo").storybookTitle("Preview 2") ],
            tags: Set()
        )
        sut.addEntry(
            folder: " ",
            views: [ Text("Foo").storybookTitle("Preview 3") ],
            tags: Set()
        )
        let views = sut.root["* Uncategorized"]?.views
        XCTAssertEqual(views?.count, 3)
    }

    func test_addEntry_SingleLevel_Unique() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 2)
    }
    
    func test_addEntry_SingleLevel_Duplicate() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/root/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ],
            tags: Set()
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 4)
    }
    
    func test_addEntry_MutliLevel_Directory_SingleEntry() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/path1/path2/",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 0)
        let path1 = root?.children["path1"]
        XCTAssertEqual(path1?.views.count, 0)
        let path2 = path1?.children["path2"]
        XCTAssertEqual(path2?.views.count, 2)
    }
    
    func test_addEntry_MutliLevel_Directory_MultiEntry() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/path1/path2/",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/root/path1/path2/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ],
            tags: Set()
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 0)
        let path1 = root?.children["path1"]
        XCTAssertEqual(path1?.views.count, 0)
        let path2 = path1?.children["path2"]
        XCTAssertEqual(path2?.views.count, 4)
    }
    
    func test_addEntry_MidLevel_SingleEntry() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/path1/path2/",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Foo").storybookTitle("Preview 2")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ],
            tags: Set()
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 0)
        let path1 = root?.children["path1"]
        XCTAssertEqual(path1?.views.count, 2)
        let path2 = path1?.children["path2"]
        XCTAssertEqual(path2?.views.count, 2)
    }
    
    // MARK: - Tag Tests

    func test_addEntry_ParentTagsMergeWithViewTags() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/path1",
            views: [
                Text("Foo")
                    .storybookTitle("Preview 1")
                    .storybookTags("view-tag-1", "view-tag-2"),
                Text("Bar")
                    .storybookTitle("Preview 2")
                    .storybookTags("view-tag-3")
            ],
            tags: Set(["parent-tag-1", "parent-tag-2"])
        )
        let entry = sut.root["root"]?.children["path1"]
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.views.count, 2)

        // Check that first view has both parent and view tags
        let view1 = entry?.views[0]
        XCTAssertTrue(view1?.tags.contains("parent-tag-1") ?? false)
        XCTAssertTrue(view1?.tags.contains("parent-tag-2") ?? false)
        XCTAssertTrue(view1?.tags.contains("view-tag-1") ?? false)
        XCTAssertTrue(view1?.tags.contains("view-tag-2") ?? false)

        // Check that second view has both parent and view tags
        let view2 = entry?.views[1]
        XCTAssertTrue(view2?.tags.contains("parent-tag-1") ?? false)
        XCTAssertTrue(view2?.tags.contains("parent-tag-2") ?? false)
        XCTAssertTrue(view2?.tags.contains("view-tag-3") ?? false)
    }

    func test_addEntry_ViewsWithoutTags_ReceiveOnlyParentTags() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/root/components",
            views: [
                Text("Foo").storybookTitle("Preview 1"),
                Text("Bar").storybookTitle("Preview 2")
            ],
            tags: Set(["parent-tag"])
        )
        let entry = sut.root["root"]?.children["components"]
        XCTAssertNotNil(entry)

        let view1 = entry?.views[0]
        XCTAssertEqual(view1?.tags.count, 1)
        XCTAssertTrue(view1?.tags.contains("parent-tag") ?? false)

        let view2 = entry?.views[1]
        XCTAssertEqual(view2?.tags.count, 1)
        XCTAssertTrue(view2?.tags.contains("parent-tag") ?? false)
    }

    // MARK: - Search Tests

    func test_search_NoTags_ReturnsBothFoldersAndComponents() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/Design System/Buttons",
            views: [
                Text("Foo").storybookTitle("Primary Button"),
                Text("Bar").storybookTitle("Secondary Button")
            ],
            tags: Set(["button"])
        )
        sut.addEntry(
            folder: "/Design System/Cards",
            views: [
                Text("Baz").storybookTitle("Card Component")
            ],
            tags: Set(["card"])
        )

        let expectation = XCTestExpectation(description: "Search completes")
        sut.search("Button") { results in
            // Should return both folder entries and component entries
            // Results should include:
            // - "Buttons" folder entry
            // - "Primary Button" component
            // - "Secondary Button" component
            XCTAssertGreaterThan(results.count, 0)

            // Check that we have results with "Button" in the title
            let hasButtonResults = results.contains { entry in
                entry.title.contains("Button")
            }
            XCTAssertTrue(hasButtonResults)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_search_WithSingleTag_ReturnsOnlyMatchingComponents() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/Components/Buttons",
            views: [
                Text("Foo").storybookTitle("Primary Button"),
                Text("Bar").storybookTitle("Secondary Button")
            ],
            tags: Set(["button", "interactive"])
        )
        sut.addEntry(
            folder: "/Components/Cards",
            views: [
                Text("Baz").storybookTitle("Card Component")
            ],
            tags: Set(["card", "container"])
        )

        let expectation = XCTestExpectation(description: "Search completes")
        sut.search("#button") { results in
            // Should return only component entries (no folders) that have "button" tag
            XCTAssertEqual(results.count, 2)

            // All results should be non-folder entries
            let allAreComponents = results.allSatisfy { !$0.isFolder }
            XCTAssertTrue(allAreComponents)

            // All results should have the "button" tag
            let allHaveButtonTag = results.allSatisfy { entry in
                entry.tags.contains("button")
            }
            XCTAssertTrue(allHaveButtonTag)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_search_WithMultipleTags_ReturnsComponentsMatchingAnyTag() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/Components/Buttons",
            views: [
                Text("Foo").storybookTitle("Primary Button")
            ],
            tags: Set(["button", "primary"])
        )
        sut.addEntry(
            folder: "/Components/Links",
            views: [
                Text("Bar").storybookTitle("Text Link")
            ],
            tags: Set(["link", "interactive"])
        )
        sut.addEntry(
            folder: "/Components/Cards",
            views: [
                Text("Baz").storybookTitle("Card Component")
            ],
            tags: Set(["card"])
        )

        let expectation = XCTestExpectation(description: "Search completes")
        sut.search("#button,#link") { results in
            // Should return components that match either "button" OR "link" tag
            XCTAssertEqual(results.count, 2)

            // All results should be non-folder entries
            let allAreComponents = results.allSatisfy { !$0.isFolder }
            XCTAssertTrue(allAreComponents)

            // Should have button component and link component, but not card
            let titles = results.map { $0.title }
            XCTAssertTrue(titles.contains("Primary Button"))
            XCTAssertTrue(titles.contains("Text Link"))
            XCTAssertFalse(titles.contains("Card Component"))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_search_WithHashOnly_ReturnsAllComponentsWithTags() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/Components/Tagged",
            views: [
                Text("Foo").storybookTitle("Tagged Component")
            ],
            tags: Set(["some-tag"])
        )
        sut.addEntry(
            folder: "/Components/Untagged",
            views: [
                Text("Bar").storybookTitle("Untagged Component")
            ],
            tags: Set()
        )

        let expectation = XCTestExpectation(description: "Search completes")
        sut.search("#") { results in
            // Should return only components that have any tags
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.title, "Tagged Component")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func test_search_EmptyKeyword_ReturnsRootEntries() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/Root1/Child",
            views: [
                Text("Foo").storybookTitle("Component 1")
            ],
            tags: Set()
        )
        sut.addEntry(
            folder: "/Root2/Child",
            views: [
                Text("Bar").storybookTitle("Component 2")
            ],
            tags: Set()
        )

        let expectation = XCTestExpectation(description: "Search completes")
        sut.search("") { results in
            // Should return only root level entries
            XCTAssertEqual(results.count, 2)

            let titles = results.map { $0.title }.sorted()
            XCTAssertEqual(titles, ["Root1", "Root2"])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // Took this functionality out but might add it back
//    func test_addEntry_AddsFileToLeafNode() throws {
//        let sut = StorybookCollectionData()
//        sut.addEntry(
//            folder: "/root/path1/path2/",
//            views: [
//                Text("Foo").storybookTitle("Preview 1"),
//                Text("Foo").storybookTitle("Preview 2")
//            ],
//            file: "SomeFile.swift"
//        )
//        sut.addEntry(
//            folder: "/root/path1/",
//            views: [
//                Text("Foo").storybookTitle("Preview 3"),
//                Text("Foo").storybookTitle("Preview 4")
//            ],
//            file: "SomeOtherFile.swift"
//        )
//        let root = sut.root["root"]
//        XCTAssertEqual(root?.views.count, 0)
//        let path1 = root?.children["path1"]
//        XCTAssertEqual(path1?.file, "SomeOtherFile.swift")
//        let path2 = path1?.children["path2"]
//        XCTAssertEqual(path2?.file, "SomeFile.swift")
//    }

}
#endif
