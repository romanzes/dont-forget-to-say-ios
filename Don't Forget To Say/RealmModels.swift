//
//  RealmModels.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/13/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift

/* v0
public class RealmBuddy: Object {
    dynamic var id = 0
    let contactId = RealmOptional<Int>()
    dynamic var name = ""
    let topics = List<RealmTopic>()

    override static func primaryKey() -> String? {
        return "id"
    }
}*/

/* v1
public class RealmBuddy: Object {
    dynamic var id = 0
    dynamic var contactId: String? = nil
    dynamic var name = ""
    let topics = List<RealmTopic>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}*/

/* v2
public class RealmBuddy: Object {
    dynamic var id = 0
    dynamic var contactId: String? = nil
    dynamic var name = ""
    let phones = List<RealmPhone>()
    let topics = List<RealmTopic>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}*/

// v3
public class RealmBuddy: Object {
    dynamic var id = ""
    dynamic var contactId: String? = nil
    dynamic var name = ""
    let phones = List<RealmPhone>()
    let topics = List<RealmTopic>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

/* v0
public class RealmTopic: Object {
    dynamic var id = 0
    dynamic var text = ""
    let buddies = LinkingObjects(fromType: RealmBuddy.self, property: "topics")
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}*/

// v3
public class RealmTopic: Object {
    dynamic var id = ""
    dynamic var text = ""
    let buddies = LinkingObjects(fromType: RealmBuddy.self, property: "topics")
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}

// v2
public class RealmPhone: Object {
    dynamic var title: String? = nil
    dynamic var number = ""
    
    convenience init(title: String?, number: String) {
        self.init()
        self.title = title
        self.number = number
    }
}