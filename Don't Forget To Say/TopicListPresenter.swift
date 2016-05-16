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
}

protocol TopicListViewInterface: class {
    func showTitle(title: String)
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
    
    private func obtainTitle() {
        dataStore.fetchBuddy(buddyId, completionHandler: { (buddy, error) in
            if let buddy = buddy {
                self.generateTitle(buddy)
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
    
    private func generateTitle(buddy: Buddy) {
        let title = String.localizedStringWithFormat(NSLocalizedString("topic_list_title", comment: "Topic list screen title"), buddy.name)
        userInterface?.showTitle(title)
    }
    
    private func generateDisplayData(topics: [Topic]) {
        let displayData = topics.map { (topic) -> TopicListItemDisplayData in
            return TopicListItemDisplayData(id: topic.id, text: topic.text)
        }
        if displayData.count == 0 {
            userInterface?.showNoContentMessage()
        } else {
            userInterface?.updateTopics(displayData)
        }
    }
}