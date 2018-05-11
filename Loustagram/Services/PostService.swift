//
//  PostService.swift
//  Loustagram
//
//  Created by Kiet on 12/5/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

@available(iOS 10.0, *)
struct PostService {
    
    // creating a post.
    
    static func create(for image: UIImage) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            print("image url: \(urlString)")
            create(forURLString: urlString, aspectHeight: aspectHeight)
        }
    }
    
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        let currentUser = User.current
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        // 1 create references to the important locations that we're planning to write data.
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // 2. Use our class method to get an array of all of our follower UIDs
        UserService.followers(for: currentUser) { (followerUIDs) in
            
            // 3. construct a timeline JSON object where we store our current user's uid
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // 4. We create a mutable dictionary that will store all of the data we want to write to our database.
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // 5. We add our post to each of our follower's timelines.
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // 6. We make sure to write the post we are trying to create.
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // 7. We write our multi-location update to our database.
            rootRef.updateChildValues(updatedData, withCompletionBlock: { (error, ref) in
                let postCountRef = Database.database().reference().child("users").child(currentUser.uid).child("post_count")
                
                postCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    let currentCount = mutableData.value as? Int ?? 0
                    
                    mutableData.value = currentCount + 1
                    
                    return TransactionResult.success(withValue: mutableData)
                })
            })
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
    static func flag(_ post: Post) {
        // 1
        guard let postKey = post.key else { return }
        
        // 2
        let flaggedPostRef = Database.database().reference().child("flaggedPosts").child(postKey)
        
        // 3
        let flaggedDict = ["image_url": post.imageURL,
                           "poster_uid": post.poster.uid,
                           "reporter_uid": User.current.uid]
        
        // 4
        flaggedPostRef.updateChildValues(flaggedDict)
        
        // 5
        let flagCountRef = flaggedPostRef.child("flag_count")
        flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
            let currentCount = mutableData.value as? Int ?? 0
            
            mutableData.value = currentCount + 1
            
            return TransactionResult.success(withValue: mutableData)
        })
    }
    
}






