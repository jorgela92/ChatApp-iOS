//
//  UsersViewModel.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 12/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import UIKit

protocol FirebaseUsersViewModelDelegate: AnyObject {
    func reloadTableView()
    func error(error: String)
    func imagePickerControllerDidCancel()
}

final class UsersViewModel: NSObject {
    
    var firebaseViewModel: FirebaseViewModel?
    var usersViewControllerDelegate: UsersViewControllerDelegate?
    var firebaseUsersViewModelDelegate: FirebaseUsersViewModelDelegate?
    
    init(firebaseViewModel: FirebaseViewModel) {
        super.init()
        self.firebaseViewModel = firebaseViewModel
        self.usersViewControllerDelegate = self
    }
    
    func getUserArrayNumber() -> Int {
        return firebaseViewModel?.getUserArrayNumber() ?? 0
    }
    
    func getUser(index: Int) -> String {
        return firebaseViewModel?.getUserArrayData(index: index) ?? ""
    }
    
    func downloadImagenFirebaseProfileUser(image: UIImageView, index: Int) {
        self.firebaseViewModel?.downloadImagenFirebaseProfileUser(user: SwiftUtils().shortUser(user: getUser(index: index)), imagenView: image, placeholder: UIImage(named: "profile")!)
    }
}

extension UsersViewModel: UsersViewControllerDelegate {
    func uploadImage(image: UIImage) {
        firebaseViewModel?.uploadImageFirebaseUserProfile(image: image)
    }
    
    
    func logaut(){
        firebaseViewModel?.logautUser()
    }
    
    func updateUser(){
        self.firebaseViewModel?.updateUserFirebase(completion: { () in
            self.firebaseUsersViewModelDelegate?.reloadTableView()
        }, failure: { (error) in
            self.firebaseUsersViewModelDelegate?.error(error: error)
        })
    }
}

extension UsersViewModel:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        usersViewControllerDelegate?.uploadImage(image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        firebaseUsersViewModelDelegate?.imagePickerControllerDidCancel()
    }
}

