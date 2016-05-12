//
//  AbstractNotificationManager.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/12/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import NotificationCenter

class NotificationManager {
    // MARK: Injected properties
    var dataStore: DataStoreProtocol!
    
    // MARK: Properties
    var pendingAction: (() -> Void)?
    
    func continueAfterRegistration() {
        pendingAction?()
        pendingAction = nil
    }
    
    func runWithCheck(action: () -> Void) {
        let app = UIApplication.sharedApplication()
        let settings = app.currentUserNotificationSettings()
        if settings == nil || !(settings!.types.contains(UIUserNotificationType.Badge)) {
            pendingAction = action
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge], categories: nil)
            app.registerUserNotificationSettings(settings)
        } else {
            action()
        }
    }
}