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
    func saveTopicWithText(text: String, contacts: Set<ContactListItemDisplayData>)
}

protocol AddTopicViewInterface: class {
    func updateContacts(contacts: [ContactListItemDisplayData]?)
    func savedTopic()
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
                    let result = ContactListItemDisplayData(name: buddy.name)
                    result.buddyId = buddy.id
                    return result
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
    
    func saveTopicWithText(text: String, contacts: Set<ContactListItemDisplayData>) {
        dataStore.topicsStore.addTopic(text) { (topic, error) in
            if let topicId = topic?.id {
                var buddyIds = Set<Int>()
                contacts.forEach({ (contact) in
                    if let buddyId = contact.buddyId {
                        buddyIds.insert(buddyId)
                    }
                })
                self.addNextRelation(topicId, buddyIds: &buddyIds)
            }
        }
    }
    
    private func addNextRelation(topicId: Int, inout buddyIds: Set<Int>) {
        if let buddyId = buddyIds.first {
            self.dataStore.topicsStore.addRelation(buddyId, topicId: topicId, completionHandler: { (topic, error) in
                buddyIds.removeFirst()
                self.addNextRelation(topicId, buddyIds: &buddyIds)
            })
        } else {
            userInterface?.savedTopic()
        }
    }
}