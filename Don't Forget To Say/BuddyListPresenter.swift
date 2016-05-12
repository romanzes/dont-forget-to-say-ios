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

protocol BuddyListViewInterface: class {
    func updateBuddies(buddies: [BuddyListItemDisplayData])
}

class BuddyListPresenter: BuddyListPresenterInterface {
    // MARK: Injected properties
    var dataStore: GlobalDataStore!
    weak var userInterface: BuddyListViewInterface?
    
    func obtainBuddies() {
        dataStore.buddiesStore.fetchBuddies() { buddies, error in
            if let buddies = buddies {
                var displayData = [BuddyListItemDisplayData]()
                self.generateDisplayData(buddies, displayData: &displayData)
            }
        }
    }
    
    func generateDisplayData(buddies: [Buddy], inout displayData: [BuddyListItemDisplayData]) {
        if buddies.count > displayData.count {
            let buddy = buddies[displayData.count]
            dataStore.topicsStore.fetchTopicsForBuddy(buddy.id) { (topics, error) in
                if let topics = topics {
                    let item = BuddyListItemDisplayData(id: buddy.id, name: buddy.name, topicCount: topics.count)
                    displayData += [item]
                    self.generateDisplayData(buddies, displayData: &displayData)
                }
            }
        } else {
            userInterface?.updateBuddies(displayData)
        }
    }
}