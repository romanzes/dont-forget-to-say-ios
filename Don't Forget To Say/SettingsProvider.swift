//
//  SettingsProvider.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/17/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol SettingsProvider {
    func isPasscodeEnabled() -> Bool
    func setPasscodeEnabled(enabled: Bool)
}

class UserDefaultsSettingsProvider: SettingsProvider {
    lazy var defaults = NSUserDefaults.standardUserDefaults()
    
    func isPasscodeEnabled() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey("passcodeEnabled")
    }
    
    func setPasscodeEnabled(enabled: Bool) {
        defaults.setBool(enabled, forKey: "passcodeEnabled")
    }
}