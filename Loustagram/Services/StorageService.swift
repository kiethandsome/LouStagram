//
//  StorageService.swift
//  Loustagram
//
//  Created by Kiet on 12/5/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

struct StorageService {
    
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        reference.putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            //3. return the download URL for the image
            completion(metadata?.downloadURL())
        }
    }
}
