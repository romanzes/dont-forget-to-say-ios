//
//  Router.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import Swinject
import PasscodeLock

struct Router {
    let container: Container
    
    func presentMainControllerFromWindow(window: UIWindow) {
        let mainController = container.resolve(BuddyListViewInterface) as! BuddyListViewController
        window.rootViewController = UINavigationController(rootViewController: mainController)
        window.makeKeyAndVisible()
    }
    
    func showTopicListFromViewController(viewController: UIViewController, buddyId: Int) {
        let topicListViewController = container.resolve(TopicListViewInterface) as! TopicListViewController
        topicListViewController.buddyId = buddyId
        viewController.navigationController?.pushViewController(topicListViewController, animated: true)
    }
    
    func presentAddTopicFromViewController(viewController: UIViewController) {
        let addTopicViewController = container.resolve(AddTopicViewInterface) as! AddTopicViewController
        let navigationController = UINavigationController(rootViewController: addTopicViewController)
        viewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func showSettingsFromViewController(viewController: UIViewController) {
        let settingsViewController = container.resolve(SettingsViewInterface) as! SettingsViewController
        viewController.navigationController?.pushViewController(settingsViewController, animated: true)
    }
    
    func showPasscodeFromSettings(viewController: UIViewController) {
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        let passcodeViewController: PasscodeLockViewController
        if repo.hasPasscode {
            passcodeViewController = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
        } else {
            passcodeViewController = PasscodeLockViewController(state: .SetPasscode, configuration: config)
        }
        viewController.navigationController?.pushViewController(passcodeViewController, animated: true)
    }
}