//
//  RealmTestCase.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/24/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import XCTest

internal var testDirectoryName = "dont_forget_test"

class RealmTestCase: XCTestCase {
    internal func fileManager() -> NSFileManager {
        return NSFileManager.defaultManager()
    }
    
    internal func testDirectory() -> NSURL {
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectory.URLByAppendingPathComponent(testDirectoryName, isDirectory: true)
    }
    
    internal func createTestDirectory() {
        try! fileManager().createDirectoryAtURL(testDirectory(), withIntermediateDirectories: true, attributes: nil)
    }
    
    internal func deleteTestDirectory() {
        do {
            try fileManager().removeItemAtURL(testDirectory())
        } catch {}
    }
    
    override func setUp() {
        deleteTestDirectory()
        createTestDirectory()
    }
    
    func copyTestRealmFromResource(name: String) -> NSURL {
        let resourceUrl = NSBundle(forClass: RealmTestCase.self).URLForResource(name, withExtension: "realm")!
        let fileUrl = testDirectory().URLByAppendingPathComponent(name + ".realm", isDirectory: false)
        try! fileManager().copyItemAtURL(resourceUrl, toURL: fileUrl)
        return fileUrl
    }
    
    override func tearDown() {
        deleteTestDirectory()
    }
}