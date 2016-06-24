//
//  CouchbaseModels.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 6/20/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

@objc(CouchbaseBuddy)
class CouchbaseBuddy: CBLModel {
    @NSManaged var name: String
    @NSManaged var contactId: String?
    @NSManaged var phones: [CouchbasePhone]
    @NSManaged var topics: [CouchbaseTopic]
    
    override func awakeFromInitializer() {
        type = "buddy"
    }
    
    class func phonesItemClass() -> AnyClass {
        return CouchbasePhone.self
    }
    
    class func topicsItemClass() -> AnyClass {
        return CouchbaseTopic.self
    }
}

@objc(CouchbaseTopic)
class CouchbaseTopic: CBLModel {
    @NSManaged var text: String
    @NSManaged var buddies: [CouchbaseBuddy]
    
    override func awakeFromInitializer() {
        type = "topic"
    }
    
    class func buddiesItemClass() -> AnyClass {
        return CouchbaseBuddy.self
    }
}

@objc(CouchbasePhone)
public class CouchbasePhone: NSObject, CBLJSONEncoding {
    var title: String?
    var number: String
    
    init(title: String?, number: String) {
        self.title = title
        self.number = number
    }
    
    public required init?(JSON jsonObject: AnyObject) {
        let dictionary = jsonObject as! [String: AnyObject]
        self.title = dictionary["title"] as? String
        self.number = dictionary["number"] as! String
    }
    
    public func encodeAsJSON() -> AnyObject {
        var dict = [String: AnyObject]()
        if let title = title {
            dict["title"] = title
        }
        dict["number"] = number
        return dict
    }
}