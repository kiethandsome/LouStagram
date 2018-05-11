//
//  User.swift
//  Loustagram
//
//  Created by Kiet on 12/1/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    
    var isFollowed = false
    var followerCount: Int?
    var followingCount: Int?
    var postCount: Int?
    
    let uid: String
    let username: String
    
    private static var _currentUser: User?
    
    static var current: User { /// Get only varriable
        guard let currentUser = _currentUser else {
            fatalError("Error: current user doesnt exsist")
        }
        return currentUser
    }
    
    /// Init methods
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
            let followerCount = dict["follower_count"] as? Int,
            let followingCount = dict["following_count"] as? Int,
            let postCount = dict["post_count"] as? Int
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        
        super.init()
    }

    /// MARK: Class Method
    
    static func setCurrent(_ user: User) {
        _currentUser = user
    }
    
    class func setCurrent(_ user: User, writeToUserDefalt: Bool = false) {
        if writeToUserDefalt {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        _currentUser = user
    }

}


extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
}









