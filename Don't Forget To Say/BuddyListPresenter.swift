//
//  BuddyListPresenter.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Async

protocol BuddyListPresenterInterface {
    func obtainBuddies()
    func deleteBuddy(buddyId: Int)
}

protocol BuddyListViewInterface: class {
    func updateBuddies(buddies: [BuddyListItemDisplayData])
    func showNoContentMessage()
}

class BuddyListPresenter: BuddyListPresenterInterface {
    // MARK: Injected properties
    var dataStore: DataStoreProtocol!
    weak var userInterface: BuddyListViewInterface?
    
    func obtainBuddies() {
        dataStore.fetchBuddies() { buddies, error in
            if let buddies = buddies {
                self.generateDisplayData(buddies)
            }
        }
    }
    
    func deleteBuddy(buddyId: Int) {
        dataStore.deleteBuddy(buddyId, completionHandler: { (error) in
            self.obtainBuddies()
        })
    }
    
    func generateDisplayData(buddies: [Buddy]) {
        var displayData = [BuddyListItemDisplayData]()
        var generateNextItem: (() -> Void)!
        generateNextItem = {
            if displayData.count < buddies.count {
                let buddy = buddies[displayData.count]
                self.dataStore.fetchTopicsForBuddy(buddy.id) { (topics, error) in
                    if let topics = topics {
                        let item = BuddyListItemDisplayData(id: buddy.id, name: buddy.name, topicCount: topics.count)
                        displayData += [item]
                        generateNextItem()
                    }
                }
            } else {
                self.onDisplayDataGenerated(displayData)
            }
        }
        generateNextItem()
    }
    
    func onDisplayDataGenerated(displayData: [BuddyListItemDisplayData]) {
        Async.main {
            if displayData.count == 0 {
                self.userInterface?.showNoContentMessage()
            } else {
                self.userInterface?.updateBuddies(displayData)
            }
        }
    }
}