//
//  MGPhotoHelper.swift
//  Loustagram
//
//  Created by Kiet on 12/5/17.
//  Copyright © 2017 Kiet. All rights reserved.
//

import UIKit
import Foundation

class MGPhotoHelper: NSObject {

    ///Mark: Properties
    
    var completionHandler: ((UIImage) -> Void)?

    ///Mark: Helper methods
    
    func presentActionSheet(from viewController: UIViewController) {
        let alert = UIAlertController(title: "Where do you want to pick youer picture from?", message: "", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            alert.addAction(capturePhotoAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Up load from library", style: .default, handler: { (action) in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            alert.addAction(uploadAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        viewController.present(imagePickerController, animated: true)
    }
}

extension MGPhotoHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            completionHandler?(selectedImage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}













