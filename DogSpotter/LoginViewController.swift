//
//  LoginViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/7/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MaterialComponents

class LoginViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var blurView: UIVisualEffectView!
    
    let loginButton = MDCRaisedButton()
    let signupButton = MDCFlatButton()
    let loginCredentialsView = ShadowedView()
    let userNameTextField = UITextField()
    let passwordTextField = UITextField()
    let emailTextField = UITextField()
    
    var loginCredentialsViewCenterXConstraint: NSLayoutConstraint!
    var loginCredentialsViewHeightConstraint: NSLayoutConstraint!
    var loginButtonWidthConstraint: NSLayoutConstraint!
    var userNameTextFieldHeightConstraint: NSLayoutConstraint!
    var emailTextFieldTopConstraint: NSLayoutConstraint!
    var signupButtonBottomConstraint: NSLayoutConstraint!
    
    var isInLoginMode = false
    var isInSignupMode = false
    var isInCredentialsMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.addSubview(blurView)
        self.view.addSubview(loginButton)
        self.view.addSubview(signupButton)
        self.view.addSubview(loginCredentialsView)
        self.loginCredentialsView.addSubview(userNameTextField)
        self.loginCredentialsView.addSubview(passwordTextField)
        self.loginCredentialsView.addSubview(emailTextField)
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setBackgroundColor(UIColor.white, for: .normal)
        loginButton.setTitleColor(UIColor.black, for: .normal)
        loginButton.sizeToFit()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        loginButtonWidthConstraint = loginButton.widthAnchor.constraint(equalToConstant: 200)
        loginButtonWidthConstraint.isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        signupButton.setTitle("Sign up", for: .normal)
        signupButton.setBackgroundColor(UIColor(red: 1, green: 0.647, blue: 0.494, alpha: 0), for: .normal)
        signupButton.setTitleColor(UIColor.white, for: .normal)
        signupButton.sizeToFit()
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        signupButtonBottomConstraint = signupButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        signupButtonBottomConstraint.isActive = true
        signupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        loginCredentialsView.translatesAutoresizingMaskIntoConstraints = false
        loginCredentialsViewCenterXConstraint = loginCredentialsView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(view.bounds.width))
        loginCredentialsViewCenterXConstraint.isActive = true
        loginCredentialsView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginCredentialsViewHeightConstraint = loginCredentialsView.heightAnchor.constraint(equalToConstant: 107)
        loginCredentialsViewHeightConstraint.isActive = true
        loginCredentialsView.widthAnchor.constraint(equalToConstant: view.bounds.width - 40).isActive = true
        loginCredentialsView.backgroundColor = UIColor.white
        loginCredentialsView.layer.cornerRadius = 2.0
        loginCredentialsView.shadowLayer.elevation = 2.0
        
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        userNameTextField.topAnchor.constraint(equalTo: loginCredentialsView.topAnchor, constant: 8).isActive = true
        userNameTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        userNameTextFieldHeightConstraint = userNameTextField.heightAnchor.constraint(equalToConstant: 25)
        userNameTextFieldHeightConstraint.isActive = true
        userNameTextField.borderStyle = .none
        userNameTextField.placeholder = "Username"
        userNameTextField.autocapitalizationType = .none
        userNameTextField.autocorrectionType = .no
        userNameTextField.font = UIFont(name: "Helvetica", size: 17)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        emailTextFieldTopConstraint = emailTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 8)
        emailTextFieldTopConstraint.isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        emailTextField.borderStyle = .none
        emailTextField.placeholder = "Email"
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.font = UIFont(name: "Helvetica", size: 17)
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 8).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        passwordTextField.borderStyle = .none
        passwordTextField.placeholder = "Password"
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.font = UIFont(name: "Helvetica", size: 17)

        blurView.alpha = 0
    }
    
    @objc func loginButtonTapped() {
        
        if !isInLoginMode {
            userNameTextField.isHidden = true
            userNameTextFieldHeightConstraint.constant = 0
            emailTextFieldTopConstraint.constant = 0
            loginCredentialsViewHeightConstraint.constant = 74
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant += self.view.bounds.width
                    self.blurView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            isInCredentialsMode = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                if self.signupButtonBottomConstraint.constant != 100 + self.view.bounds.height/2 - 170 {
                    self.signupButtonBottomConstraint.constant += (self.view.bounds.height/2 - 170)
                }
                self.loginButtonWidthConstraint.constant = self.loginCredentialsView.bounds.width
                self.loginButton.backgroundColor = UIColor(red: 178/255, green: 69/255, blue: 39/255, alpha: 1)
                self.loginButton.setTitleColor(UIColor.white, for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        isInLoginMode = true
        isInSignupMode = false
    }
    
    @objc func signupButtonTapped() {
        if !isInSignupMode {
            userNameTextField.isHidden = false
            userNameTextFieldHeightConstraint.constant = 25
            emailTextFieldTopConstraint.constant = 8
            loginCredentialsViewHeightConstraint.constant = 107
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant += self.view.bounds.width
                    self.blurView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            isInCredentialsMode = true
            
        }
        isInSignupMode = true
        isInLoginMode = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
