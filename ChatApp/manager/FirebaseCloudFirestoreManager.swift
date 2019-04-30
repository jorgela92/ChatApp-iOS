//
//  FirebaseCloudFirestoreManager.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class FirebaseCloudFirestoreManager {
    
    init() {
        
    }
    
    //USERS//
    func setUser(userArray: [String], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        var arrayU: [String] = userArray
        self.getUsers(completion: { (arrayUsers) in
            arrayU.append(contentsOf: arrayUsers)
            self.setArrayUser(arrayUser: Array(Set(arrayU)), completion: {
                completion()
            }, failure: {(error) in
                failure(error)
            })
        }) { (error) in
            self.setArrayUser(arrayUser: Array(Set(arrayU)), completion: {
                completion()
            }, failure: {(error) in
                failure(error)
            })
        }
    }
    
    private func setArrayUser(arrayUser: [String], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("chatusers").document("users").setData(["users": arrayUser]) { (error) in
            if let error = error{
                failure(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
    
    private func getUsers(completion: @escaping((_ arrayUsers: [String]) -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("chatusers").document("users").getDocument(completion: { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else{
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        completion(try FirebaseDecoder().decode([String].self, from: documentSnapshot.data()?["users"] as Any))
                    } catch {
                        failure(error.localizedDescription)
                    }
                } else {
                    failure("")
                }
                
            }
        })
    }
    
    func updateUser(completion: @escaping((_ users: [String]) -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("chatusers").document("users").addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        completion(try FirebaseDecoder().decode([String].self, from: documentSnapshot.data()?["users"] as Any))
                    } catch {
                        failure(error.localizedDescription)
                    }
                } else {
                    failure("")
                }
            }
        }
    }
    //USERS//
    
    //CONVERSATION//
    func setConversation(conversation: [String: Conversation], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        for identifier in conversation.keys{
            do {
                Firestore.firestore().collection("conversations").document(identifier).setData(["messages" : try FirebaseEncoder().encode(conversation[identifier]?.messages) as Any]) { (error) in
                    if let error = error {
                        failure(error.localizedDescription)
                    } else {
                        completion()
                    }
                }
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    func getConversations(completion: @escaping((_ dataSnapshot: [String: Conversation]) -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("conversations").getDocuments { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else{
                if let documentSnapshot = documentSnapshot, documentSnapshot.count > 0 {
                    var conversationsDictionary: [String: Conversation] = [String: Conversation]()
                    for document in documentSnapshot.documents {
                        do {
                            conversationsDictionary[document.documentID] = Conversation(messages: try FirebaseDecoder().decode([Message].self, from: document.data()["messages"] as Any))
                        } catch {
                            failure(error.localizedDescription)
                        }
                    }
                    completion(conversationsDictionary)
                    
                } else {
                    failure("")
                }
            }
        }
    }
    //CONVERSATION//
    
    //MESSAGE CONVERSATION//
    func setMessage(identifier: String, message: Message, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        self.getMessages(identifier: identifier, completion: { (messages, identifier) in
            var arrayMessages: [Message] = messages
            arrayMessages.append(message)
            do{
                Firestore.firestore().collection("conversations").document(identifier).setData(["messages":try FirebaseEncoder().encode(arrayMessages)], completion: { (error) in
                    completion()
                })
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    private func getMessages(identifier: String, completion: @escaping((_ messages: [Message], _ identifier: String) -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("conversations").document(identifier).getDocument{ (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else{
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        completion(try FirebaseDecoder().decode([Message].self, from: documentSnapshot.data()?["messages"] as Any), identifier)
                    } catch {
                        failure(error.localizedDescription)
                    }
                } else {
                    failure("")
                }
            }
        }
    }
    
    func updateMessage(identifier: String, completion: @escaping((_ message: [Message], _ identifier: String) -> Void), failure: @escaping((_ error: String) -> Void)){
        Firestore.firestore().collection("conversations").document(identifier).addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        completion(try FirebaseDecoder().decode([Message].self, from: documentSnapshot.data()?["messages"] as Any), identifier)
                    } catch {
                        failure(error.localizedDescription)
                    }
                } else {
                    failure("")
                }
            }
        }
    }
    //MESSAGE CONVERSATION//
    
}
