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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        var userRef: DatabaseReference?
        if let uid = Auth.auth().currentUser?.uid {
            userRef = Database().reference().child("users").child(uid)
        } else {
            let alertView = UIAlertController(title: "Not Logged In", message: "Looks like you're not logged in.", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "#sorrynotsorry", style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alertView, animated: true, completion: nil)
        }
        
        userRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            self.usernameLabel.text = String(describing: snapshot.value(forKey: "username"))
            self.emailLabel.text = String(describing: snapshot.value(forKey: "email"))
            self.reputationLabel.text = String(describing: snapshot.value(forKey: "reputation"))
            
            
            
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

}
