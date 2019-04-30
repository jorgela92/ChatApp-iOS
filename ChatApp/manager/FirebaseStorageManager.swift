//
//  FirebaseStorageManager.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import Foundation
import FirebaseStorage
import SDWebImage
import FirebaseUI

class FirebaseStorageManager {
    
    private let urlStrorage: String = "gs://wathasapp-9dc3a.appspot.com/"
    
    init() {
        
    }
    
    func uploadImageUserProfile(user: String, image: UIImage, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        if let data = self.resize(image).pngData(){
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            let uploadTask = Storage.storage(url: self.urlStrorage).reference().child("images-chat/profile/\(user).png").putData(data, metadata: metadata) { (metadata, error) in
                guard metadata != nil else {
                    failure(error?.localizedDescription ?? error.debugDescription)
                    return
                }
                completion()
            }
            
            uploadTask.observe(.success) { snapshot in
                completion()
            }
            
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error as NSError? {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        failure(error.localizedDescription)
                        break
                    case .unauthorized:
                        failure(error.localizedDescription)
                        break
                    case .cancelled:
                        failure(error.localizedDescription)
                        break
                    case .unknown:
                        failure(error.localizedDescription)
                        break
                    default:
                        failure(error.localizedDescription)
                        break
                    }
                }
            }
        }
    }
    
    private func resize(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 250.0
        let maxWidth: Float = 250.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.8
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
    func downloadImagenProfileUser(image: String, imagenView: UIImageView, placeholder: UIImage){
        let reference  = Storage.storage(url: self.urlStrorage).reference().child("images-chat/profile/\(image).png")
        imagenView.sd_setImage(with: reference, placeholderImage: placeholder)
    }
    
    func uploadImage(conversation: String, name:String, image: UIImage, completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)){
        if let data = self.resize(image).pngData(){
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            let uploadTask = Storage.storage(url: self.urlStrorage).reference().child("images-chat/\(conversation)/\(name).png").putData(data, metadata: metadata) { (metadata, error) in
                guard metadata != nil else {
                    failure(error?.localizedDescription ?? error.debugDescription)
                    return
                }
                completion()
            }
            
            uploadTask.observe(.success) { snapshot in
                completion()
            }
            
            uploadTask.observe(.failure) { snapshot in
                if let error = snapshot.error as NSError? {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        failure(error.localizedDescription)
                        break
                    case .unauthorized:
                        failure(error.localizedDescription)
                        break
                    case .cancelled:
                        failure(error.localizedDescription)
                        break
                    case .unknown:
                        failure(error.localizedDescription)
                        break
                    default:
                        failure(error.localizedDescription)
                        break
                    }
                }
            }
        }
    }
    
    func downloadImagen(conversation: String, name: String, imagenView: UIImageView, placeholder: UIImage){
        let reference  = Storage.storage(url: self.urlStrorage).reference().child("images-chat/\(conversation)/\(name).png")
        imagenView.sd_setImage(with: reference, placeholderImage: placeholder)
    }
    
    func randomStringNameImage() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return "\(String((0...19).map{ _ in letters.randomElement()! }))"
    }
}

