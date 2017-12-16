//
//  LoginViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/7/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var imageView: UIImageView!
    
    // Properties
    let loginButton = MDCRaisedButton()
    let signupButton = MDCFlatButton()
    let loginCredentialsView = ShadowedView()
    let userNameTextField = UITextField()
    let nameTextField = UITextField()
    let passwordTextField = UITextField()
    let emailTextField = UITextField()
    
    // Constraint variables to be used w/ animation
    var loginCredentialsViewCenterXConstraint: NSLayoutConstraint!
    var loginCredentialsViewHeightConstraint: NSLayoutConstraint!
    var loginButtonWidthConstraint: NSLayoutConstraint!
    var loginButtonBottomConstraint: NSLayoutConstraint!
    var nameTextFieldHeightConstraint: NSLayoutConstraint!
    var userNameTextFieldHeightConstraint: NSLayoutConstraint!
    var emailTextFieldTopConstraint: NSLayoutConstraint!
    var signupButtonBottomConstraint: NSLayoutConstraint!
    var signupButtonWidthConstraint: NSLayoutConstraint!
    
    // Status variables to check view status
    var isInLoginMode = false
    var isInSignupMode = false
    var isInCredentialsMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        self.view.addSubview(loginButton)
        self.view.addSubview(signupButton)
        
        self.view.addSubview(loginCredentialsView)
        self.loginCredentialsView.addSubview(userNameTextField)
        self.loginCredentialsView.addSubview(nameTextField)
        self.loginCredentialsView.addSubview(passwordTextField)
        self.loginCredentialsView.addSubview(emailTextField)
        
        //MARK: Login Button Setup
        loginButton.setTitle("Log in", for: .normal)
        loginButton.setBackgroundColor(UIColor.white, for: .normal)
        loginButton.setTitleColor(UIColor.black, for: .normal)
        loginButton.sizeToFit()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        //MARK: Login Button Layout
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        loginButtonBottomConstraint = loginButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        loginButtonBottomConstraint.isActive = true
        loginButtonWidthConstraint = loginButton.widthAnchor.constraint(equalToConstant: 200)
        loginButtonWidthConstraint.isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK: Signup Button Setup
        signupButton.setTitle(NSLocalizedString("Sign Up", comment: "sign up"), for: .normal)
        signupButton.setBackgroundColor(UIColor(red: 1, green: 0.647, blue: 0.494, alpha: 0), for: .normal)
        signupButton.setTitleColor(UIColor.white, for: .normal)
        signupButton.sizeToFit()
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        
        //MARK: Signup Button Layout
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        signupButtonBottomConstraint = signupButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 100)
        signupButtonBottomConstraint.isActive = true
        signupButtonWidthConstraint = signupButton.widthAnchor.constraint(equalToConstant: 100)
        signupButtonWidthConstraint.isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //MARK: Login Credentials View Layout
        loginCredentialsView.translatesAutoresizingMaskIntoConstraints = false
        loginCredentialsViewCenterXConstraint = loginCredentialsView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(view.bounds.width))
        loginCredentialsViewCenterXConstraint.isActive = true
        loginCredentialsView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginCredentialsViewHeightConstraint = loginCredentialsView.heightAnchor.constraint(equalToConstant: 107)
        loginCredentialsViewHeightConstraint.isActive = true
        loginCredentialsView.widthAnchor.constraint(equalToConstant: view.bounds.width - 40).isActive = true
        loginCredentialsView.backgroundColor = UIColor.white
        loginCredentialsView.layer.cornerRadius = 2.0
        loginCredentialsView.shadowLayer.elevation = ShadowElevation(rawValue: 2.0)
        loginCredentialsView.isHidden = true
        
        //MARK: Username Text Field Layout
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        userNameTextField.topAnchor.constraint(equalTo: loginCredentialsView.topAnchor, constant: 8).isActive = true
        userNameTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        userNameTextFieldHeightConstraint = userNameTextField.heightAnchor.constraint(equalToConstant: 25)
        userNameTextFieldHeightConstraint.isActive = true
        
        //MARK: Username Text Field Setup
        userNameTextField.borderStyle = .none
        userNameTextField.placeholder = NSLocalizedString("Username", comment: "username")
        userNameTextField.autocapitalizationType = .none
        userNameTextField.autocorrectionType = .no
        userNameTextField.textContentType = .username
        userNameTextField.font = UIFont(name: "Avenir Next", size: 17)
        
        //MARK: Name Text Field Layout
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        nameTextField.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 8).isActive = true
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalToConstant: 25)
        nameTextFieldHeightConstraint.isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        
        //MARK: Name Text Field Setup
        nameTextField.borderStyle = .none
        nameTextField.placeholder = NSLocalizedString("Name", comment: "name")
        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no
        nameTextField.textContentType = .name
        nameTextField.font = UIFont(name: "Avenir Next", size: 17)
        
        //MARK: Email Text Field Layout
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        emailTextFieldTopConstraint = emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8)
        emailTextFieldTopConstraint.isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        //MARK: Email Text Field Setup
        emailTextField.borderStyle = .none
        emailTextField.placeholder = NSLocalizedString("Email", comment: "email")
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
        emailTextField.font = UIFont(name: "Avenir Next", size: 17)
        
        //MARK: Password Text Field Layout
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.leadingAnchor.constraint(equalTo: loginCredentialsView.leadingAnchor, constant: 8).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 8).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: loginCredentialsView.trailingAnchor, constant: -8).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        //MARK: Password Text Field Setup
        passwordTextField.borderStyle = .none
        passwordTextField.placeholder = NSLocalizedString("Password", comment: "password")
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.font = UIFont(name: "Avenir Next", size: 17)
    }
    
    @objc func loginButtonTapped() {
        loginCredentialsView.isHidden = false
        let textFieldsArray = [userNameTextField,
                               nameTextField,
                               passwordTextField,
                               emailTextField]
        let buttonsArray = [signupButton,
                            loginButton]
        
        if !isInLoginMode {
            UIView.animate(withDuration: 0.2, animations: {
                self.userNameTextField.isHidden = true
                self.userNameTextFieldHeightConstraint.constant = 0
                self.nameTextField.isHidden = true
                self.nameTextFieldHeightConstraint.constant = 0
                self.emailTextFieldTopConstraint.constant = -8
                self.loginCredentialsViewHeightConstraint.constant = 74
            })
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant = 0
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
                self.loginButton.backgroundColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
                self.loginButton.setTitleColor(UIColor.white, for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            isInLoginMode = true
            isInSignupMode = false
            return
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            createAlertView(withTitle: NSLocalizedString("Oops", comment: "something went wrong"), andMessage: NSLocalizedString("Please enter email and password", comment: "ask user to enter email and password"))
            return
        }
        
        //MARK: Sign In to Firebase Authentication
        SVProgressHUD.show()
        self.toggleEnableTextFields(named: textFieldsArray, to: false)
        self.toggleEnableButtons(named: buttonsArray, to: false)
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                self.createAlertView(withTitle: NSLocalizedString("Oops", comment: "something went wrong"), andMessage: error!.localizedDescription)
                self.toggleEnableTextFields(named: textFieldsArray, to: true)
                self.toggleEnableButtons(named: buttonsArray, to: true)
                return
            }
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "showTabBarController", sender: self)
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.userNameTextField.text = ""
            self.toggleEnableTextFields(named: textFieldsArray, to: true)
            self.toggleEnableButtons(named: buttonsArray, to: true)
        })
    }
    
    @objc func signupButtonTapped() {
        loginCredentialsView.isHidden = false
        let textFieldsArray = [userNameTextField,
                               nameTextField,
                               passwordTextField,
                               emailTextField]
        
        let buttonsArray = [signupButton,
                            loginButton]
        
        if !isInSignupMode {
            UIView.animate(withDuration: 0.2, animations: {
                self.userNameTextField.isHidden = false
                self.userNameTextFieldHeightConstraint.constant = 25
                self.nameTextField.isHidden = false
                self.nameTextFieldHeightConstraint.constant = 25
                self.emailTextFieldTopConstraint.constant = 8
                self.loginCredentialsViewHeightConstraint.constant = 140
            })
            
            if !isInCredentialsMode {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self.loginCredentialsViewCenterXConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            isInCredentialsMode = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.loginButtonBottomConstraint.constant = (self.view.bounds.height/2 - 20)
                self.loginButtonWidthConstraint.constant = 200
                self.signupButtonWidthConstraint.constant = self.loginCredentialsView.bounds.width
                self.signupButtonBottomConstraint.constant = 130
                self.signupButton.backgroundColor = UIColor(red: 229/255, green: 75/255, blue: 75/255, alpha: 1)
                self.signupButton.setTitleColor(UIColor.white, for: .normal)
                self.loginButton.backgroundColor = UIColor.white
                self.loginButton.setTitleColor(UIColor.black, for: .normal)
                self.view.layoutIfNeeded()
            }, completion: nil)
            isInSignupMode = true
            isInLoginMode = false
            return
        }
        
        guard let email = emailTextField.text?.lowercased(), let password = passwordTextField.text, let username = userNameTextField.text?.lowercased() , let name = nameTextField.text else {
            createAlertView(withTitle: NSLocalizedString("Oops", comment: "something went wrong"), andMessage: NSLocalizedString("It looks like you're missing some data.", comment: "ask user for more data"))
            return
        }
        
        //MARK: Create user using Firebase Authentication
        SVProgressHUD.show()
        toggleEnableTextFields(named: textFieldsArray, to: false)
        toggleEnableButtons(named: buttonsArray, to: false)
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                self.createAlertView(withTitle: NSLocalizedString("Oops", comment: "something went wrong"), andMessage: error!.localizedDescription)
                self.toggleEnableTextFields(named: textFieldsArray, to: true)
                self.toggleEnableButtons(named: buttonsArray, to: true)
                return
            }
            
            let usernameCheckRef = Database.database().reference().child("usernames").child(username)
            usernameCheckRef.observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists(){
                    //duplicate username found
                    let user = Auth.auth().currentUser!
                    user.delete(completion: { (error) in
                        if error != nil {
                            SVProgressHUD.dismiss()
                            print(String(describing: error?.localizedDescription))
                            
                        }
                        SVProgressHUD.dismiss()
                        self.createAlertView(withTitle: "Oops", andMessage: "This username is already taken. Please try again.")
                        self.toggleEnableTextFields(named: textFieldsArray, to: true)
                        self.toggleEnableButtons(named: buttonsArray, to: true)
                    })
                } else {
                    //finish setup
                    let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
                    let userValues = ["username":username,
                                      "email": email,
                                      "name": name,
                                      "startDate": String(describing: NSDate.timeIntervalSinceReferenceDate),
                                      "reputation": "10",
                                      "uid": user?.uid]
                    let usernameRef = Database.database().reference().child("usernames").child(username)
                    usernameRef.setValue((Auth.auth().currentUser?.uid)!)
                    
                    userRef.updateChildValues(userValues as Any as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                        if error != nil {
                            SVProgressHUD.dismiss()
                            self.createAlertView(withTitle: NSLocalizedString("Oops", comment: "something went wrong"), andMessage: error!.localizedDescription)
                            self.toggleEnableTextFields(named: textFieldsArray, to: true)
                            self.toggleEnableButtons(named: buttonsArray, to: true)
                            return
                        }
                    })
                    
                    self.performSegue(withIdentifier: "showTabBarController", sender: self)
                    
                    SVProgressHUD.dismiss()
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.userNameTextField.text = ""
                    self.nameTextField.text = ""
                    self.toggleEnableTextFields(named: textFieldsArray, to: true)
                    self.toggleEnableButtons(named: buttonsArray, to: true)
                }
            })
            
            
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func createAlertView(withTitle title: String, andMessage message: String ) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let releaseAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
        alertView.addAction(releaseAction)
        present(alertView, animated: true, completion: nil)
    }
    
    func toggleEnableTextFields(named textFields: [UITextField],to enabled: Bool ) {
        for textField in textFields {
            if enabled {
                textField.isEnabled = true
            } else {
                textField.isEnabled = false
            }
            
        }
    }
    
    func toggleEnableButtons(named buttons: [UIButton], to enabled: Bool) {
        for button in buttons {
            if enabled {
                button.isEnabled = true
            } else {
                button.isEnabled = false
            }
        }
    }
    @IBAction func passwordResetButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Password Reset", message: "Please enter your email address.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Your email address"
            textfield.keyboardType = .emailAddress
            textfield.autocapitalizationType = .none
            
            let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
                // handle submission
                Auth.auth().sendPasswordReset(withEmail: textfield.text!, completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                    }
                })
            }
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            
            
        }
        present(alertController, animated: true, completion: nil)
    }
}
