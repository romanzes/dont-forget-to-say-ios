//
//  RealmModels.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/13/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBuddy: Object {
    dynamic var id = 0
    let contactId = RealmOptional<Int>()
    dynamic var name = ""
    let topics = List<RealmTopic>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmTopic: Object {
    dynamic var id = 0
    dynamic var text = ""
    let buddies = LinkingObjects(fromType: RealmBuddy.self, property: "topics")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}