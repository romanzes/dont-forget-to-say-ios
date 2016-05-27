//
//  CommonStateView.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/27/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import StatefulViewController

class CommonStateView: UIView, StatefulPlaceholderView {
    // MARK: Properties
    var customViewInsets = UIEdgeInsets()
    
    func placeholderViewInsets() -> UIEdgeInsets {
        return customViewInsets
    }
    
    func adjustInsetsInController(controller: UIViewController, place: UIView?) {
        if let place = place {
            let container = controller.view
            let bounds = container.bounds
            let parent: UIView
            if let superview = place.superview {
                parent = superview
            } else {
                parent = container
            }
            let frame = parent.convertRect(place.frame, toView: container)
            let right = frame.origin.x + frame.width
            let bottom = frame.origin.y + frame.height
            customViewInsets = UIEdgeInsetsMake(frame.origin.y - bounds.origin.y, frame.origin.x - bounds.origin.x, bounds.height - bottom, bounds.width - right)
        }
    }
}