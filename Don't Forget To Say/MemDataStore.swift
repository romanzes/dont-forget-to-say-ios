//
//  TopicsMemStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

private struct TopicRelation {
    let id: Int
    let topicId: Int
    let buddyId: Int
}

class MemDataStore: DataStoreProtocol {
    // MARK: - Data
    
    private var freeBuddyId = 8
    private var freeTopicId = 4
    private var freeRelationId = 5
    
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
        TopicRelation(id: 1, topicId: 1, buddyId: 1),
        TopicRelation(id: 2, topicId: 3, buddyId: 1),
        TopicRelation(id: 3, topicId: 1, buddyId: 2),
        TopicRelation(id: 4, topicId: 2, buddyId: 2)
    ]
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        completionHandler(buddies: buddies, error: nil)
    }
    
    func fetchBuddy(id: Int, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let buddy = buddies.filter { (buddy: Buddy) -> Bool in
            return buddy.id == id
            }.first
        if let _ = buddy {
            completionHandler(buddy: buddy, error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    func addBuddy(name: String, contactId: Int?, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let newBuddy = Buddy(id: freeBuddyId, contactId: contactId, name: name)
        buddies += [newBuddy]
        freeBuddyId += 1
        completionHandler(buddy: newBuddy, error: nil)
    }
    
    func deleteBuddy(id: Int, completionHandler: (error: CrudStoreError?) -> Void) {
        relations = relations.filter({ (relation) -> Bool in
            relation.buddyId != id
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
    
    func fetchTopicsForBuddy(buddyId: Int, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void) {
        let relations = self.relations.filter { (relation) -> Bool in
            return relation.buddyId == buddyId
        }
        let topics = relations.map { (relation) -> Topic in
            let index = self.topics.indexOf({ (topic) -> Bool in
                return topic.id == relation.topicId
            })
            return self.topics[index!]
        }
        completionHandler(topics: topics, error: nil)
    }
    
    func addTopic(text: String, buddyIds: [Int], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void) {
        let newTopic = Topic(id: freeTopicId, text: text, buddyCount: buddyIds.count)
        topics += [newTopic]
        freeTopicId += 1
        buddyIds.forEach { (buddyId) in
            addRelation(buddyId, topicId: newTopic.id)
        }
        completionHandler(topic: newTopic, error: nil)
    }
    
    func deleteTopic(id: Int, completionHandler: (error: CrudStoreError?) -> Void) {
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
    
    func deleteTopicFromBuddy(buddyId: Int, topicId: Int, completionHandler: (error: CrudStoreError?) -> Void) {
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
    
    private func addRelation(buddyId: Int, topicId: Int) {
        let newRelation = TopicRelation(id: freeRelationId, topicId: topicId, buddyId: buddyId)
        relations += [newRelation]
        freeRelationId += 1
    }
    
    private func decreaseBuddyCountForTopic(topicId: Int) {
        if let index = (topics.indexOf { (topic) -> Bool in
            topic.id == topicId
        }) {
            let topic = topics[index]
            topics[index] = Topic(id: topic.id, text: topic.text, buddyCount: topic.buddyCount - 1)
        }
    }
}