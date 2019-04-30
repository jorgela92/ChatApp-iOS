//
//  FirebaseDatabaseManager.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class FirebaseDatabaseManager {
    
    init() {
        
    }
    //USERS//
    func setUser(userArray: [String]){
        self.getUsers(completion: { (arrayUsers) in
            var arrayU: [String] = arrayUsers
            arrayU.append(contentsOf: userArray)
            self.setArrayUser(arrayUser: Array(Set(arrayU)))
        }) { (error) in
            self.setArrayUser(arrayUser: userArray)
            print(error)
        }
    }
    
    private func setArrayUser(arrayUser: [String]){
        Database.database().reference().child("users").setValue(arrayUser)
    }
    
    private func getUsers(completion: @escaping((_ arrayUsers: [String]) -> Void), failure: @escaping((_ error: String) -> Void)){
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            do {
                completion(try FirebaseDecoder().decode([String].self, from: dataSnapshot.value as Any))
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    
    func updateUser(completion: @escaping((_ user: String, _ index: Int) -> Void), failure: @escaping((_ error: String) -> Void)){
        Database.database().reference().child("users").observe(.childAdded, with: { (dataSnapshot) in
            do {
                completion(try FirebaseDecoder().decode(String.self, from: dataSnapshot.value as Any), Int(dataSnapshot.key) ?? -1)
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    //USERS//
    
    //CONVERSATION//
    func setConversation(conversation: [String: Conversation]) {
        do{
            Database.database().reference().child("conversations").setValue(try FirebaseEncoder().encode(conversation), withCompletionBlock: { (error, databaseReference) in
                if error != nil{
                    print(error.debugDescription)
                }
            })
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func getConversations(completion: @escaping((_ dataSnapshot: [String: Conversation]) -> Void), failure: @escaping((_ error: String) -> Void)){
        Database.database().reference().child("conversations").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            do {
                completion(try FirebaseDecoder().decode([String: Conversation].self, from: dataSnapshot.value as Any))
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    //CONVERSATION//
    
    //MESSAGE CONVERSATION//
    private func getMessages(identifier: String, completion: @escaping((_ messages: [Message], _ identifier: String) -> Void), failure: @escaping((_ error: String) -> Void)){
        Database.database().reference().child("conversations").child(identifier).child("messages").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            do {
                completion(try FirebaseDecoder().decode([Message].self, from: dataSnapshot.value as Any), identifier)
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    
    func setMessage(identifier: String, message: Message){
        self.getMessages(identifier: identifier, completion: { (messages, identifier) in
            var arrayMessages: [Message] = messages
            arrayMessages.append(message)
            do{
                Database.database().reference().child("conversations").child(identifier).child("messages").setValue(try FirebaseEncoder().encode(arrayMessages))
            } catch {
                print(error.localizedDescription)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func updateMessage(identifier: String, completion: @escaping((_ message: Message, _ identifier: String, _ index: Int) -> Void), failure: @escaping((_ error: String) -> Void)){
        Database.database().reference().child("conversations").child(identifier).child("messages").observe(.childAdded, with: { (dataSnapshot) in
            do {
                completion(try FirebaseDecoder().decode(Message.self, from: dataSnapshot.value as Any), identifier, Int(dataSnapshot.key) ?? -1)
            } catch {
                failure(error.localizedDescription)
            }
        }) { (error) in
            failure(error.localizedDescription)
        }
    }
    //MESSAGE CONVERSATION//
}
