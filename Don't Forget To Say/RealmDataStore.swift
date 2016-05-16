//
//  CoreDataStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/12/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDataStore: DataStoreProtocol {
    let realm = try! Realm()
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        let realmBuddies = realm.objects(RealmBuddy)
        let buddies = realmBuddies.map { (realmBuddy) -> Buddy in
            convertBuddy(realmBuddy)
        }
        completionHandler(buddies: buddies, error: nil)
    }
    
    func fetchBuddy(id: Int, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let realmBuddy = realm.objectForPrimaryKey(RealmBuddy.self, key: id)
        if let realmBuddy = realmBuddy {
            let buddy = convertBuddy(realmBuddy)
            completionHandler(buddy: buddy, error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    func addBuddy(name: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let newBuddy = RealmBuddy()
        newBuddy.id = entityPrimaryKey(RealmBuddy)
        newBuddy.name = name
        do {
            try realm.write({
                realm.add(newBuddy)
            })
            completionHandler(buddy: convertBuddy(newBuddy), error: nil)
        } catch {
            completionHandler(buddy: nil, error: CrudStoreError.CannotCreate("Cannot create buddy with name \(name)"))
        }
    }
    
    func deleteBuddy(id: Int, completionHandler: (error: CrudStoreError?) -> Void) {
        do {
            try realm.write {
                // delete buddy
                realm.delete(realm.objectForPrimaryKey(RealmBuddy.self, key: id)!)
                // clean unowned topics
                realm.delete(realm.objects(RealmTopic.self).filter("buddies.@count = 0"))
            }
            completionHandler(error: nil)
        } catch {
            completionHandler(error: CrudStoreError.CannotFetch("Cannot remove buddy with id \(id)"))
        }
    }
    
    func fetchTopicsForBuddy(buddyId: Int, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        let realmBuddy = realm.objectForPrimaryKey(RealmBuddy.self, key: buddyId)
        if let realmBuddy = realmBuddy {
            let topics = realmBuddy.topics.map({ (realmTopic) -> Topic in
                convertTopic(realmTopic)
            })
            completionHandler(topics: topics, error: nil)
        } else {
            completionHandler(topics: nil, error: CrudStoreError.CannotFetch("Cannot fetch topics for id \(buddyId)"))
        }
    }
    
    func addTopic(text: String, buddyIds: [Int], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        do {
            try realm.write({
                let newTopic = RealmTopic()
                newTopic.id = entityPrimaryKey(RealmTopic)
                newTopic.text = text
                buddyIds.forEach { (buddyId) in
                    if let buddy = realm.objectForPrimaryKey(RealmBuddy.self, key: buddyId) {
                        buddy.topics.append(newTopic)
                    }
                }
                realm.add(newTopic)
                completionHandler(topic: convertTopic(newTopic), error: nil)
            })
        } catch {
            completionHandler(topic: nil, error: CrudStoreError.CannotFetch("Cannot create topic with text \(text)"))
        }
    }
    
    private func entityPrimaryKey(type: Object.Type) -> Int {
        var result = 1
        if let last = realm.objects(type).sorted("id").last {
            result = last.valueForKey("id") as! Int + 1
        }
        return result
    }
    
    private func convertBuddy(buddy: RealmBuddy) -> Buddy {
        return Buddy(id: buddy.id, name: buddy.name)
    }
    
    private func convertTopic(topic: RealmTopic) -> Topic {
        return Topic(id: topic.id, text: topic.text)
    }
}