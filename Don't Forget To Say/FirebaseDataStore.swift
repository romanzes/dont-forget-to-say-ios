//
//  FirebaseDataStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 6/1/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Async
import Firebase

class FirebaseDataStore: DataStoreProtocol {
    var firebase: FIRDatabaseReference
    
    init() {
        let database = FIRDatabase.database()
        database.persistenceEnabled = true
        firebase = database.reference()
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
        firebase.child("buddies").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            var buddies: [Buddy] = []
            if !(snapshot.value is NSNull) {
                let postDict = snapshot.value as! NSDictionary
                for key in postDict.allKeys {
                    let key = key as! String
                    buddies.append(self.convertBuddy(key, dict: postDict[key] as! NSDictionary))
                }
            }
            completionHandler(buddies: buddies, error: nil)
        }) { error in
            completionHandler(buddies: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddies from firebase"))
        }
    }
    
    private func fetchBuddyImpl(id: String, _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        firebase.child("buddies").child(id).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.value is NSNull {
                completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id) from firebase"))
            } else {
                let postDict = snapshot.value as! NSDictionary
                let buddy = self.convertBuddy(id, dict: postDict)
                completionHandler(buddy: buddy, error: nil)
            }
        }) { error in
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id) from firebase"))
        }
    }
    
    private func addBuddyImpl(name: String, _ contactId: String?, _ phones: [Phone], _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let buddyRef = firebase.child("buddies").childByAutoId()
        let buddyKey = buddyRef.key
        var buddy: [String: AnyObject] = ["name": name]
        if let contactId = contactId {
            buddy["contact"] = contactId
        }
        var phonesArray = [AnyObject]()
        for phone in phones {
            var phoneMap = ["number": phone.number]
            if let phoneTitle = phone.title {
                phoneMap["label"] = phoneTitle
            }
            phonesArray.append(phoneMap)
        }
        buddy["phones"] = phonesArray
        firebase.updateChildValues(["/buddies/\(buddyKey)": buddy])
        completionHandler(buddy: Buddy(id: buddyKey, contactId: contactId, name: name, phones: phones), error: nil)
    }
    
    private func deleteBuddyImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        firebase.child("buddies").child(id).removeValue()
        deleteRelationsForBuddy(id) {
            completionHandler(error: nil)
        }
    }
    
    private func fetchTopicsForBuddyImpl(buddyId: String, _ completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        let block: (snapshot: FIRDataSnapshot) -> Void = { snapshot in
            var topics: [Topic] = []
            if snapshot.value is NSNull {
                completionHandler(topics: topics, error: nil)
            } else {
                let postDict = snapshot.value as! NSDictionary
                var counter = 0
                var processNextTopic: (() -> Void)!
                processNextTopic = {
                    if counter < postDict.allKeys.count {
                        let relation = postDict.allValues[counter]
                        counter += 1
                        guard let topicId = relation["topic"] as? String else {
                            processNextTopic()
                            return
                        }
                        self.fetchTopic(topicId) { (topic, error) in
                            if let topic = topic {
                                topics.append(topic)
                            }
                            processNextTopic()
                        }
                    } else {
                        completionHandler(topics: topics, error: nil)
                    }
                }
                processNextTopic()
            }
        }
        let cancelBlock: (error: NSError) -> Void = { error in
            completionHandler(topics: nil, error: CrudStoreError.CannotFetch("Cannot fetch topics for buddy \(buddyId) from firebase"))
        }
        firebase.child("topic_relations")
            .queryOrderedByChild("buddy")
            .queryEqualToValue(buddyId)
            .observeSingleEventOfType(.Value, withBlock: block, withCancelBlock: cancelBlock)
    }
    
    private func addTopicImpl(text: String, _ buddyIds: [String], _ completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        let topicKey = firebase.child("topics").childByAutoId().key
        let topic = ["text": text]
        firebase.updateChildValues(["/topics/\(topicKey)": topic])
        buddyIds.forEach { (buddyId) in
            let relationKey = firebase.child("topic_relations").childByAutoId().key
            let topicRelation = ["buddy": buddyId, "topic": topicKey]
            firebase.updateChildValues(["/topic_relations/\(relationKey)": topicRelation])
        }
        completionHandler(topic: Topic(id: topicKey, text: text, buddyCount: buddyIds.count), error: nil)
    }
    
    private func deleteTopicImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        firebase.child("topics").child(id).removeValue()
        deleteRelationsForTopic(id) {
            completionHandler(error: nil)
        }
    }
    
    private func deleteTopicFromBuddyImpl(buddyId: String, _ topicId: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        let block: (snapshot: FIRDataSnapshot) -> Void = { snapshot in
            if !(snapshot.value is NSNull) {
                let postDict = snapshot.value as! NSDictionary
                for key in postDict.allKeys {
                    let key = key as! String
                    let relation = postDict.valueForKey(key)!
                    if relation["buddy"] as? String == buddyId {
                        self.firebase.child("topic_relations").child(key).removeValue()
                        completionHandler(error: nil)
                    }
                }
            }
            completionHandler(error: CrudStoreError.CannotDelete("There is no relation between buddy \(buddyId) and topic \(topicId) from firebase"))
        }
        let cancelBlock: (error: NSError) -> Void = { _ in
            completionHandler(error: CrudStoreError.CannotDelete("Can't delete relation between buddy \(buddyId) and topic \(topicId) from firebase"))
        }
        firebase.child("topic_relations")
            .queryOrderedByChild("topic")
            .queryEqualToValue(topicId)
            .observeSingleEventOfType(.Value, withBlock: block, withCancelBlock: cancelBlock)
    }
    
    // MARK: Helper methods
    
    private func convertBuddy(key: String, dict: NSDictionary) -> Buddy {
        let contactId = dict["contact"] as? String
        let name = dict["name"] as! String
        return Buddy(id: key, contactId: contactId, name: name, phones: [])
    }
    
    private func convertTopic(key: String, dict: NSDictionary) -> Topic {
        let text = dict["text"] as! String
        return Topic(id: key, text: text, buddyCount: 0)
    }
    
    private func fetchTopic(id: String, completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        firebase.child("topics").child(id).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if snapshot.value is NSNull {
                completionHandler(topic: nil, error: CrudStoreError.CannotFetch("Cannot fetch topic with id \(id) from firebase"))
            } else {
                let postDict = snapshot.value as! NSDictionary
                let topic = self.convertTopic(id, dict: postDict)
                completionHandler(topic: topic, error: nil)
            }
        }) { error in
            completionHandler(topic: nil, error: CrudStoreError.CannotFetch("Cannot fetch topic with id \(id) from firebase"))
        }
    }
    
    private func deleteRelationsForBuddy(buddyId: String, _ completionHandler: () -> Void) {
        let block: (snapshot: FIRDataSnapshot) -> Void = { snapshot in
            var counter = 0
            var processNextRelation: (() -> Void)!
            processNextRelation = {
                guard counter < Int(snapshot.childrenCount) else {
                    completionHandler()
                    return
                }
                guard let relation = snapshot.children.allObjects[counter] as? FIRDataSnapshot else {
                    completionHandler()
                    return
                }
                counter += 1
                self.deleteRelationAndTopic(relation) {
                    processNextRelation()
                }
            }
            processNextRelation()
        }
        let cancelBlock: (error: NSError) -> Void = { _ in
            completionHandler()
        }
        firebase.child("topic_relations")
            .queryOrderedByChild("buddy")
            .queryEqualToValue(buddyId)
            .observeSingleEventOfType(.Value, withBlock: block, withCancelBlock: cancelBlock)
    }
    
    private func deleteRelationAndTopic(relation: FIRDataSnapshot, _ completionHandler: () -> Void) {
        relation.ref.removeValue()
        guard let dict = relation.value as? NSDictionary else {
            completionHandler()
            return
        }
        guard let topicId = dict["topic"] as? String else {
            completionHandler()
            return
        }
        self.deleteTopicIfUnused(topicId) {
            completionHandler()
        }
    }
    
    private func deleteTopicIfUnused(topicId: String, _ completionHandler: () -> Void) {
        let block: (snapshot: FIRDataSnapshot) -> Void = { snapshot in
            if snapshot.childrenCount == 0 {
                self.firebase.child("topics").child(topicId).removeValue()
            }
            completionHandler()
        }
        let cancelBlock: (error: NSError) -> Void = { error in
            completionHandler()
        }
        firebase.child("topic_relations")
            .queryOrderedByChild("topic")
            .queryEqualToValue(topicId)
            .observeSingleEventOfType(.Value, withBlock: block, withCancelBlock: cancelBlock)
    }
    
    private func deleteRelationsForTopic(topicId: String, _ completionHandler: () -> Void) {
        let block: (snapshot: FIRDataSnapshot) -> Void = { snapshot in
            snapshot.children.forEach({ relation in
                relation.ref.removeValue()
            })
        }
        let cancelBlock: (error: NSError) -> Void = { _ in
            completionHandler()
        }
        firebase.child("topic_relations")
            .queryOrderedByChild("topic")
            .queryEqualToValue(topicId)
            .observeSingleEventOfType(.Value, withBlock: block, withCancelBlock: cancelBlock)
    }
}