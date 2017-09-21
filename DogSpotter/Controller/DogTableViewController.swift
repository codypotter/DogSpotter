//
//  DogTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/20/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class DogTableViewController: UITableViewController {

    var uid: String?
    var uidRef: DatabaseReference?
    let profileCell = ProfileTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userProfileImageView = UIImageView()
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        userProfileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        userProfileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userProfileImageView.layer.cornerRadius = 20
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.image = UIImage(named: "AppIcon")
        
        navigationItem.titleView = userProfileImageView
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell

        uidRef = Database.database().reference().child("users").child(uid!)
        uidRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            cell.nameLabel.text = value?["name"] as? String ?? ""
            cell.usernameLabel.text = value?["username"] as? String ?? ""
            cell.totalReputationLabel.text = value?["reputation"] as? String ?? ""
        })
        print(uid!)
        // Configure the cell...

        return cell
    }

}
