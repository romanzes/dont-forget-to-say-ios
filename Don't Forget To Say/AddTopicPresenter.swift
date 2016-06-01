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
    var dataStore: DataStoreProtocol!
    var contactStore: ContactStoreProtocol!
    weak var userInterface: AddTopicViewInterface?
    
    var contacts: [ContactListItemDisplayData]?
    
    private func obtainBuddies(completionHandler: () -> Void) {
        dataStore.fetchBuddies { (buddies, error) in
            if let buddies = buddies {
                self.contacts = buddies.map({ (buddy) -> ContactListItemDisplayData in
                    ContactListItemDisplayData(buddyId: buddy.id, contactId: buddy.contactId, name: buddy.name, phones: buddy.phones, isNew: false)
                })
                completionHandler()
            }
        }
    }
    
    private func obtainContacts(completionHandler: () -> Void) {
        contactStore.loadContacts({ (contacts) in
            let contactsFromPhone = contacts
                .filter({ (contact) -> Bool in
                    self.contacts?.indexOf({ (buddy) -> Bool in
                        buddy.contactId == contact.id
                    }) == nil
                })
                .map({ (contact) -> ContactListItemDisplayData in
                    ContactListItemDisplayData(contactId: contact.id, name: contact.name, phones: contact.phones, isNew: false)
                })
            self.contacts! += contactsFromPhone
            completionHandler()
        })
    }
    
    func filterContacts(predicate: String?) {
        let onObtainedContacts = {
            var result: [ContactListItemDisplayData]?
            if predicate == nil || predicate!.isEmpty {
                result = self.contacts
            } else {
                result = self.contacts?.filter({ (elem) -> Bool in
                    return elem.name.lowercaseString.containsString(predicate!.lowercaseString)
                })
                result?.append(ContactListItemDisplayData(name: predicate!, isNew: true))
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.userInterface?.updateContacts(result)
            }
        }
        let onObtainedBuddies = {
            self.obtainContacts(onObtainedContacts)
        }
        if contacts == nil {
            obtainBuddies(onObtainedBuddies)
        } else {
            onObtainedContacts()
        }
    }
    
    func saveTopicWithText(text: String, contacts: Set<ContactListItemDisplayData>) {
        var newBuddies = [ContactListItemDisplayData]()
        var buddyIds = [Int]()
        contacts.forEach({ (contact) in
            if let buddyId = contact.buddyId {
                buddyIds.append(buddyId)
            } else {
                newBuddies.append(contact)
            }
        })
        addBuddies(newBuddies) { buddies in
            buddies.forEach({ (buddy) in
                buddyIds.append(buddy.id)
            })
            self.dataStore.addTopic(text, buddyIds: buddyIds) { (topic, error) in
                if topic != nil {
                    self.userInterface?.savedTopic()
                }
            }
        }
    }
    
    private func addBuddies(newBuddies: [ContactListItemDisplayData], completionHandler: (buddies: [Buddy]) -> Void) {
        var buddyQueue = newBuddies
        var buddies = [Buddy]()
        var addNextBuddy: (() -> Void)!
        addNextBuddy = {
            if let buddy = buddyQueue.first {
                self.dataStore.addBuddy(buddy.name, contactId: buddy.contactId, phones: buddy.phones) { (buddy, error) in
                    if let buddy = buddy {
                        buddies.append(buddy)
                    }
                    buddyQueue.removeFirst()
                    addNextBuddy()
                }
            } else {
                completionHandler(buddies: buddies)
            }
        }
        addNextBuddy()
    }
}