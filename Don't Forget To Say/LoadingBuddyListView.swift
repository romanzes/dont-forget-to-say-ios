//
//  LoadingBuddyListView.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/25/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

class LoadingBuddyListView: UIView {
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LoadingBuddyListView", bundle: nil).instantiateWithOwner(nil, options: nil).first as! LoadingBuddyListView
    }
    
    override func awakeFromNib() {
        configureView()
    }
    
    private func configureView() {
        loadingLabel.text = NSLocalizedString("buddy_loading_progress", comment: "Buddy list loading progress")
        progressIndicator.startAnimating()
    }
}