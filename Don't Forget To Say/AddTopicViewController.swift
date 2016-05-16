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
    var selectedContacts = Set<ContactListItemDisplayData>()
    
    // MARK: Outlets
    @IBOutlet weak var topicTextField: UITextField!
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
        navigationItem.title = NSLocalizedString("add_topic_title", comment: "Add topic screen title")
        edgesForExtendedLayout = UIRectEdge.None
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.leftBarButtonItem = cancelButton
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(self.save))
        self.navigationItem.rightBarButtonItem = saveButton
        
        topicTextField.placeholder = NSLocalizedString("topic_text_placeholder", comment: "Topic text placeholder")
        
        buddyPicker.delegate = self
        buddyPicker.setPlaceholderLabelText(NSLocalizedString("buddy_picker_placeholder", comment: "Buddy picker placeholder"))
        buddyPicker.setPromptLabelText(NSLocalizedString("buddy_picker_prompt", comment: "Buddy picker prompt"))
        let layer = buddyPicker.layer
        layer.shadowColor = UIColor(red: 225.0/255.0, green: 226.0/255.0, blue: 228.0/255.0, alpha: 1).CGColor
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 1.0
        
        buddiesTableView.delegate = self
        buddiesTableView.dataSource = self
        buddiesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: BuddySuggestTableCellIdentifier)
        buddiesTableView.reloadData()
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {
        if let text = topicTextField.text {
            presenter.saveTopicWithText(text, contacts: selectedContacts)
        }
    }
    
    func updateContacts(contacts: [ContactListItemDisplayData]?) {
        self.contacts = contacts
        buddiesTableView.reloadData()
    }
    
    func savedTopic() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func contactPicker(contactPicker: THContactPickerView!, textFieldDidChange textField: UITextField!) {
        presenter.filterContacts(textField.text)
    }
    
    func contactPicker(contactPicker: THContactPickerView!, didSelectContact contact: AnyObject!) {
        contactPicker.removeContact(contact)
        selectedContacts.remove(contact as! ContactListItemDisplayData)
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
            fillCell(cell, contact: contacts[indexPath.row])
        }
        return cell
    }
    
    func fillCell(cell: UITableViewCell, contact: ContactListItemDisplayData) {
        if (contact.isNew) {
            let text = String.localizedStringWithFormat(NSLocalizedString("new_buddy_list_item", comment: "New buddy list item"), contact.name)
            cell.textLabel?.text = text
        } else {
            cell.textLabel?.text = contact.name
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let contact = contacts?[indexPath.row] {
            buddyPicker.addContact(contact, withName: contact.name)
            selectedContacts.insert(contact)
        }
    }
}