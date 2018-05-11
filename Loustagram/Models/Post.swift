//
//  Post.swift
//  Loustagram
//
//  Created by Kiet on 12/7/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase.FIRDataSnapshot

class Post: MGKeyed {
    
    var likeCount: Int
    let poster: User
    var isLiked = false
    
    var key: String?
    let imageURL: String
    let imageHeight: CGFloat
    let creationDate: Date
    

    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username]
        
        return ["image_url" : imageURL,
                "image_height" : imageHeight,
                "created_at" : createdAgo,
                "like_count" : likeCount,
                "poster" : userDict]
    }
    
    init(imageURL: String, imageHeight: CGFloat) {
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date()
        
        self.likeCount = 0
        self.poster = User.current

    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let imageURL = dict["image_url"] as? String,
            let imageHeight = dict["image_height"] as? CGFloat,
            let createdAgo = dict["created_at"] as? TimeInterval,
            
            let likeCount = dict["like_count"] as? Int,
            let userDict = dict["poster"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String
            else { return nil }

        
        self.key = snapshot.key
        self.imageURL = imageURL
        self.imageHeight = imageHeight
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
        
        self.likeCount = likeCount
        self.poster = User(uid: uid, username: username)

    }
    
    // create new post in database

    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        
        ///1 Create a reference to the current user for taking user uid
        let currentUser = User.current
        
        ///2 Initialize a new Post using the data passed in by the parameters.
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        ///3 Convert the new post object into a dictionary so that it can be written as JSON in our database.
        let dict = post.dictValue
        
        ///4 Construct the relative path to the location where we want to store the new post data.
        let postReference = Database.database().reference().child("posts").child(currentUser.uid).childByAutoId()
        
        ///5 Write the data to the specified location.
        postReference.updateChildValues(dict)
    }

}








