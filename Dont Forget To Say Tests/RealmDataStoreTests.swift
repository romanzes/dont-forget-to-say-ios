//
//  RealmDataStoreTests.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/24/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Dont_Forget_To_Say

class RealmDataStoreTests: RealmTestCase {
    
    // MARK: Test cases
    
    func testDefaultRealm() {
        let realm = try! Realm(fileURL: copyTestRealmFromResource("default-v0"))
        
        let kate = realm.objectForPrimaryKey(RealmBuddy.self, key: 1)!
        XCTAssertEqual(kate.contactId.value, 1)
        let roman = realm.objectForPrimaryKey(RealmBuddy.self, key: 2)!
        XCTAssertNil(roman.contactId.value)
    }
}
