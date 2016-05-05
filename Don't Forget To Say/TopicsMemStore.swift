//
//  TopicsMemStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

class TopicsMemStore: TopicsStoreProtocol {
    // MARK: - Data
    
    private var topics = [
        Topic(id: 1, text: "VIPER is bad"),
        Topic(id: 2, text: "MVP is better"),
        Topic(id: 3, text: "Dagger and Typhoon are brothers forever")
    ]
    
    private var relations = [
        TopicRelation(id: 1, topicId: 1, buddyId: 1),
        TopicRelation(id: 2, topicId: 3, buddyId: 1),
        TopicRelation(id: 3, topicId: 1, buddyId: 2),
        TopicRelation(id: 4, topicId: 2, buddyId: 2)
    ]
    
    // MARK: - CRUD operations - Optional error
    
    func fetchRelations(completionHandler: (relations: [TopicRelation]?, error: CrudStoreError?) -> Void) {
        completionHandler(relations: relations, error: nil)
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
}