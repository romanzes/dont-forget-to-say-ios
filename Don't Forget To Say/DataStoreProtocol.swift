//
//  GlobalStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol DataStoreProtocol {
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void)
    func fetchBuddy(id: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
    func addBuddy(name: String, contactId: String?, phones: [Phone], completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
    func deleteBuddy(id: String, completionHandler: (error: CrudStoreError?) -> Void)
    func fetchTopicsForBuddy(buddyId: String, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void)
    func addTopic(text: String, buddyIds: [String], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void)
    func deleteTopic(id: String, completionHandler: (error: CrudStoreError?) -> Void)
    func deleteTopicFromBuddy(buddyId: String, topicId: String, completionHandler: (error: CrudStoreError?) -> Void)
}