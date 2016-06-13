//
//  SettingsViewController.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/17/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import FXForms

class SettingsViewController: FXFormViewController, SettingsViewInterface {
    // MARK: Injected properties
    var router: Router!
    var presenter: SettingsPresenterInterface!
    
    // MARK: Properties
    var form: SettingsForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("settings_screen_title", comment: "Settings screen title")
        
        presenter.loadForm()
    }
    
    func setForm(form: SettingsForm) {
        self.form = form
    }
    
    func refreshForm() {
        formController.form = form as! FXForm
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        presenter.saveForm()
    }
    
    func changePasscodeClicked() {
        router.showPasscodeFromSettings(self)
    }
    
    func enablePasscodeToggled() {
        performSelector(#selector(refreshForm), withObject: self, afterDelay: 0.2)
    }
    
    func signInClicked() {
        presenter.signIn()
    }
    
    func signOutClicked() {
        presenter.signOut()
    }
}