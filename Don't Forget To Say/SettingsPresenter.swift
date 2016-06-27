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
    func setForm(form: SettingsForm)
    func refreshForm()
}

class SettingsPresenter: SettingsPresenterInterface {
    // MARK: Injected properties
    var settingsProvider: SettingsProvider!
    var settingsForm: SettingsForm!
    weak var userInterface: SettingsViewInterface?
    
    func loadForm() {
        settingsForm.passcodeEnabled = settingsProvider.isPasscodeEnabled()
        userInterface?.setForm(settingsForm)
        userInterface?.refreshForm()
    }
    
    func saveForm() {
        settingsProvider.setPasscodeEnabled(settingsForm.passcodeEnabled)
    }
}