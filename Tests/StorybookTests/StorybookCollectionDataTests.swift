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
            ]
        )
        sut.addEntry(
            folder: "/root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 2")
            ]
        )
        sut.addEntry(
            folder: "/root/path1",
            views: [
                Text("Foo").storybookTitle("Preview 3")
            ]
        )
        sut.addEntry(
            folder: "root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 4"),
            ]
        )
        let destination = sut.root["root"]?.children["path1"]
        XCTAssertEqual(destination?.views.count, 4)
    }
    
    func test_addEntry_EmptyString_AddsToDefaultFolder() throws {
        let sut = StorybookCollectionData()
        sut.addEntry(
            folder: "/",
            views: [ Text("Foo").storybookTitle("Preview 1") ]
        )
        sut.addEntry(
            folder: "",
            views: [ Text("Foo").storybookTitle("Preview 2") ]
        )
        sut.addEntry(
            folder: " ",
            views: [ Text("Foo").storybookTitle("Preview 3") ]
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
            ]
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
            ]
        )
        sut.addEntry(
            folder: "/root/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ]
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
            ]
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
            ]
        )
        sut.addEntry(
            folder: "/root/path1/path2/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ]
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
            ]
        )
        sut.addEntry(
            folder: "/root/path1/",
            views: [
                Text("Foo").storybookTitle("Preview 3"),
                Text("Foo").storybookTitle("Preview 4")
            ]
        )
        let root = sut.root["root"]
        XCTAssertEqual(root?.views.count, 0)
        let path1 = root?.children["path1"]
        XCTAssertEqual(path1?.views.count, 2)
        let path2 = path1?.children["path2"]
        XCTAssertEqual(path2?.views.count, 2)
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
