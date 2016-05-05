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
    
    func presentMainController(window: UIWindow) {
        let mainController = container.resolve(BuddyListViewInterface) as! BuddyListViewController
        window.rootViewController = UINavigationController(rootViewController: mainController)
        window.makeKeyAndVisible()
    }
}