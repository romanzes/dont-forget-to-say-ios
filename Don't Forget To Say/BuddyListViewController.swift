//
//  BuddyListViewController.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import UIKit

var BuddyTableCellIdentifier = "BuddyTableCell"

class BuddyListViewController: UIViewController, UITableViewDataSource, BuddyListViewInterface {
    // MARK: Injected properties
    var presenter: BuddyListPresenterInterface?
    
    // MARK: Properties
    var displayData: [BuddyListItemDisplayData]?
    
    // MARK: Outlets
    @IBOutlet weak var buddiesTableView: UITableView!
    
    init(presenter: BuddyListPresenterInterface?) {
        self.presenter = presenter
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
        buddiesTableView.registerNib(UINib(nibName: BuddyTableCellIdentifier, bundle: nil), forCellReuseIdentifier: BuddyTableCellIdentifier)
    }
    
    override func viewDidAppear(animated: Bool) {
        presenter?.obtainBuddies()
    }
    
    func obtainedBuddies(buddies: [BuddyListItemDisplayData]) {
        displayData = buddies
        reloadEntries()
    }
    
    func reloadEntries() {
        buddiesTableView.reloadData()
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
}
