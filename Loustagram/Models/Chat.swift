//
//  Chat.swift
//  Loustagram
//
//  Created by Kiet on 12/22/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class Chat {
    
    // MARK - Properties
    
    var key: String?
    let title: String
    let memberHash: String
    let memberUIDs: [String]
    var lastMessage: String?
    var lastMessageSent: Date?
    

    
    // MARK: - Init
    
    init?(snapshot: DataSnapshot) {
        guard !snapshot.key.isEmpty,
            let dict = snapshot.value as? [String : Any],
            let title = dict["title"] as? String,
            let memberHash = dict["memberHash"] as? String,
            let membersDict = dict["members"] as? [String : Bool],
            let lastMessage = dict["lastMessage"] as? String,
            let lastMessageSent = dict["lastMessageSent"] as? TimeInterval
            else { return nil }
        
        self.key = snapshot.key
        self.title = title
        self.memberHash = memberHash
        self.memberUIDs = Array(membersDict.keys)
        self.lastMessage = lastMessage
        self.lastMessageSent = Date(timeIntervalSince1970: lastMessageSent)
    }
    
    init(members: [User]){
        // 1. Assert that there are only two members in a chat
        assert(members.count == 2, "There must be two members in a chat.")
        
        // 2. Create the chat title using the usernames of each member.
        self.title = members.reduce("") { (acc, cur) -> String in
            return acc.isEmpty ? cur.username : "\(acc), \(cur.username)"
        }
        // 3. Store a hash value that will prevent users from creating duplicate chats between users
        self.memberHash = Chat.hash(forMembers: members)
        
        // 4. Store each member's UID. this will allow us to easily update our denormalized chats when we create a service method for sending messages.
        self.memberUIDs = members.map { $0.uid }
    }
    
    // MARK: - Class Methods
    
    static func hash(forMembers members: [User]) -> String {
        guard members.count == 2 else {
            fatalError("There must be two members to compute member hash.")
        }
        
        let firstMember = members[0]
        let secondMember = members[1]
        
        let memberHash = String(firstMember.uid.hashValue ^ secondMember.uid.hashValue)
        return memberHash
    }
}







