//
//  TopicListViewController.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

var TopicTableCellIdentifier = "TopicTableCell"

class TopicListViewController: UIViewController, UITableViewDataSource, TopicListViewInterface {
    // MARK: Injected properties
    var presenter: TopicListPresenterInterface!
    
    // MARK: Properties
    var buddyId: Int!
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchData(buddyId)
    }
    
    func showButtonClicked() {
        presenter.showNotifications()
    }
    
    func showTitle(title: String) {
        navigationItem.title = title
    }
    
    func updateTopics(topics: [TopicListItemDisplayData]) {
        displayData = topics
        topicsTableView.backgroundView = nil
        topicsTableView.separatorStyle = .SingleLine
        reloadEntries()
    }
    
    func showNoContentMessage() {
        topicsTableView.backgroundView = noContentView
        topicsTableView.separatorStyle = .None
        reloadEntries()
    }
    
    func reloadEntries() {
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
}
