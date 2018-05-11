//
//  StorageReference+Post.swift
//  Loustagram
//
//  Created by Kiet on 12/7/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import FirebaseStorage

@available(iOS 10.0, *)
extension StorageReference {
    
    static let dateFormater = ISO8601DateFormatter()
    
    static func newPostImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormater.string(from: Date())
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
    
}
