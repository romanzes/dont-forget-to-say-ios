//
//  TopicListPresenter.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol TopicListPresenterInterface {
    func fetchData(buddyId: Int)
    func showNotifications()
    func deleteTopic(topicId: Int, deleteAll: Bool)
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
    var buddyId: Int!
    
    func fetchData(buddyId: Int) {
        self.buddyId = buddyId
        obtainTitle()
        obtainTopics()
    }
    
    func showNotifications() {
        notificationManager.showNotificationsForBuddy(buddyId)
    }
    
    func deleteTopic(topicId: Int, deleteAll: Bool) {
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
                self.userInterface?.showBuddyName(buddy.name)
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
        if displayData.count == 0 {
            userInterface?.showNoContentMessage()
        } else {
            userInterface?.updateTopics(displayData)
        }
    }
}