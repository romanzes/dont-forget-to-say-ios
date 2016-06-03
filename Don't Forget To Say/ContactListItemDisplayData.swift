//
//  ContactListItemDisplayData.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/6/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

class ContactListItemDisplayData: Hashable {
    var buddyId: String?
    var contactId: String?
    var name: String
    var phones: [Phone]
    var isNew: Bool
    
    init(buddyId: String? = nil, contactId: String? = nil, name: String, phones: [Phone] = [], isNew: Bool) {
        self.buddyId = buddyId
        self.contactId = contactId
        self.name = name
        self.phones = phones
        self.isNew = isNew
    }
    
    var hashValue: Int {
        get {
            var hashString = name
            if let buddyId = buddyId {
                hashString += buddyId
            }
            if let contactId = contactId {
                hashString += contactId
            }
            return hashString.hashValue
        }
    }
}

func ==<T where T: ContactListItemDisplayData>(lhs: T, rhs: T) -> Bool {
    return lhs.buddyId == rhs.buddyId && lhs.name == rhs.name && lhs.isNew == rhs.isNew
}