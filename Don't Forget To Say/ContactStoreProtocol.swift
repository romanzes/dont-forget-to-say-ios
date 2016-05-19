//
//  ContactStoreProtocol.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/18/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol ContactStoreProtocol {
    func loadContacts(completionHandler: [Contact] -> Void)
}