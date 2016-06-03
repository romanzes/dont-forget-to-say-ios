//
//  TopicListViewController.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit
import StatefulViewController

var TopicTableCellIdentifier = "TopicTableCell"

class TopicListViewController: UIViewController, UITableViewDataSource, TopicListViewInterface, StatefulViewController {
    // MARK: Injected properties
    var presenter: TopicListPresenterInterface!
    
    // MARK: Properties
    var buddyId: String!
    var buddyName: String?
    var displayData: [TopicListItemDisplayData]?
    
    // MARK: Outlets
    @IBOutlet weak var topicsTableView: UITableView!
    @IBOutlet var noContentView: UIView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    init() {
        super.init(nibName: "TopicListViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        let showButtonTitle = NSLocalizedString("show_notifications_button", comment: "Show notifications button text")
        let showButton = UIBarButtonItem(title: showButtonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.showButtonClicked))
        self.navigationItem.rightBarButtonItem = showButton
        
        topicsTableView.dataSource = self
        topicsTableView.registerNib(UINib(nibName: TopicTableCellIdentifier, bundle: nil), forCellReuseIdentifier: TopicTableCellIdentifier)
        
        noContentLabel.text = NSLocalizedString("topic_list_empty", comment: "Topic list empty message")
        
        let loadingView = CommonLoadingView.instanceFromNib()
        self.loadingView = loadingView
        loadingView.showMessage(NSLocalizedString("topic_list_loading_progress", comment: "Topic list loading progress"))
        
        let emptyView = CommonEmptyView.instanceFromNib()
        self.emptyView = emptyView
        emptyView.setMessage(NSLocalizedString("topic_list_empty", comment: "Topic list empty message"))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()
        startLoading()
        presenter.fetchData(buddyId)
    }
    
    func showButtonClicked() {
        presenter.showNotifications()
    }
    
    func showBuddyName(name: String) {
        buddyName = name
        let title = String.localizedStringWithFormat(NSLocalizedString("topic_list_title", comment: "Topic list screen title"), name)
        navigationItem.title = title
    }
    
    func updateTopics(topics: [TopicListItemDisplayData]) {
        displayData = topics
        topicsTableView.backgroundView = nil
        topicsTableView.separatorStyle = .SingleLine
        reloadEntries()
    }
    
    func showNoContentMessage() {
        displayData = nil
        topicsTableView.backgroundView = noContentView
        topicsTableView.separatorStyle = .None
        reloadEntries()
    }
    
    func reloadEntries() {
        endLoading()
        topicsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataProperty = displayData {
            return dataProperty.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let topicItem = displayData![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(TopicTableCellIdentifier, forIndexPath: indexPath) as! TopicTableCell
        cell.topicTextLabel.text = topicItem.text
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let topic = displayData?[indexPath.row] {
            let dialog: UIAlertController
            if topic.isSingle {
                dialog = singleDeletionDialog(topic)
            } else {
                dialog = multipleDeletionDialog(topic)
            }
            tableView.setEditing(false, animated: true)
            presentViewController(dialog, animated: true, completion: nil)
        }
    }
    
    private func singleDeletionDialog(topic: TopicListItemDisplayData) -> UIAlertController {
        let title = NSLocalizedString("topic_remove_title", comment: "Topic deletion alert title")
        let message = NSLocalizedString("topic_remove_message_single", comment: "Topic deletion alert message for single relation")
        let okButton = NSLocalizedString("topic_remove_ok", comment: "Topic deletion confirmation button")
        let cancelButton = NSLocalizedString("topic_remove_cancel", comment: "Topic deletion cancel button")
        
        let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        deleteAlert.addAction(UIAlertAction(title: okButton, style: .Default, handler: { (action: UIAlertAction!) in
            self.presenter.deleteTopic(topic.id, deleteAll: true)
        }))
        deleteAlert.addAction(UIAlertAction(title: cancelButton, style: .Cancel, handler: nil))
        return deleteAlert
    }
    
    private func multipleDeletionDialog(topic: TopicListItemDisplayData) -> UIAlertController {
        let title = NSLocalizedString("topic_remove_title", comment: "Topic deletion alert title")
        let message = NSLocalizedString("topic_remove_message_multiple", comment: "Topic deletion alert message for multiple relation")
        let deleteAllButton = NSLocalizedString("topic_remove_all_ok", comment: "Topic button to delete all relations")
        let deleteSingleButton = String.localizedStringWithFormat(NSLocalizedString("topic_remove_single_ok", comment: "Topic button to delete one relation"), buddyName!)
        let cancelButton = NSLocalizedString("topic_remove_cancel", comment: "Topic deletion cancel button")
        
        let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        deleteAlert.addAction(UIAlertAction(title: deleteAllButton, style: .Destructive, handler: { (action: UIAlertAction!) in
            self.presenter.deleteTopic(topic.id, deleteAll: true)
        }))
        deleteAlert.addAction(UIAlertAction(title: deleteSingleButton, style: .Default, handler: { (action: UIAlertAction!) in
            self.presenter.deleteTopic(topic.id, deleteAll: false)
        }))
        deleteAlert.addAction(UIAlertAction(title: cancelButton, style: .Cancel, handler: nil))
        return deleteAlert
    }
    
    // MARK: StatefulViewController
    
    func hasContent() -> Bool {
        return displayData?.count > 0
    }
}
