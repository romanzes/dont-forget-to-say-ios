//
//  LocalizedPasscodeViewController.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/18/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import PasscodeLock

class LocalizedPasscodeViewController: PasscodeLockViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton?.setTitle(NSLocalizedString("passcode_cancel_button", comment: "Passcode screen cancel button"), forState: .Normal)
        deleteSignButton?.setTitle(NSLocalizedString("passcode_delete_button", comment: "Passcode screen delete button"), forState: .Normal)
    }
}