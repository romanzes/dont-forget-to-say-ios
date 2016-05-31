//
//  FirebaseAuthProvider.swift
//  Dont Forget To Say
//
//  Created by mac-132 on 5/30/16.
//  Copyright © 2016 Romanzes. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI

public class FirebaseAuthProvider: NSObject, AuthProvider, FIRAuthUIDelegate {
    // MARK: Properties
    var callback: (authorized: Bool) -> Void = { _ in }
    var authorized: Bool = false
    
    override init() {
        super.init()
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            self.authorized = user != nil
            self.callback(authorized: self.authorized)
        })
    }
    
    func setAuthCallback(authCallback: (authorized: Bool) -> Void) {
        callback = authCallback
        if let ui = FIRAuthUI.authUI() {
            ui.delegate = self
        }
    }
    
    func isAuthorized() -> Bool {
        return authorized
    }
    
    func signIn() {
        if let authViewController = FIRAuthUI.authUI()?.authViewController() {
            let window = UIApplication.sharedApplication().keyWindow
            window?.rootViewController?.presentViewController(authViewController, animated: true, completion: nil)
        }
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {}
    }
    
    public func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
        callback(authorized: authorized)
    }
}