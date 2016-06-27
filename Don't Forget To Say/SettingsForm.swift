//
//  SettingsForm.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/17/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import FXForms

protocol SettingsForm: class {
    var passcodeEnabled: Bool { get set }
}

class SettingsFormImpl: NSObject, FXForm, SettingsForm {
    var passcodeEnabled: Bool = false
    
    func fields() -> [AnyObject]! {
        var result: [AnyObject] = []
        
        let passcodeEnabledField = [
            FXFormFieldKey: "passcodeEnabled",
            FXFormFieldTitle: NSLocalizedString("passcode_enabled", comment: "Passcode enabled label"),
            FXFormFieldAction: "enablePasscodeToggled",
            FXFormFieldHeader: NSLocalizedString("privacy_group_title", comment: "Privacy group title")
        ]
        result.append(passcodeEnabledField)
        
        if passcodeEnabled {
            let changePasscodeField = [
                FXFormFieldTitle: NSLocalizedString("сhange_passcode", comment: "Change passcode label"),
                FXFormFieldAction: "changePasscodeClicked"
            ]
            result.append(changePasscodeField)
        }
        
        let syncTitle = NSLocalizedString("sync_group_title", comment: "Synchronization group title")
        let facebookField = [
            FXFormFieldHeader: syncTitle,
            FXFormFieldCell: FacebookButtonCell.self
        ]
        result.append(facebookField)
        
        return result
    }
}
