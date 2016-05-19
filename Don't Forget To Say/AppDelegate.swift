//
//  AppDelegate.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import Swinject
import PasscodeLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let container = Container() { c in
        c.register(Router.self) { r in
                Router(container: c)
            }
            .inObjectScope(.Container)
        c.register(DataStoreProtocol.self) { r in RealmDataStore() }
            .inObjectScope(.Container)
        c.register(ContactStoreProtocol.self) { r in AddressBookContactStore() }
            .inObjectScope(.Container)
        c.register(NotificationManagerInterface.self) { r in NotificationManager() }
            .initCompleted() { r, c in
                let notificationManager = c as! NotificationManager
                notificationManager.dataStore = r.resolve(DataStoreProtocol.self)
            }
            .inObjectScope(.Container)
        c.register(SettingsProvider.self) { r in UserDefaultsSettingsProvider() }
        
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
                presenter.dataStore = r.resolve(DataStoreProtocol.self)
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
                presenter.dataStore = r.resolve(DataStoreProtocol.self)
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
                presenter.dataStore = r.resolve(DataStoreProtocol.self)
                presenter.contactStore = r.resolve(ContactStoreProtocol.self)
        }
        
        c.register(SettingsViewInterface.self) { r in SettingsViewController() }
            .initCompleted() { r, c in
                let viewController = c as! SettingsViewController
                viewController.router = r.resolve(Router.self)
                viewController.presenter = r.resolve(SettingsPresenterInterface.self)
        }
        c.register(SettingsPresenterInterface.self) { r in SettingsPresenter() }
            .initCompleted() { r, c in
                let presenter = c as! SettingsPresenter
                presenter.settingsProvider = r.resolve(SettingsProvider.self)
                presenter.settingsForm = SettingsFormImpl()
                presenter.userInterface = r.resolve(SettingsViewInterface.self)
        }
    }
    
    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        let configuration = PasscodeLockConfiguration()
        let viewController = LocalizedPasscodeViewController(state: .EnterPasscode, configuration: configuration)
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration, viewController: viewController)
        return presenter
    }()
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        container.resolve(Router.self)?.presentMainControllerFromWindow(window!)
        showPasscode()
        return true
    }
    
    func showPasscode() {
        let settingsProvider = container.resolve(SettingsProvider)!
        if settingsProvider.isPasscodeEnabled() {
            passcodeLockPresenter.presentPasscodeLock()
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        showPasscode()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        let notificationManager = container.resolve(NotificationManagerInterface.self) as! NotificationManager
        notificationManager.continueAfterRegistration()
    }
}

