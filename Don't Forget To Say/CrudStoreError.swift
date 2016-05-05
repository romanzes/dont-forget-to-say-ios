//
//  CrudStoreError.swift
//  Don't Forget To Say
//
//  Created by mac-132 on 5/4/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

enum CrudStoreError: ErrorType {
    case CannotFetch(String)
    case CannotCreate(String)
    case CannotUpdate(String)
    case CannotDelete(String)
}