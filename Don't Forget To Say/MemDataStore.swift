//
//  TopicsMemStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Async

private struct TopicRelation {
    let topicId: String
    let buddyId: String
    
    init(topicId: Int, buddyId: Int) {
        self.init(topicId: "\(topicId)", buddyId: "\(buddyId)")
    }
    
    init(topicId: String, buddyId: String) {
        self.topicId = topicId
        self.buddyId = buddyId
    }
}

class MemDataStore: DataStoreProtocol {
    // MARK: - Data
    
    private var freeBuddyId = 8
    private var freeTopicId = 4
    
    private var buddies = [
        Buddy(id: 1, name: "Roman Petrenko"),
        Buddy(id: 2, name: "Andrei Senchuk"),
        Buddy(id: 3, name: "Гурбангулы Мяликулиевич Бердымухаммедов"),
        Buddy(id: 4, name: "Yuliya Charkasava"),
        Buddy(id: 5, name: "Mikhail Aksionchyk"),
        Buddy(id: 6, name: "Vladimir Putin"),
        Buddy(id: 7, name: "Barack Obama")
    ]
    
    private var topics = [
        Topic(id: 1, text: "VIPER is bad", buddyCount: 2),
        Topic(id: 2, text: "MVP is better", buddyCount: 1),
        Topic(id: 3, text: "Dagger and Typhoon are brothers forever", buddyCount: 1)
    ]
    
    private var relations = [
        TopicRelation(topicId: 1, buddyId: 1),
        TopicRelation(topicId: 3, buddyId: 1),
        TopicRelation(topicId: 1, buddyId: 2),
        TopicRelation(topicId: 2, buddyId: 2)
    ]
    
    private let simulatedDelay = 1.0
    
    // MARK: Protocol methods
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.fetchBuddiesImpl(completionHandler)
        }
    }
    
    func fetchBuddy(id: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.fetchBuddyImpl(id, completionHandler)
        }
    }
    
    func addBuddy(name: String, contactId: String?, phones: [Phone], completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.addBuddyImpl(name, contactId, phones, completionHandler)
        }
    }
    
    func deleteBuddy(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.deleteBuddyImpl(id, completionHandler)
        }
    }
    
    func fetchTopicsForBuddy(buddyId: String, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.fetchTopicsForBuddyImpl(buddyId, completionHandler)
        }
    }
    
    func addTopic(text: String, buddyIds: [String], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.addTopicImpl(text, buddyIds, completionHandler)
        }
    }
    
    func deleteTopic(id: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.deleteTopicImpl(id, completionHandler)
        }
    }
    
    func deleteTopicFromBuddy(buddyId: String, topicId: String, completionHandler: (error: CrudStoreError?) -> Void) {
        Async.background(after: simulatedDelay) {
            self.deleteTopicFromBuddyImpl(buddyId, topicId, completionHandler)
        }
    }
    
    // MARK: implementation
    
    private func fetchBuddiesImpl(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        completionHandler(buddies: self.buddies, error: nil)
    }
    
    private func fetchBuddyImpl(id: String, _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let buddy = buddies.filter { (buddy: Buddy) -> Bool in
            return buddy.id == id
            }.first
        if let _ = buddy {
            completionHandler(buddy: buddy, error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    private func addBuddyImpl(name: String, _ contactId: String?, _ phones: [Phone], _ completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let newBuddy = Buddy(id: freeBuddyId, contactId: contactId, name: name, phones: phones)
        buddies += [newBuddy]
        freeBuddyId += 1
        completionHandler(buddy: newBuddy, error: nil)
    }
    
    private func deleteBuddyImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        relations = relations.filter({ (relation) -> Bool in
            "\(relation.buddyId)" != id
        })
        let index = buddies.indexOf { (buddy) -> Bool in
            buddy.id == id
        }
        if let index = index {
            buddies.removeAtIndex(index)
            completionHandler(error: nil)
        } else {
            completionHandler(error: CrudStoreError.CannotFetch("Cannot remove buddy with id \(id)"))
        }
    }
    
    private func fetchTopicsForBuddyImpl(buddyId: String, _ completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        let relations = self.relations.filter { (relation) -> Bool in
            return "\(relation.buddyId)" == buddyId
        }
        let topics = relations.map { (relation) -> Topic in
            let index = self.topics.indexOf({ (topic) -> Bool in
                return topic.id == relation.topicId
            })
            return self.topics[index!]
        }
        completionHandler(topics: topics, error: nil)
    }
    
    private func addTopicImpl(text: String, _ buddyIds: [String], _ completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        let newTopic = Topic(id: freeTopicId, text: text, buddyCount: buddyIds.count)
        topics += [newTopic]
        freeTopicId += 1
        buddyIds.forEach { (buddyId) in
            addRelation(buddyId, topicId: newTopic.id)
        }
        completionHandler(topic: newTopic, error: nil)
    }
    
    private func deleteTopicImpl(id: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        relations = self.relations.filter({ (relation) -> Bool in
            return relation.topicId != id
        })
        if let index = (topics.indexOf { (topic) -> Bool in
            return topic.id == id
        }) {
            topics.removeAtIndex(index)
            completionHandler(error: nil)
        } else {
            completionHandler(error: CrudStoreError.CannotDelete("Cannot remove topic with id \(id)"))
        }
    }
    
    private func deleteTopicFromBuddyImpl(buddyId: String, _ topicId: String, _ completionHandler: (error: CrudStoreError?) -> Void) {
        if let index = (relations.indexOf { (relation) -> Bool in
            return relation.buddyId == buddyId && relation.topicId == topicId
        }) {
            relations.removeAtIndex(index)
            decreaseBuddyCountForTopic(topicId)
            completionHandler(error: nil)
        } else {
            completionHandler(error: CrudStoreError.CannotDelete("Cannot remove topic with id \(topicId) for buddy id \(buddyId)"))
        }
    }
    
    // MARK: Helper functions
    
    private func addRelation(buddyId: String, topicId: String) {
        let newRelation = TopicRelation(topicId: topicId, buddyId: buddyId)
        relations += [newRelation]
    }
    
    private func decreaseBuddyCountForTopic(topicId: String) {
        if let index = (topics.indexOf { (topic) -> Bool in
            topic.id == topicId
        }) {
            let topic = topics[index]
            topics[index] = Topic(id: topic.id, text: topic.text, buddyCount: topic.buddyCount - 1)
        }
    }
}