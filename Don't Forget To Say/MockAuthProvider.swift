//
//  MockAuthProvider.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/31/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Async

public class MockAuthProvider: AuthProvider {
    // MARK: Properties
    var authCallback: (authorized: Bool) -> Void = {_ in }
    var authorized: Bool = false
    
    func setAuthCallback(authCallback: (authorized: Bool) -> Void) {
        self.authCallback = authCallback
    }
    
    func isAuthorized() -> Bool {
        return authorized
    }
    
    private func setAuthorized(authorized: Bool) {
        Async.main(after: 3) {
            self.authorized = authorized
            self.authCallback(authorized: authorized)
        }
    }
    
    func signIn() {
        setAuthorized(true)
    }
    
    func signOut() {
        setAuthorized(false)
    }
}