//
//  AddTopicPresenter.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/5/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol AddTopicPresenterInterface {
    func filterContacts(predicate: String?)
}

protocol AddTopicViewInterface: class {
    func updateContacts(contacts: [ContactListItemDisplayData]?)
}

class AddTopicPresenter: AddTopicPresenterInterface {
    // MARK: Injected properties
    var dataStore: GlobalDataStore!
    weak var userInterface: AddTopicViewInterface?
    
    var contacts: [ContactListItemDisplayData]?
    
    private func obtainContacts(completionHandler: () -> Void) {
        dataStore.buddiesStore.fetchBuddies { (buddies, error) in
            if let buddies = buddies {
                self.contacts = buddies.map({ (buddy) -> ContactListItemDisplayData in
                    ContactListItemDisplayData(name: buddy.name)
                })
                completionHandler()
            }
        }
    }
    
    func filterContacts(predicate: String?) {
        let onObtain = {
            if predicate == nil || predicate!.isEmpty {
                self.userInterface?.updateContacts(self.contacts)
            } else {
                let filteredContacts = self.contacts?.filter({ (elem) -> Bool in
                    return elem.name.lowercaseString.containsString(predicate!.lowercaseString)
                })
                self.userInterface?.updateContacts(filteredContacts)
            }
        }
        if contacts == nil {
            obtainContacts(onObtain)
        } else {
            onObtain()
        }
    }
}