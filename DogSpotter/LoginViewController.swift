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
    var loginButtonBottomConstraint: NSLayoutConstraint!
    var userNameTextFieldHeightConstraint: NSLayoutConstraint!
    var emailTextFieldTopConstraint: NSLayoutConstraint!
    var signupButtonBottomConstraint: NSLayoutConstraint!
    var signupButtonWidthConstraint: NSLayoutConstraint!
    
    var isInLoginMode = false
    var isInSignupMode = false
    var isInCredentialsMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        loginButtonBottomConstraint = loginButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        loginButtonBottomConstraint.isActive = true
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
        signupButtonWidthConstraint = signupButton.widthAnchor.constraint(equalToConstant: 100)
        signupButtonWidthConstraint.isActive = true
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
            UIView.animate(withDuration: 0.2, animations: {
                self.userNameTextField.isHidden = true
                self.userNameTextFieldHeightConstraint.constant = 0
                self.emailTextFieldTopConstraint.constant = 0
                self.loginCredentialsViewHeightConstraint.constant = 74
            })
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant = 0
                    self.blurView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            isInCredentialsMode = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.signupButtonBottomConstraint.constant = (self.view.bounds.height/2 - 20)
                self.signupButtonWidthConstraint.constant = 100
                self.loginButtonWidthConstraint.constant = self.loginCredentialsView.bounds.width
                self.loginButtonBottomConstraint.constant = 100
                self.signupButton.setBackgroundColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0), for: .normal)
                self.signupButton.setTitleColor(UIColor.white, for: .normal)
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
            UIView.animate(withDuration: 0.2, animations: {
                self.userNameTextField.isHidden = false
                self.userNameTextFieldHeightConstraint.constant = 25
                self.emailTextFieldTopConstraint.constant = 8
                self.loginCredentialsViewHeightConstraint.constant = 107
            })
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant = 0
                    self.blurView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            isInCredentialsMode = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.loginButtonBottomConstraint.constant = (self.view.bounds.height/2 - 20)
                self.loginButtonWidthConstraint.constant = 200
                self.signupButtonWidthConstraint.constant = self.loginCredentialsView.bounds.width
                self.signupButtonBottomConstraint.constant = 110
                self.signupButton.backgroundColor = UIColor(red: 178/255, green: 69/255, blue: 39/255, alpha: 1)
                self.signupButton.setTitleColor(UIColor.white, for: .normal)
                self.loginButton.backgroundColor = UIColor.white
                self.loginButton.setTitleColor(UIColor.black, for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
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
