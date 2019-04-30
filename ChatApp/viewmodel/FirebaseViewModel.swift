//
//  FirebaseViewModel.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase
import FirebasePerformance
import MMProgressHUD

final class FirebaseViewModel {
    
    let firebaseAuthManager: FirebaseAuthManager = FirebaseAuthManager()
    //let firebaseDatabaseManager: FirebaseDatabaseManager = FirebaseDatabaseManager()
    let firebaseCloudFirestoreManager: FirebaseCloudFirestoreManager = FirebaseCloudFirestoreManager()
    let firebaseStorageManager: FirebaseStorageManager = FirebaseStorageManager()
    
    var firebaseData: FirebaseData = FirebaseData()
    private var indexConversations: Int = 0
    
    private var trace: Trace?
    
    init() {
        
    }
    
    //AUTH USER//
    func signUser(email: String?, password: String?, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        if let email = email {
            trace = Performance.startTrace(name: "Trace User: \(email)")
        }
        firebaseAuthManager.sign(email: email, password: password) { (authResult, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
    
    func registerUser(email: String?, password: String?, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        firebaseAuthManager.register(email: email, password: password) { (authResult, error) in
            if let authResult = authResult, let emailString = authResult.user.email{
                self.firebaseData.users.append(emailString)
                self.firebaseCloudFirestoreManager.setUser(userArray: self.firebaseData.users, completion:{
                    completion()
                }, failure: ({ (error) in
                    failure(error)
                }))
            } else {
                if let error: Error = error{
                    failure(error.localizedDescription)
                }
            }
        }
    }
    
    func logautUser(){
        MMProgressHUD.show()
        firebaseAuthManager.signOut(completion: {
            self.trace?.stop()
            self.firebaseData = FirebaseData()
            MMProgressHUD.dismiss()
        }) { (error) in
            MMProgressHUD.dismissWithError(error)
        }
    }
    //AUTH USER//
    
    //USER DATABASE//
    func updateUserFirebase(completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        trace?.incrementMetric("updateUser", by: 1)
        firebaseCloudFirestoreManager.updateUser(completion: { (users) in
            self.firebaseData.users = users
            completion()
            self.getConversations(completion: {
                completion()
            }, failure: { (error) in
                failure(error)
            })
        }, failure: { (error) in
            failure(error)
        })
    }
    
    func getCurrentUser() -> String {
        var currentUser = firebaseAuthManager.getCurrentUser()
        if let indexSender = (currentUser.range(of: "@")?.lowerBound){
            currentUser = String(currentUser.prefix(upTo: indexSender))
        }
        return currentUser
    }
    
    func getUserArrayNumber() -> Int {
        return firebaseData.users.count
    }
    
    func getUserArrayData(index: Int) -> String {
        return firebaseData.users[index]
    }
    //USER DATABASE//
    
    //CONVERSATION DATABASES//
    private func getConversations(completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        trace?.incrementMetric("getConversations", by: 1)
        firebaseCloudFirestoreManager.getConversations(completion: { (conversations) in
            for conversation in conversations {
                self.firebaseData.conversations[conversation.key] = conversation.value
            }
            var setNewConversation: Bool = false
            for user in self.firebaseData.users{
                if !self.firebaseData.conversations.keys.contains(self.getStringIdentifier(user: user)) &&
                    !self.firebaseData.conversations.keys.contains(self.getStringIdentifier(user: user, rotate: false)){
                    self.firebaseData.conversations[self.getStringIdentifier(user: user)] = Conversation(messages: [Message(message: "", user: "", hour: "")])
                    setNewConversation = true
                }
            }
            if setNewConversation {
                self.setNewConversationFirebase(conversation: self.firebaseData.conversations, completion:{
                    self.firebaseCloudFirestoreManager.getConversations(completion: { (conversations) in
                        for conversation in conversations {
                            self.firebaseData.conversations[conversation.key] = conversation.value
                        }
                        completion()
                    }, failure: { (error) in
                        failure(error)
                    })
                }, failure: { (error) in
                    failure(error)
                })
            } else {
                completion()
            }
        }) { (error) in
            for user in self.firebaseData.users {
                self.firebaseData.conversations[self.getStringIdentifier(user: user)] = Conversation(messages: [Message(message: "", user: "", hour: "")])
            }
            self.setNewConversationFirebase(conversation: self.firebaseData.conversations, completion:{
                self.firebaseCloudFirestoreManager.getConversations(completion: { (conversations) in
                    for conversation in conversations {
                        self.firebaseData.conversations[conversation.key] = conversation.value
                    }
                    completion()
                }, failure: { (error) in
                    failure(error)
                })
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    private func setNewConversationFirebase(conversation: [String: Conversation], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        trace?.incrementMetric("setNewConversation", by: 1)
        firebaseCloudFirestoreManager.setConversation(conversation: conversation, completion: {
            completion()
        }) { (error) in
            failure(error)
        }
    }
    
    func getConversationMessagesNumber(userReceiver: String) -> Int {
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver)) {
            return firebaseData.conversations[getStringIdentifier(user: userReceiver)]?.messages.count ?? 0
        }
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver, rotate: false)) {
            return firebaseData.conversations[getStringIdentifier(user: userReceiver, rotate: false)]?.messages.count ?? 0
        }
        return 0
    }
    
    func getConversationMessages(index: Int, userReceiver: String) -> Message? {
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver)) {
            return firebaseData.conversations[getStringIdentifier(user: userReceiver)]?.messages[index]
        }
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver, rotate: false)) {
            return firebaseData.conversations[getStringIdentifier(user: userReceiver, rotate: false)]?.messages[index]
        }
        return nil
    }
    
    func getConversationKey(userReceiver: String) -> String? {
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver)) {
            return getStringIdentifier(user: userReceiver)
        }
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver, rotate: false)) {
            return getStringIdentifier(user: userReceiver, rotate: false)
        }
        return nil
    }
    //CONVERSATION DATABASES//
    
    //MESSAGE CONVERSATION//
    func setMessageFirebase(userReceiver: String, message: String, iamge: UIImage?, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        trace?.incrementMetric("setMessageFirebase", by: 1)
        let imageName: String = self.firebaseStorageManager.randomStringNameImage()
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver)){
            if message.elementsEqual("image-"){
                firebaseStorageManager.uploadImage(conversation: getStringIdentifier(user: userReceiver), name: "\(message)\(imageName)", image: iamge!, completion: {
                    let dfmatter = DateFormatter()
                    dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    self.firebaseCloudFirestoreManager.setMessage(identifier: self.getStringIdentifier(user: userReceiver), message: Message(message: "\(message)\(imageName)", user: self.getCurrentUser(), hour: dfmatter.string(from: Date())), completion: {
                        completion()
                    }, failure: { (error) in
                        failure(error)
                    })
                }) { (error) in
                    failure(error)
                }
            } else {
                let dfmatter = DateFormatter()
                dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                firebaseCloudFirestoreManager.setMessage(identifier: getStringIdentifier(user: userReceiver), message: Message(message: message, user: getCurrentUser(), hour: dfmatter.string(from: Date())), completion:{
                    completion()
                }, failure: { (error) in
                    failure(error)
                })
            }
        } else if firebaseData.conversations.keys.contains(self.getStringIdentifier(user: userReceiver, rotate: false)){
            if message.elementsEqual("image-"){
                let dfmatter = DateFormatter()
                dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                firebaseStorageManager.uploadImage(conversation: getStringIdentifier(user: userReceiver, rotate: false), name: "\(message)\(imageName)", image: iamge!, completion: {
                    self.firebaseCloudFirestoreManager.setMessage(identifier: self.getStringIdentifier(user: userReceiver, rotate: false), message: Message(message: "\(message)\(imageName)", user: self.getCurrentUser(), hour: dfmatter.string(from: Date())), completion: {
                        completion()
                    }, failure: { (error) in
                        failure(error)
                    })
                }) { (error) in
                    
                }
            } else {
                let dfmatter = DateFormatter()
                dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                firebaseCloudFirestoreManager.setMessage(identifier: getStringIdentifier(user: userReceiver, rotate: false), message: Message(message: message, user: getCurrentUser(), hour: dfmatter.string(from: Date())), completion:{
                    completion()
                }, failure: { (error) in
                    failure(error)
                })
            }
        }
    }
    
    func updateMessageFirebase(userReceiver: String, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        trace?.incrementMetric("updateMessage", by: 1)
        if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver)){
            firebaseCloudFirestoreManager.updateMessage(identifier: getStringIdentifier(user: userReceiver), completion: { (messages, identifier)  in
                self.firebaseData.conversations[identifier]?.messages = messages
                completion()
            }) { (error) in
                failure(error)
            }
        } else if firebaseData.conversations.keys.contains(getStringIdentifier(user: userReceiver, rotate: false)){
            firebaseCloudFirestoreManager.updateMessage(identifier: getStringIdentifier(user: userReceiver, rotate: false), completion: { (messages, identifier)  in
                self.firebaseData.conversations[identifier]?.messages = messages
                completion()
            }) { (error) in
                failure(error)
            }
        }
    }
    //MESSAGE CONVERSATION//
    
    func getStringIdentifier(user: String, rotate: Bool = true) -> String{
        if rotate {
            return "\(getCurrentUser())-\(firebaseData.shortUser(user: user))"
        } else {
            return "\(firebaseData.shortUser(user: user))-\(getCurrentUser())"
        }
    }
    
    //STORAGE//
    func uploadImageFirebaseUserProfile(image: UIImage){
        MMProgressHUD.show()
        trace?.incrementMetric("uploadImageUserProfile", by: 1)
        firebaseStorageManager.uploadImageUserProfile(user: getCurrentUser(), image: image, completion: {
            MMProgressHUD.dismiss()
        }, failure: { (error) in
            MMProgressHUD.dismissWithError(error)
        })
    }
    
    func downloadImagenFirebaseProfileUser(user: String, imagenView: UIImageView, placeholder: UIImage){
        trace?.incrementMetric("downloadImagenUserProfile", by: 1)
        firebaseStorageManager.downloadImagenProfileUser(image: user, imagenView: imagenView, placeholder: placeholder)
    }
    
    private func uploadImageFirebase(conversation: String, name:String, image: UIImage, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        trace?.incrementMetric("uploadImage", by: 1)
        firebaseStorageManager.uploadImage(conversation: conversation, name: name, image: image, completion: {
            completion()
        }) { (error) in
            failure(error)
        }
    }
    
    func downloadImagenFirebase(conversation: String, name: String, imagenView: UIImageView, placeholder: UIImage){
        trace?.incrementMetric("downloadImage", by: 1)
        firebaseStorageManager.downloadImagen(conversation: conversation, name: name, imagenView: imagenView, placeholder: placeholder)
    }
    //STORAGE//
}

