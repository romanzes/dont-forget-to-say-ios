//
//  Buddy.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

struct Buddy {
    let id: Int
    let contactId: String?
    let name: String
    
    init(id: Int, contactId: String? = nil, name: String) {
        self.id = id
        self.contactId = contactId
        self.name = name
    }
}