//
//  RealmMigration.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/19/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMigration {
    func performRealmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    self.migrateToV1(migration)
                }
            }
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    private func migrateToV1(migration: Migration) {
        migration.enumerate(RealmBuddy.className()) { oldObject, newObject in
            if let contactId = oldObject!["contactId"] as! Int? {
                newObject!["contactId"] = "\(contactId)"
            }
        }
    }
}