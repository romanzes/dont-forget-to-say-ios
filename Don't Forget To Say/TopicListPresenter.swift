//
//  TopicListPresenter.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Async

protocol TopicListPresenterInterface {
    func fetchData(buddyId: String)
    func showNotifications()
    func deleteTopic(topicId: String, deleteAll: Bool)
}

protocol TopicListViewInterface: class {
    func showBuddyName(name: String)
    func updateTopics(topics: [TopicListItemDisplayData])
    func showNoContentMessage()
}

class TopicListPresenter: TopicListPresenterInterface {
    // MARK: Injected properties
    var dataStore: DataStoreProtocol!
    var notificationManager: NotificationManagerInterface!
    weak var userInterface: TopicListViewInterface?
    
    // MARK: Properties
    var buddyId: String!
    
    func fetchData(buddyId: String) {
        self.buddyId = buddyId
        obtainTitle()
        obtainTopics()
    }
    
    func showNotifications() {
        notificationManager.showNotificationsForBuddy(buddyId)
    }
    
    func deleteTopic(topicId: String, deleteAll: Bool) {
        let onDelete: (CrudStoreError?) -> Void = { (error) in
            self.obtainTopics()
        }
        if deleteAll {
            dataStore.deleteTopic(topicId, completionHandler: onDelete)
        } else {
            dataStore.deleteTopicFromBuddy(buddyId, topicId: topicId, completionHandler: onDelete)
        }
    }
    
    private func obtainTitle() {
        dataStore.fetchBuddy(buddyId, completionHandler: { (buddy, error) in
            if let buddy = buddy {
                Async.main {
                    self.userInterface?.showBuddyName(buddy.name)
                }
            }
        })
    }
    
    private func obtainTopics() {
        dataStore.fetchTopicsForBuddy(buddyId, completionHandler: { (topics, error) in
            if let topics = topics {
                self.generateDisplayData(topics)
            }
        })
    }
    
    private func generateDisplayData(topics: [Topic]) {
        let displayData = topics.map { (topic) -> TopicListItemDisplayData in
            return TopicListItemDisplayData(id: topic.id, text: topic.text, isSingle: topic.buddyCount == 1)
        }
        onDisplayDataGenerated(displayData)
    }
    
    private func onDisplayDataGenerated(displayData: [TopicListItemDisplayData]) {
        Async.main {
            if displayData.count == 0 {
                self.userInterface?.showNoContentMessage()
            } else {
                self.userInterface?.updateTopics(displayData)
            }
        }
    }
}