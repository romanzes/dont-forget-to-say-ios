//
//  ModernContactStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/19/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
class ModernContactStore: ContactStoreProtocol {
    func loadContacts(completionHandler: [Contact] -> Void) {
        let contactStore = CNContactStore()
        contactStore.requestAccessForEntityType(CNEntityType.Contacts) { (granted, error) in
            if granted {
                completionHandler(self.loadContactsImpl(contactStore))
            } else {
                completionHandler([])
            }
        }
    }
    
    private func loadContactsImpl(contactStore: CNContactStore) -> [Contact] {
        let keysToFetch = [ CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey ]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var contacts: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                contacts.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        var result = [Contact]()
        for contact in contacts {
            if let name = CNContactFormatter.stringFromContact(contact, style: CNContactFormatterStyle.FullName) {
                let phones = contact.phoneNumbers
                    .filter({ (phone) -> Bool in
                        phone.value is CNPhoneNumber
                    })
                    .map({ (phone) -> Phone in
                        Phone(title: CNLabeledValue.localizedStringForLabel(phone.label), number: (phone.value as! CNPhoneNumber).stringValue)
                    })
                result.append(Contact(id: contact.identifier, name: name, phones: phones))
            }
        }
        return result
    }
}