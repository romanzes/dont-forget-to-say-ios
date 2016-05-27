//
//  CommonEmptyView.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/26/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

class CommonEmptyView: CommonStateView {
    // MARK: Outlets
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    class func instanceFromNib() -> CommonEmptyView {
        return UINib(nibName: "\(CommonEmptyView.self)", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CommonEmptyView
    }
    
    func setMessage(message: String) {
        emptyMessageLabel.text = message
    }
}