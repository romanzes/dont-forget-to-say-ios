//
//  Router.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import Swinject

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
}