//
//  SwiftUtils.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 24/04/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation

final class SwiftUtils {
    
    func shortUser(user: String) -> String {
        var currentUser = user
        if let indexSender = (currentUser.range(of: "@")?.lowerBound) {
            currentUser = String(currentUser.prefix(upTo: indexSender))
        }
        return currentUser
    }
    
    func formatHour(dateString: String) -> String {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dfmatter.date(from: dateString)
        dfmatter.dateFormat = "HH:mm"
        return dfmatter.string(from: date ?? Date())
    }
}
