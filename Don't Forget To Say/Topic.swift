//
//  Topic.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/3/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

struct Topic {
    let id: String
    let text: String
    let buddyCount: Int
    
    init(id: Int, text: String, buddyCount: Int) {
        self.init(id: "\(id)", text: text, buddyCount: buddyCount)
    }
    
    init(id: String, text: String, buddyCount: Int) {
        self.id = id
        self.text = text
        self.buddyCount = buddyCount
    }
}