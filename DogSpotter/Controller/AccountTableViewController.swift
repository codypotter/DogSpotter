//
//  AccountTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/18/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class AccountTableViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var reputationLabel: UILabel!
    @IBOutlet weak var dogsPostedLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userRef = Database.database().reference().child("users").child(uid!)
        userRef.observe(.value) { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            self.usernameLabel.text = postDict["username"] as? String
            self.emailLabel.text = postDict["email"] as? String
            self.reputationLabel.text = postDict["reputation"] as? String
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
