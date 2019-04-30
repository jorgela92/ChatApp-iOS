//
//  Conversation.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation

struct FirebaseData: Codable {
    var conversations: [String: Conversation] = [String: Conversation]()
    var users: [String] = [String]()
    
    func shortUser(user: String) -> String {
        var currentUser = user
        if let indexSender = (currentUser.range(of: "@")?.lowerBound){
            currentUser = String(currentUser.prefix(upTo: indexSender))
        }
        return currentUser
    }
}

struct Conversation: Codable, Hashable {
    var messages: [Message] = [Message]()
    
    init(messages: [Message]) {
        self.messages = messages
    }
    
    init(){
        
    }
    
    mutating func appendMessage(message: String, user: String, hour: String) {
        self.messages.append(Message(message: message, user: user, hour: hour))
    }
}

struct Message: Codable, Hashable {
    var message: String = ""
    var user: String = ""
    var hour: String = ""
    
    
    init(message: String, user: String, hour: String) {
        self.message = message
        self.user = user
        self.hour = hour
    }
}
