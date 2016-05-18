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
    
    func loadedForm(form: SettingsForm) {
        self.form = form
        reloadForm()
    }
    
    func reloadForm() {
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
        performSelector(#selector(reloadForm), withObject: self, afterDelay: 0.2)
    }
}