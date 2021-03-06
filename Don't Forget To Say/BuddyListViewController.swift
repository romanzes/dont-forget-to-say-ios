//
//  BuddyListViewController.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import StatefulViewController

var BuddyTableCellIdentifier = "BuddyTableCell"

class BuddyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BuddyListViewInterface, StatefulViewController {
    // MARK: Injected properties
    var router: Router!
    var presenter: BuddyListPresenterInterface!
    
    // MARK: Properties
    var displayData: [BuddyListItemDisplayData]?
    
    // MARK: Outlets
    @IBOutlet weak var buddiesTableView: UITableView!
    @IBOutlet weak var addTopicButton: UIButton!
    
    init() {
        super.init(nibName: "BuddyListViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        navigationItem.title = NSLocalizedString("buddy_list_title", comment: "Buddy list screen title")
        
        let settingsButtonLabel = NSLocalizedString("settings_button_label", comment: "Settings button label")
        let settingsButton = UIBarButtonItem(title: settingsButtonLabel, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.settingsButtonClicked))
        self.navigationItem.rightBarButtonItem = settingsButton
        
        buddiesTableView.dataSource = self
        buddiesTableView.delegate = self
        buddiesTableView.registerNib(UINib(nibName: BuddyTableCellIdentifier, bundle: nil), forCellReuseIdentifier: BuddyTableCellIdentifier)
        
        addTopicButton.setTitle(NSLocalizedString("add_topic_button", comment: "Add topic button text"), forState: UIControlState.Normal)
        addTopicButton.addTarget(self, action: #selector(self.addTopicClicked), forControlEvents: UIControlEvents.TouchUpInside)
        
        let loadingView = CommonLoadingView.instanceFromNib()
        self.loadingView = loadingView
        loadingView.showMessage(NSLocalizedString("buddy_list_loading_progress", comment: "Buddy list loading progress"))
        
        let emptyView = CommonEmptyView.instanceFromNib()
        self.emptyView = emptyView
        emptyView.setMessage(NSLocalizedString("buddy_list_empty", comment: "Buddy list empty message"))
    }
    
    func settingsButtonClicked() {
        router.showSettingsFromViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
    }
    
    override func viewDidAppear(animated: Bool) {
        startLoading()
        presenter.obtainBuddies()
    }
    
    override func viewDidLayoutSubviews() {
        (emptyView as! CommonStateView).adjustInsetsInController(self, place: buddiesTableView)
    }
    
    func updateBuddies(buddies: [BuddyListItemDisplayData]) {
        displayData = buddies
        buddiesTableView.backgroundView = nil
        buddiesTableView.separatorStyle = .SingleLine
        reloadEntries()
    }
    
    func reloadEntries() {
        endLoading()
        buddiesTableView.reloadData()
    }
    
    func addTopicClicked() {
        router.presentAddTopicFromViewController(self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let displayData = displayData {
            return displayData.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(BuddyTableCellIdentifier, forIndexPath: indexPath) as! BuddyTableCell
        
        if let buddyItem = displayData?[indexPath.row] {
            cell.nameLabel.text = buddyItem.name
            cell.topicsLabel.text = String(buddyItem.topicCount)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let buddyId = displayData?[indexPath.row].id {
            router.showTopicListFromViewController(self, buddyId: buddyId)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let buddy = displayData?[indexPath.row] {
            let title = String.localizedStringWithFormat(NSLocalizedString("buddy_remove_title", comment: "Buddy deletion alert title"), buddy.name)
            let message = NSLocalizedString("buddy_remove_message", comment: "Buddy deletion alert message")
            let okButton = NSLocalizedString("buddy_remove_ok", comment: "Buddy deletion confirmation button")
            let cancelButton = NSLocalizedString("buddy_remove_cancel", comment: "Buddy deletion cancel button")
            
            let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            deleteAlert.addAction(UIAlertAction(title: okButton, style: .Default, handler: { (action: UIAlertAction!) in
                self.presenter.deleteBuddy(buddy.id)
            }))
            deleteAlert.addAction(UIAlertAction(title: cancelButton, style: .Cancel, handler: nil))
            
            tableView.setEditing(false, animated: true)
            presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: StatefulViewController
    
    func hasContent() -> Bool {
        return displayData?.count > 0
    }
}
