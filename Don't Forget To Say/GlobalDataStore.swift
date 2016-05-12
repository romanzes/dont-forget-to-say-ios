//
//  GlobalStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol BuddiesStoreProtocol {
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void)
    func fetchBuddy(id: Int, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
    func addBuddy(name: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void)
}

protocol TopicsStoreProtocol {
    func fetchTopicsForBuddy(buddyId: Int, completionHandler: (topics: [Topic]?, error: CrudStoreError?) -> Void)
    func addTopic(text: String, buddyIds: [Int], completionHandler: (topic: Topic?, error: CrudStoreError?) -> Void)
}

struct GlobalDataStore {
    let buddiesStore: BuddiesStoreProtocol
    let topicsStore: TopicsStoreProtocol
}