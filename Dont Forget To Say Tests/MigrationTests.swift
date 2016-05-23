//
//  MigrationTests.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/20/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Dont_Forget_To_Say

class MigrationTests: RealmTestCase {
    
    // MARK: Utility functions
    
    internal func createRealmForMigration() -> Realm {
        var config = RealmMigration.configuration()
        config.fileURL = copyTestRealmFromResource("default-v0")
        return try! Realm(configuration: config)
    }
    
    // MARK: Test cases
    
    func testV0ToV1Migration() {
        let realm = createRealmForMigration()
        
        let kate = realm.objectForPrimaryKey(RealmBuddy.self, key: 1)!
        XCTAssertEqual(kate.contactId, "1")
        let roman = realm.objectForPrimaryKey(RealmBuddy.self, key: 2)!
        XCTAssertNil(roman.contactId)
    }
}
