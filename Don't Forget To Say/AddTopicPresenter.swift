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
                    let result = ContactListItemDisplayData(name: buddy.name, isNew: false)
                    result.buddyId = buddy.id
                    return result
                })
                completionHandler()
            }
        }
    }
    
    func filterContacts(predicate: String?) {
        let onObtain = {
            var result: [ContactListItemDisplayData]?
            if predicate == nil || predicate!.isEmpty {
                result = self.contacts
            } else {
                result = self.contacts?.filter({ (elem) -> Bool in
                    return elem.name.lowercaseString.containsString(predicate!.lowercaseString)
                })
                result?.append(ContactListItemDisplayData(name: predicate!, isNew: true))
            }
            self.userInterface?.updateContacts(result)
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
                var newBuddies = [String]()
                var buddyIds = [Int]()
                contacts.forEach({ (contact) in
                    if contact.isNew {
                        newBuddies.append(contact.name)
                    } else if let buddyId = contact.buddyId {
                        buddyIds.append(buddyId)
                    }
                })
                self.addNextBuddy(topicId, newBuddies: &newBuddies, buddyIds: &buddyIds)
            }
        }
    }
    
    private func addNextBuddy(topicId: Int, inout newBuddies: [String], inout buddyIds: [Int]) {
        if let contactName = newBuddies.first {
            dataStore.buddiesStore.addBuddy(contactName, completionHandler: { (buddy, error) in
                if let buddy = buddy {
                    buddyIds.append(buddy.id)
                }
                newBuddies.removeFirst()
                self.addNextBuddy(topicId, newBuddies: &newBuddies, buddyIds: &buddyIds)
            })
        } else {
            addNextRelation(topicId, buddyIds: &buddyIds)
        }
    }
    
    private func addNextRelation(topicId: Int, inout buddyIds: [Int]) {
        if let buddyId = buddyIds.first {
            dataStore.topicsStore.addRelation(buddyId, topicId: topicId, completionHandler: { (topic, error) in
                buddyIds.removeFirst()
                self.addNextRelation(topicId, buddyIds: &buddyIds)
            })
        } else {
            userInterface?.savedTopic()
        }
    }
}