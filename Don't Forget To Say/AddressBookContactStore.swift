//
//  AddressBookContactStore.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/18/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import SwiftAddressBook

class AddressBookContactStore: ContactStoreProtocol {
    func loadContacts(completionHandler: [Contact] -> Void) {
        SwiftAddressBook.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                var contacts = [Contact]()
                if let people = swiftAddressBook?.allPeople {
                    for person in people {
                        if let name = person.compositeName, let numbers = person.phoneNumbers {
                            let phones = numbers.map({ (phone) -> Phone in
                                var localizedLabel: String? = nil
                                if let label = phone.label {
                                    localizedLabel = ABAddressBookCopyLocalizedLabel(label).takeRetainedValue() as String
                                }
                                return Phone(title: localizedLabel, number: phone.value)
                            })
                            contacts += [Contact(id: "\(person.recordID)", name: name, phones: phones)]
                        }
                    }
                }
                completionHandler(contacts)
            }
            else {
                completionHandler([])
            }
        })
    }
}