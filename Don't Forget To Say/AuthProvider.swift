//
//  AuthProvider.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/30/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation

protocol AuthProvider {
    func setAuthCallback(authCallback: (authorized: Bool) -> Void)
    func isAuthorized() -> Bool
    func signIn()
    func signOut()
}
