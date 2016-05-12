//
//  AppDelegate.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container() { c in
        c.register(Router.self) { r in
            Router(container: c)
        }
        .inObjectScope(.Container)
        c.register(GlobalDataStore.self) { r in
            GlobalDataStore(buddiesStore: BuddiesMemStore(), topicsStore: TopicsMemStore())
        }
        .inObjectScope(.Container)
        c.register(NotificationManagerInterface.self) { r in NotificationManager() }
            .initCompleted() { r, c in
                let notificationManager = c as! NotificationManager
                notificationManager.dataStore = r.resolve(GlobalDataStore.self)
            }
        .inObjectScope(.Container)
        
        c.register(BuddyListViewInterface.self) { r in BuddyListViewController() }
            .initCompleted() { r, c in
                let viewController = c as! BuddyListViewController
                viewController.presenter = r.resolve(BuddyListPresenterInterface.self)
                viewController.router = r.resolve(Router.self)
            }
        c.register(BuddyListPresenterInterface.self) { r in BuddyListPresenter() }
            .initCompleted() { r, c in
                let presenter = c as! BuddyListPresenter
                presenter.userInterface = r.resolve(BuddyListViewInterface.self)
                presenter.dataStore = r.resolve(GlobalDataStore.self)
            }
        
        c.register(TopicListViewInterface.self) { r in TopicListViewController() }
            .initCompleted() { r, c in
                let viewController = c as! TopicListViewController
                viewController.presenter = r.resolve(TopicListPresenterInterface.self)
            }
        c.register(TopicListPresenterInterface.self) { r in TopicListPresenter() }
            .initCompleted() { r, c in
                let presenter = c as! TopicListPresenter
                presenter.userInterface = r.resolve(TopicListViewInterface.self)
                presenter.dataStore = r.resolve(GlobalDataStore.self)
                presenter.notificationManager = r.resolve(NotificationManagerInterface.self)
            }
        
        c.register(AddTopicViewInterface.self) { r in AddTopicViewController() }
            .initCompleted() { r, c in
                let viewController = c as! AddTopicViewController
                viewController.presenter = r.resolve(AddTopicPresenterInterface.self)
        }
        c.register(AddTopicPresenterInterface.self) { r in AddTopicPresenter() }
            .initCompleted() { r, c in
                let presenter = c as! AddTopicPresenter
                presenter.userInterface = r.resolve(AddTopicViewInterface.self)
                presenter.dataStore = r.resolve(GlobalDataStore.self)
        }
    }
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        container.resolve(Router.self)?.presentMainControllerFromWindow(window!)
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let notificationManager = container.resolve(NotificationManagerInterface.self) as! NotificationManager
        notificationManager.continueAfterRegistration()
    }
}

