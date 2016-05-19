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
    func fetchBuddy(id: Int, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
    func addBuddy(name: String, contactId: String?, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
    func deleteBuddy(id: Int, completionHandler: (error: CrudStoreError?) -> Void)
    func fetchTopicsForBuddy(buddyId: Int, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void)
    func addTopic(text: String, buddyIds: [Int], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void)
    func deleteTopic(id: Int, completionHandler: (error: CrudStoreError?) -> Void)
    func deleteTopicFromBuddy(buddyId: Int, topicId: Int, completionHandler: (error: CrudStoreError?) -> Void)
}