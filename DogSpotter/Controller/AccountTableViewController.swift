//
//  AccountTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/18/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AccountTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var reputationLabel: UILabel!
    @IBOutlet weak var dogsPostedLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let uid = Auth.auth().currentUser?.uid
    var tempImage = UIImage()
    var tempImageData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        
        SVProgressHUD.show()
        let userRef = Database.database().reference().child("users").child(uid!)
        userRef.observe(.value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.usernameLabel.text = postDict["username"] as? String
            self.emailLabel.text = postDict["email"] as? String
            self.reputationLabel.text = "👑" + (postDict["reputation"] as? String)!
            
            snapshot.ref.child("dogs").observe(.value, with: { (snap) in
                let dogsDict = snap.value as? [String : AnyObject] ?? [:]
                self.dogsPostedLabel.text = String(describing: dogsDict.count)
            })
            
            snapshot.ref.child("following").observe(.value, with: { (snap) in
                let followingDict = snap.value as? [String : AnyObject] ?? [:]
                self.followingLabel.text = String(describing: followingDict.count)
            })
            
            snapshot.ref.child("followers").observe(.value, with: { (snap) in
                let followersDict = snap.value as? [String : AnyObject] ?? [:]
                self.followersLabel.text = String(describing: followersDict.count)
            })
            
            SVProgressHUD.dismiss()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && indexPath.section == 0 {
            let alertController = UIAlertController(title: "Edit", message: "Please enter a new username.", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = self.usernameLabel.text
                textField.autocapitalizationType = .none
                alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = textField.text
                    changeRequest?.commitChanges(completion: { (error) in
                        if error != nil {
                            print(String(describing: error?.localizedDescription))
                            return
                        }
                    })
                    self.usernameLabel.text = textField.text
                }))
            }
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 1 && indexPath.section == 0 {
            let alertController = UIAlertController(title: "Edit", message: "Please enter a new email.", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = self.emailLabel.text
                textField.autocapitalizationType = .none
                textField.keyboardType = .emailAddress
                alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                    Auth.auth().currentUser?.updateEmail(to: textField.text!) { (error) in
                        print(String(describing: error?.localizedDescription))
                    }
                    self.emailLabel.text = textField.text
                }))
            }
            present(alertController, animated: true, completion: nil)
        } else if indexPath.row == 2 && indexPath.section == 0 {
            let source = UIImagePickerControllerSourceType.photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(source)
                else {
                    let alert = UIAlertController(title: "Library Error", message: "Oops! Looks like Dog Spotter doesn't have access to your photo library! Please open Settings to give Dog Spotter permission to use your photo library.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    present(alert, animated: true)
                    return
            }
            let library = UIImagePickerController()
            library.sourceType = source
            library.allowsEditing = true
            library.delegate = self
            present(library, animated: true)
        }
        tableView.reloadData()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        tempImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            tempImageData = UIImageJPEGRepresentation(editedImage, 0.70)!
            tempImage = editedImage
        }
        profileImageView.image = tempImage
        self.dismiss(animated: true, completion: nil)
    }
}
