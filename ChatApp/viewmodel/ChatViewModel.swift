//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 12/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import UIKit

protocol FirebaseChatViewModelDelegate: AnyObject {
    func reloadTableView()
    func error(error: String)
    func imagePickerControllerDidCancel()
    func showHUD()
    func dismiss()
    func textViewDidBeginEditing()
    func textViewDidChange(textView: UITextView)
}

final class ChatViewModel: NSObject {
    
    private var userReceiver: String?
    private var firebaseViewModel: FirebaseViewModel?
    var chatViewControllerDelegate: ChatViewControllerDelegate?
    var firebaseChatViewModelDelegate: FirebaseChatViewModelDelegate?
    
    init(firebaseViewModel: FirebaseViewModel, userReceiver: String) {
        super.init()
        self.firebaseViewModel = firebaseViewModel
        self.userReceiver = userReceiver
        chatViewControllerDelegate = self
    }
    
    func getConversationMessagesNumber() -> Int {
        return firebaseViewModel?.getConversationMessagesNumber(userReceiver: userReceiver ?? "") ?? 0
    }
    
    private func getConversationMessages(index: Int) -> Message? {
        return firebaseViewModel?.getConversationMessages(index: index, userReceiver: userReceiver ?? "")
    }
    
    func getConversationMessageUser(index: Int) -> String {
        return SwiftUtils().shortUser(user: getConversationMessages(index: index)?.user ?? "")
    }
    
    func getConversationMessageHour(index: Int) -> String {
        return SwiftUtils().formatHour(dateString: getConversationMessages(index: index)?.hour ?? "")
    }
    
    func getConversationMessageMessage(index: Int) -> String {
        return getConversationMessages(index: index)?.message ?? ""
    }
    
    func getCurrentUser() -> String {
        return SwiftUtils().shortUser(user: firebaseViewModel?.getCurrentUser() ?? "")
    }
    
    func getUserReceiver() -> String {
        return userReceiver ?? ""
    }
    
    func downloadImagenFirebase(image: UIImageView, index: Int, placeholder: String) {
        firebaseViewModel?.downloadImagenFirebase(conversation: firebaseViewModel?.getConversationKey(userReceiver: userReceiver ?? "") ?? "", name: firebaseViewModel?.getConversationMessages(index: index, userReceiver: userReceiver ?? "")?.message ?? "", imagenView: image, placeholder: UIImage(named: placeholder)!)
        
    }
    
    func downloadImagenFirebaseProfileUser(image: UIImageView, index: Int, placeholder: String) {
        if !getConversationMessageUser(index: index).elementsEqual(getConversationMessageUser(index: index - 1)) {
            firebaseViewModel?.downloadImagenFirebaseProfileUser(user: getConversationMessageUser(index: index), imagenView: image, placeholder: UIImage(named: placeholder)!)
        } else {
            image.isHidden = true
        }
    }
}

extension ChatViewModel: ChatViewControllerDelegate {
    
    func updateMessage(userReceiver: String) {
        done(userReciver: userReceiver)
        firebaseViewModel?.updateMessageFirebase(userReceiver: userReceiver, completion: {
            self.firebaseChatViewModelDelegate?.reloadTableView()
        }, failure: {(error) in
            self.firebaseChatViewModelDelegate?.error(error: error)
        })
    }
    
    func buttonClicked(userReceiver: String, message: String, image: UIImage?) {
        firebaseChatViewModelDelegate?.showHUD()
        firebaseViewModel?.setMessageFirebase(userReceiver: userReceiver, message: message, iamge: image, completion: {
            self.firebaseChatViewModelDelegate?.dismiss()
        }, failure: { (error) in
            self.firebaseChatViewModelDelegate?.error(error: error)
        })
    }
    
    func done(userReciver: String){
        if let firebaseViewModel = firebaseViewModel {
            if firebaseViewModel.firebaseData.conversations.keys.contains(firebaseViewModel.getStringIdentifier(user: userReciver)) {
                firebaseViewModel.firebaseData.conversations[firebaseViewModel.getStringIdentifier(user: userReciver)]?.messages = [Message]()
            }
            if firebaseViewModel.firebaseData.conversations.keys.contains(firebaseViewModel.getStringIdentifier(user: userReciver, rotate: false)){
                firebaseViewModel.firebaseData.conversations[firebaseViewModel.getStringIdentifier(user: userReciver, rotate: false)]?.messages = [Message]()
            }
        }
    }
}

extension ChatViewModel: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.firebaseChatViewModelDelegate?.textViewDidBeginEditing()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        firebaseChatViewModelDelegate?.textViewDidChange(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}

extension ChatViewModel:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        chatViewControllerDelegate?.buttonClicked(userReceiver: userReceiver ?? "", message: "image-", image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
    }
}

