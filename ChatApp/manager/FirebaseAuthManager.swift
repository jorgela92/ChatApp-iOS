//
//  FirebaseAuthManager.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAuthManager {
    
    init() {
        
    }
    
    func sign(email: String?, password: String?, completion: @escaping((_ authResult: AuthDataResult?, _ error: Error?) -> Void)) {
        Auth.auth().signIn(withEmail: email ?? "", password: password ?? "") { (user, error) in
            completion(user, error)
        }
    }
    
    func signOut(completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            failure(error.localizedDescription)
        }
    }
    
    func register(email: String?, password: String?, completion: @escaping((_ authResult: AuthDataResult?, _ error: Error?) -> Void)){
        Auth.auth().createUser(withEmail: email ?? "", password: password ?? "") { (authResult, error) in
            completion(authResult, error)
        }
    }
    
    func getCurrentUser() -> String{
        return Auth.auth().currentUser?.email ?? ""
    }
    
    func getStateDidChangeListener(completion: @escaping((_ auth: Auth?, _ user: User?) -> Void), failure: @escaping((_ error: String) -> Void)){
        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            completion(auth, user)
        }
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
