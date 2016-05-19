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
                        if let name = person.compositeName {
                            contacts += [Contact(id: person.recordID, name: name)]
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