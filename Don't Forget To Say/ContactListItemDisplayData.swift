//
//  ContactListItemDisplayData.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/6/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

class ContactListItemDisplayData: Hashable {
    var buddyId: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var hashValue: Int {
        get {
            var result = name.hashValue
            if let buddyId = buddyId {
                result += buddyId
            }
            return result
        }
    }
}

func ==<T where T: ContactListItemDisplayData>(lhs: T, rhs: T) -> Bool {
    return lhs.buddyId == rhs.buddyId && lhs.name == rhs.name
}