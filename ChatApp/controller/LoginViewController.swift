//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Jorge Lapeña Antón on 07/02/2019.
//  Copyright © 2019 Jorge Lapeña Antón. All rights reserved.
//

import UIKit
import Firebase
import MMProgressHUD
import MaterialComponents

protocol LoginViewControllerDelegate: AnyObject {
    func buttonClicked(tag: Int, email: String?, password: String?)
}

class LoginViewController: GenericViewController {
    
    @IBOutlet weak var buttonRegister: MDCButton!
    @IBOutlet weak var buttonGo: MDCButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textEmail: MDCTextField!
    @IBOutlet weak var textPassword: MDCTextField!
    @IBOutlet weak var switchRecorderUser: UISwitch!
    @IBOutlet weak var labelRecorderUser: UILabel!
    @IBOutlet weak var imagePassword: UIImageView!
    
    private var emailController: MDCTextInputControllerOutlined?
    private var passwordController: MDCTextInputControllerOutlined?
    
    private let loginViewModel: LoginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureController()
    }
    
    private func configureController(){
        loginViewModel.firebaseAuthViewModelDelegate = self
        configureUI()
    }
    
    private func configureUI(){
        if let email = UserDefaults.standard.string(forKey: LoginViewController.description()){
            textEmail.text = email
            switchRecorderUser.isOn = true
        } else {
            textEmail.text = ""
            switchRecorderUser.isOn = false
        }
        switchRecorderUser.onTintColor = MDCPalette.lightGreen.accent700
        switchRecorderUser.tintColor = MDCPalette.grey.tint800
        labelRecorderUser.textColor = UIColor.black
        buttonGo.layer.cornerRadius = 20
        let colorSchemeGo = MDCSemanticColorScheme()
        colorSchemeGo.onPrimaryColor = UIColor.white
        colorSchemeGo.primaryColor = MDCPalette.lightGreen.accent700!
        MDCContainedButtonColorThemer.applySemanticColorScheme(colorSchemeGo, to: buttonGo)
        buttonRegister.layer.cornerRadius = 20
        let colorSchemeRegister = MDCSemanticColorScheme()
        colorSchemeRegister.onPrimaryColor = UIColor.white
        colorSchemeRegister.primaryColor = MDCPalette.lightBlue.accent700!
        MDCContainedButtonColorThemer.applySemanticColorScheme(colorSchemeRegister, to: buttonRegister)
        textEmail.backgroundColor = UIColor.white
        textEmail.textColor = UIColor.black
        textEmail.backgroundColor = UIColor.clear
        textEmail.clearButtonMode = .never
        textEmail.delegate = self
        emailController = MDCTextInputControllerOutlined(textInput: textEmail)
        emailController?.borderFillColor = UIColor.white
        emailController?.normalColor = UIColor.black
        emailController?.activeColor = UIColor.black
        emailController?.inlinePlaceholderColor = UIColor.black
        emailController?.floatingPlaceholderActiveColor = UIColor.black
        textPassword.backgroundColor = UIColor.white
        textPassword.textColor = UIColor.black
        textPassword.backgroundColor = UIColor.clear
        textPassword.clearButtonMode = .never
        textPassword.delegate = self
        passwordController = MDCTextInputControllerOutlined(textInput: textPassword)
        passwordController?.borderFillColor = UIColor.white
        passwordController?.normalColor = UIColor.black
        passwordController?.activeColor = UIColor.black
        passwordController?.inlinePlaceholderColor = UIColor.black
        passwordController?.floatingPlaceholderActiveColor = UIColor.black
        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(messageTableViewTapped))
        view.addGestureRecognizer(tabGesture)
    }
    
    @objc private func messageTableViewTapped(){
        view.layoutIfNeeded()
        view.endEditing(true)
    }
    
    @IBAction func actionFirebase(_ sender: UIButton) {
        MMProgressHUD.show(withStatus: "Loading...")
        loginViewModel.loginViewControllerDelegate?.buttonClicked(tag: sender.tag,
                                                                          email: textEmail.text,
                                                                          password: textPassword.text)
    }
    
    @IBAction func actionPasswordSee(_ sender: Any) {
        if textPassword.isSecureTextEntry {
            textPassword.isSecureTextEntry = false
            imagePassword.image = UIImage(named: "password_hidden")
        } else {
            textPassword.isSecureTextEntry = true
            imagePassword.image = UIImage(named: "password_visible")
        }
    }
}

extension LoginViewController: FirebaseAuthViewModelDelegate {
    func login() {
        if switchRecorderUser.isOn {
            UserDefaults.standard.set(textEmail.text, forKey: LoginViewController.description())
        } else {
            UserDefaults.standard.set("", forKey: LoginViewController.description())
        }
        UserDefaults.standard.synchronize()
        if let usersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersController") as? UsersViewController {
            
            usersViewController.usersViewModel = UsersViewModel.init(firebaseViewModel: loginViewModel.firebaseViewModel)
            present(UINavigationController(rootViewController: usersViewController), animated:true, completion: nil)
        }
    }
    
    func register() {
        labelTitle.text = "Login"
        textPassword.text = ""
        MMProgressHUD.dismiss(withSuccess: "REGISTER OK")
    }
    
    func error(error: String, sign: Bool) {
        if sign{
            labelTitle.text = "Registrar"
            textPassword.text = ""
            MMProgressHUD.dismissWithError(error)
        } else {
            textPassword.text = ""
            MMProgressHUD.dismissWithError(error)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.layoutIfNeeded()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
