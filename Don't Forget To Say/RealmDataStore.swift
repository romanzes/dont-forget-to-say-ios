//
//  CoreDataStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/12/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift
import Async

class RealmDataStore: DataStoreProtocol {
    private let realmProvider: RealmProvider
    
    init(realmProvider: RealmProvider) {
        self.realmProvider = realmProvider
    }
    
    // MARK: Protocol methods
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        Async.background {
            self.fetchBuddiesImpl(completionHandler)
        }
    }
    
    func fetchBuddy(id: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        Async.background {
            self.fetchBuddyImpl(id, completionHandler)
        }
    }
    
    func addBuddy(name: String, contactId: String?, phones: [Phone], completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        Async.background {
            self.addBuddyImpl(name, contactId, phones, completionHandler)
        }
    }
    
    func deleteBuddy(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background {
            self.deleteBuddyImpl(id, completionHandler)
        }
    }
    
    func fetchTopicsForBuddy(buddyId: String, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        Async.background {
            self.fetchTopicsForBuddyImpl(buddyId, completionHandler)
        }
    }
    
    func addTopic(text: String, buddyIds: [String], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        Async.background {
            self.addTopicImpl(text, buddyIds, completionHandler)
        }
    }
    
    func deleteTopic(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background {
            self.deleteTopicImpl(id, completionHandler)
        }
    }
    
    func deleteTopicFromBuddy(buddyId: String, topicId: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background {
            self.deleteTopicFromBuddyImpl(buddyId, topicId, completionHandler)
        }
    }
    
    // MARK: implementation
    
    private func fetchBuddiesImpl(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        let realmBuddies = realm().objects(RealmBuddy)
        let buddies = realmBuddies.map { (realmBuddy) -> Buddy in
            convertBuddy(realmBuddy)
        }
        completionHandler(buddies: buddies, error: nil)
    }
    
    private func fetchBuddyImpl(id: String, _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let realmBuddy = realm().objectForPrimaryKey(RealmBuddy.self, key: id)
        if let realmBuddy = realmBuddy {
            let buddy = convertBuddy(realmBuddy)
            completionHandler(buddy: buddy, error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    private func addBuddyImpl(name: String, _ contactId: String?, _ phones: [Phone], _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let realmInstance = realm()
        let newBuddy = RealmBuddy()
        newBuddy.id = entityPrimaryKey(realmInstance, type: RealmBuddy.self)
        newBuddy.contactId = contactId
        newBuddy.name = name
        phones.forEach { (phone) in newBuddy.phones.append(RealmPhone(title: phone.title, number: phone.number)) }
        do {
            try realmInstance.write({
                realmInstance.add(newBuddy)
            })
            completionHandler(buddy: convertBuddy(newBuddy), error: nil)
        } catch {
            completionHandler(buddy: nil, error: CrudStoreError.CannotCreate("Cannot create buddy with name \(name)"))
        }
    }
    
    private func deleteBuddyImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        do {
            let realmInstance = realm()
            try realmInstance.write {
                // delete buddy
                realmInstance.delete(realmInstance.objectForPrimaryKey(RealmBuddy.self, key: id)!)
                // clean unowned topics
                realmInstance.delete(realmInstance.objects(RealmTopic.self).filter("buddies.@count = 0"))
            }
            completionHandler(error: nil)
        } catch {
            completionHandler(error: CrudStoreError.CannotFetch("Cannot remove buddy with id \(id)"))
        }
    }
    
    private func fetchTopicsForBuddyImpl(buddyId: String, _ completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        let realmBuddy = realm().objectForPrimaryKey(RealmBuddy.self, key: buddyId)
        if let realmBuddy = realmBuddy {
            let topics = realmBuddy.topics.map({ (realmTopic) -> Topic in
                convertTopic(realmTopic)
            })
            completionHandler(topics: topics, error: nil)
        } else {
            completionHandler(topics: nil, error: CrudStoreError.CannotFetch("Cannot fetch topics for id \(buddyId)"))
        }
    }
    
    private func addTopicImpl(text: String, _ buddyIds: [String], _ completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        do {
            let realmInstance = realm()
            try realmInstance.write({
                let newTopic = RealmTopic()
                newTopic.id = entityPrimaryKey(realmInstance, type: RealmTopic.self)
                newTopic.text = text
                buddyIds.forEach { (buddyId) in
                    if let buddy = realmInstance.objectForPrimaryKey(RealmBuddy.self, key: buddyId) {
                        buddy.topics.append(newTopic)
                    }
                }
                realmInstance.add(newTopic)
                completionHandler(topic: convertTopic(newTopic), error: nil)
            })
        } catch {
            completionHandler(topic: nil, error: CrudStoreError.CannotFetch("Cannot create topic with text \(text)"))
        }
    }
    
    private func deleteTopicImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        do {
            let realmInstance = realm()
            try realmInstance.write {
                realmInstance.delete(realmInstance.objectForPrimaryKey(RealmTopic.self, key: id)!)
            }
            completionHandler(error: nil)
        } catch {
            completionHandler(error: CrudStoreError.CannotFetch("Cannot remove topic with id \(id)"))
        }
    }
    
    private func deleteTopicFromBuddyImpl(buddyId: String, _ topicId: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        do {
            let realmInstance = realm()
            try realmInstance.write {
                if let buddy = realmInstance.objectForPrimaryKey(RealmBuddy.self, key: buddyId) {
                    if let index = buddy.topics.indexOf({ (topic) -> Bool in
                        "\(topic.id)" == topicId
                    }) {
                        buddy.topics.removeAtIndex(index)
                        completionHandler(error: nil)
                    } else {
                        completionHandler(error: CrudStoreError.CannotFetch("There no relation between buddy \(buddyId) and topic \(topicId)"))
                    }
                } else {
                    completionHandler(error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(buddyId)"))
                }
            }
        } catch {
            completionHandler(error: CrudStoreError.CannotFetch("Cannot remove relation between buddy \(buddyId) and topic \(topicId)"))
        }
    }
    
    // MARK: Helper functions
    
    private func realm() -> Realm {
        return realmProvider.getRealm()
    }
    
    private func entityPrimaryKey(realm: Realm, type: Object.Type) -> Int {
        var result = 1
        if let last = realm.objects(type).sorted("id").last {
            result = last.valueForKey("id") as! Int + 1
        }
        return result
    }
    
    private func convertBuddy(buddy: RealmBuddy) -> Buddy {
        let phones = buddy.phones.map { (phone) -> Phone in
            Phone(title: phone.title, number: phone.number)
        }
        return Buddy(id: "\(buddy.id)", contactId: buddy.contactId, name: buddy.name, phones: phones)
    }
    
    private func convertTopic(topic: RealmTopic) -> Topic {
        return Topic(id: "\(topic.id)", text: topic.text, buddyCount: topic.buddies.count)
    }
}