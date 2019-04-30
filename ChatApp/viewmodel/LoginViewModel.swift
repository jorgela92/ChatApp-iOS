//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 12/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation

protocol FirebaseAuthViewModelDelegate: AnyObject {
    func login()
    func register()
    func error(error: String, sign: Bool)
}

final class LoginViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var loginViewControllerDelegate: LoginViewControllerDelegate?
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?
    
    init() {
        self.loginViewControllerDelegate = self
    }
    
}

extension LoginViewModel: LoginViewControllerDelegate {
    
    func buttonClicked(tag: Int, email: String?, password: String?) {
        switch tag {
        case 0:
            self.firebaseViewModel.signUser(email: email, password: password, completion: {
                self.firebaseAuthViewModelDelegate?.login()
            }, failure: { (error) in
                self.firebaseAuthViewModelDelegate?.error(error: error, sign: true)
            })
            break
        case 1:
            self.firebaseViewModel.registerUser(email: email, password: password, completion: {
                self.firebaseAuthViewModelDelegate?.register()
            }, failure: { (error) in
                self.firebaseAuthViewModelDelegate?.error(error: error, sign: false)
            })
            break
        default:
            break
        }
    }
}
