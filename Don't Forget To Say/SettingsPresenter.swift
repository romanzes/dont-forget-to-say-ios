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
    func signIn()
    func signOut()
}

protocol SettingsViewInterface: class {
    func setForm(form: SettingsForm)
    func refreshForm()
}

class SettingsPresenter: SettingsPresenterInterface {
    // MARK: Injected properties
    var settingsProvider: SettingsProvider!
    var authProvider: AuthProvider!
    var settingsForm: SettingsForm!
    weak var userInterface: SettingsViewInterface?
    
    func loadForm() {
        authProvider.setAuthCallback { (authorized) in
            self.settingsForm.authorized = authorized
            self.settingsForm.authInProgress = false
            self.userInterface?.refreshForm()
        }
        settingsForm.passcodeEnabled = settingsProvider.isPasscodeEnabled()
        settingsForm.authorized = authProvider.isAuthorized()
        userInterface?.setForm(settingsForm)
        userInterface?.refreshForm()
    }
    
    func saveForm() {
        settingsProvider.setPasscodeEnabled(settingsForm.passcodeEnabled)
    }
    
    func signIn() {
        settingsForm.authInProgress = true
        self.userInterface?.refreshForm()
        authProvider.signIn()
    }
    
    func signOut() {
        settingsForm.authInProgress = true
        self.userInterface?.refreshForm()
        authProvider.signOut()
    }
}