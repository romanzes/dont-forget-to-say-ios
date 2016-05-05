//
//  BuddyListPresenter.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol BuddyListPresenterInterface {
    func obtainBuddies()
}

protocol BuddyListViewInterface {
    func obtainedBuddies(buddies: [BuddyListItemDisplayData])
}

class BuddyListPresenter: BuddyListPresenterInterface {
    // MARK: Injected properties
    var dataStore: GlobalDataStore?
    var userInterface: BuddyListViewInterface?
    
    func obtainBuddies() {
        var fetchedBuddies: [Buddy]?
        let onRelationsFetched = { (relations: [TopicRelation]?, error: CrudStoreError?) in
            if let buddies = fetchedBuddies, relations = relations {
                self.generateDisplayData(buddies, relations: relations)
            }
        }
        let onBuddiesFetched = { (buddies: [Buddy]?, error: CrudStoreError?) in
            fetchedBuddies = buddies
            self.dataStore?.topicsStore.fetchRelations(onRelationsFetched)
        }
        dataStore?.buddiesStore.fetchBuddies(onBuddiesFetched)
    }
    
    func generateDisplayData(buddies: [Buddy], relations: [TopicRelation]) {
        let displayData = buddies.map { (buddy) -> BuddyListItemDisplayData in
            let topicCount = relations.filter({ (relation) -> Bool in
                return relation.buddyId == buddy.id
            }).count
            return BuddyListItemDisplayData(id: buddy.id, name: buddy.name, topicCount: topicCount)
        }
        userInterface?.obtainedBuddies(displayData)
    }
}