//
//  AddTopicViewController.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import THContactPicker

var BuddySuggestTableCellIdentifier = "BuddySuggestTableCell"

class AddTopicViewController: UIViewController, THContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, AddTopicViewInterface {
    // MARK: Injected properties
    var presenter: AddTopicPresenterInterface!
    
    // MARK: Properties
    var contacts: [ContactListItemDisplayData]?
    
    // MARK: Outlets
    @IBOutlet weak var buddyPicker: THContactPickerView!
    @IBOutlet weak var buddiesTableView: UITableView!
    @IBOutlet weak var buddyPickerHeight: NSLayoutConstraint!
    
    init() {
        super.init(nibName: "AddTopicViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.filterContacts("")
    }
    
    func configureView() {
        navigationItem.title = NSLocalizedString("Add topic (title)", comment: "Add topic screen title")
        edgesForExtendedLayout = UIRectEdge.None
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        buddyPicker.delegate = self
        
        buddiesTableView.delegate = self
        buddiesTableView.dataSource = self
        buddiesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BuddySuggestTableCellIdentifier)
        buddiesTableView.reloadData()
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateContacts(contacts: [ContactListItemDisplayData]?) {
        self.contacts = contacts
        buddiesTableView.reloadData()
    }
    
    func contactPicker(contactPicker: THContactPickerView!, textFieldDidChange textField: UITextField!) {
        presenter.filterContacts(textField.text)
    }
    
    func contactPicker(contactPicker: THContactPickerView!, didSelectContact contact: AnyObject!) {
        contactPicker.removeContact(contact)
    }
    
    func contactPickerDidResize(contactPicker: THContactPickerView!) {
        self.buddyPickerHeight.constant = contactPicker.frame.height
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contacts = contacts {
            return contacts.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BuddySuggestTableCellIdentifier)!
        if let contacts = contacts {
            cell.textLabel?.text = contacts[indexPath.row].name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let contact = contacts?[indexPath.row] {
            buddyPicker.addContact(contact, withName: contact.name)
        }
    }
}