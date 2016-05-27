//
//  LoadingBuddyListView.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/25/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

class CommonLoadingView: CommonStateView {
    // MARK: Outlets
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    class func instanceFromNib() -> CommonLoadingView {
        return UINib(nibName: "\(CommonLoadingView.self)", bundle: nil).instantiateWithOwner(nil, options: nil).first as! CommonLoadingView
    }
    
    func showMessage(message: String) {
        loadingLabel.text = message
        progressIndicator.startAnimating()
    }
}