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
    class func defineMigrationLogic() {
        let config = configuration()
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    class func configuration() -> Realm.Configuration {
        return Realm.Configuration(
            schemaVersion: 3,
            
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    self.migrateToV1(migration)
                }
                if (oldSchemaVersion < 3) {
                    self.migrateToV3(migration)
                }
            }
        )
    }
    
    class private func migrateToV1(migration: Migration) {
        migration.enumerate(RealmBuddy.className()) { oldObject, newObject in
            if let contactId = oldObject!["contactId"] as? Int {
                newObject!["contactId"] = "\(contactId)"
            }
        }
    }
    
    class private func migrateToV3(migration: Migration) {
        migration.enumerate(RealmBuddy.className()) { oldObject, newObject in
            if let id = oldObject!["id"] as? Int {
                newObject!["id"] = "\(id)"
            }
        }
        migration.enumerate(RealmTopic.className()) { oldObject, newObject in
            if let id = oldObject!["id"] as? Int {
                newObject!["id"] = "\(id)"
            }
        }
    }
}