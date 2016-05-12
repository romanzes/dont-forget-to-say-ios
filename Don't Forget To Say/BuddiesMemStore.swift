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
    
    private var freeId = 8
    
    private var buddies = [
        Buddy(id: 1, name: "Roman Petrenko"),
        Buddy(id: 2, name: "Andrei Senchuk"),
        Buddy(id: 3, name: "Гурбангулы Мяликулиевич Бердымухаммедов"),
        Buddy(id: 4, name: "Yuliya Charkasava"),
        Buddy(id: 5, name: "Mikhail Aksionchyk"),
        Buddy(id: 6, name: "Vladimir Putin"),
        Buddy(id: 7, name: "Barack Obama")
    ]
    
    // MARK: - CRUD operations - Optional error
    
    func fetchBuddies(completionHandler: (buddies: [Buddy]?, error: CrudStoreError?) -> Void) {
        completionHandler(buddies: buddies, error: nil)
    }
    
    func fetchBuddy(id: Int, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let buddy = buddies.filter { (buddy: Buddy) -> Bool in
            return buddy.id == id
            }.first
        if let _ = buddy {
            completionHandler(buddy: buddy, error: nil)
        } else {
            completionHandler(buddy: nil, error: CrudStoreError.CannotFetch("Cannot fetch buddy with id \(id)"))
        }
    }
    
    func addBuddy(name: String, completionHandler: (buddy: Buddy?, error: CrudStoreError?) -> Void) {
        let newBuddy = Buddy(id: freeId, name: name)
        buddies += [newBuddy]
        freeId += 1
        completionHandler(buddy: newBuddy, error: nil)
    }
}