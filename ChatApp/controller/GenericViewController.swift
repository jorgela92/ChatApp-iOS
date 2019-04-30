//
//  GenericViewController.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialPalettes

class GenericViewController: UIViewController {
    
    let imagePicker: UIImagePickerController =  UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI(){
        navigationController?.navigationBar.barTintColor = MDCPalette.grey.tint700
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        view.backgroundColor = MDCPalette.grey.tint200
    }
    
    func selectImage(_ sender: UIBarButtonItem){
        let alert = self.getAlertCamera()
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender.customView
            alert.popoverPresentationController?.sourceRect = sender.customView!.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        present(alert, animated: true, completion: nil)
    }
    
    func selectImage(_ sender: UIButton){
        let alert = self.getAlertCamera()
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    private func getAlertCamera() -> UIAlertController {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    private func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}
