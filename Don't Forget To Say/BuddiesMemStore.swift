//
//  BuddiesMemStore.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

class BuddiesMemStore: BuddiesStoreProtocol {
    // MARK: - Data
    
    private var buddies = [
        Buddy(id: 1, name: "Roman Petrenko"),
        Buddy(id: 2, name: "Andrei Senchuk"),
        Buddy(id: 3, name: "Гурбангулы Мяликулиевич Бердымухаммедов")
    ]
    
    // MARK: - CRUD operations - Optional error
    
    func fetchBuddies(completionHandler: (buddies: [Buddy], error: CrudStoreError?) -> Void) {
        completionHandler(buddies: buddies, error: nil)
    }
}