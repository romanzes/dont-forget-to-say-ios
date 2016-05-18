//
//  SettingsViewPresenter.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/17/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol SettingsPresenterInterface {
    func loadForm()
    func saveForm()
}

protocol SettingsViewInterface: class {
    func loadedForm(form: SettingsForm)
}

class SettingsPresenter: SettingsPresenterInterface {
    // MARK: Injected properties
    var settingsProvider: SettingsProvider!
    var settingsForm: SettingsForm!
    weak var userInterface: SettingsViewInterface?
    
    func loadForm() {
        settingsForm.passcodeEnabled = settingsProvider.isPasscodeEnabled()
        userInterface?.loadedForm(settingsForm)
    }
    
    func saveForm() {
        settingsProvider.setPasscodeEnabled(settingsForm.passcodeEnabled)
    }
}