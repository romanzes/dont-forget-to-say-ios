//
//  RealmProvider.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/26/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import RealmSwift

class RealmProvider {
    let getRealm: () -> Realm
    
    init (getRealm: () -> Realm) {
        self.getRealm = getRealm
    }
}