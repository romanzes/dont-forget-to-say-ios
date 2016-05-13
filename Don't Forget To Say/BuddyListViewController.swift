//
//  BuddyListViewController.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

var BuddyTableCellIdentifier = "BuddyTableCell"

class BuddyListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BuddyListViewInterface {
    // MARK: Injected properties
    var router: Router!
    var presenter: BuddyListPresenterInterface!
    
    // MARK: Properties
    var displayData: [BuddyListItemDisplayData]?
    
    // MARK: Outlets
    @IBOutlet weak var buddiesTableView: UITableView!
    @IBOutlet weak var addTopicButton: UIButton!
    @IBOutlet var noContentView: UIView!
    @IBOutlet weak var noContentLabel: UILabel!
    
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
        navigationItem.title = NSLocalizedString("Buddies", comment: "Buddy list screen title")
        
        buddiesTableView.dataSource = self
        buddiesTableView.delegate = self
        buddiesTableView.registerNib(UINib(nibName: BuddyTableCellIdentifier, bundle: nil), forCellReuseIdentifier: BuddyTableCellIdentifier)
        
        noContentLabel.text = NSLocalizedString("Buddy list is empty", comment: "Buddy list empty message")
        
        addTopicButton.setTitle(NSLocalizedString("Add topic (button)", comment: "Add topic button text"), forState: UIControlState.Normal)
        addTopicButton.addTarget(self, action: #selector(self.addTopicClicked), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        presenter.obtainBuddies()
    }
    
    func updateBuddies(buddies: [BuddyListItemDisplayData]) {
        displayData = buddies
        buddiesTableView.backgroundView = nil
        buddiesTableView.separatorStyle = .SingleLine
        reloadEntries()
    }
    
    func showNoContentMessage() {
        buddiesTableView.backgroundView = noContentView
        buddiesTableView.separatorStyle = .None
        reloadEntries()
    }
    
    func reloadEntries() {
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
}
