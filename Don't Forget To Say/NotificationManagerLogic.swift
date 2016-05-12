//
//  NotificationManager.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/12/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import NotificationCenter

protocol NotificationManagerInterface {
    func showNotificationsForBuddy(buddyId: Int)
}

extension NotificationManager: NotificationManagerInterface {
    func showNotificationsForBuddy(buddyId: Int) {
        runWithCheck {
            self.showNotificationsForBuddyImpl(buddyId)
        }
    }
    
    func showNotificationsForBuddyImpl(buddyId: Int) {
        dataStore.topicsStore.fetchTopicsForBuddy(buddyId) { (topics, error) in
            topics?.forEach({ (topic) in
                self.showNotificationForTopic(topic)
            })
        }
    }
    
    private func showNotificationForTopic(topic: Topic) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = topic.text
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}