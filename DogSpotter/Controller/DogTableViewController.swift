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

    var user = User()
    let profileCell = ProfileTableViewCell()
    var dogs = [Dog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDogRef = Database.database().reference().child("users").child(user.uid!).child("dogs")
        
        let userProfileImageView = UIImageView()
        userProfileImageView.translatesAutoresizingMaskIntoConstraints = false
        userProfileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        userProfileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userProfileImageView.layer.cornerRadius = 20
        userProfileImageView.clipsToBounds = true
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.image = UIImage(named: "AppIcon")
        
        navigationItem.titleView = userProfileImageView
        
        //MARK: Download dogs from firebase
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let snapshotValue = snapshot.value as? NSDictionary
                let dogID = snapshotValue?["dogID"] as? String ?? ""
                
                let dogRef = Database.database().reference().child("dogs").child(dogID)
                dogRef.observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value  = snap.value as? NSDictionary
                    let newDog = Dog()

                    newDog.name = value?["name"] as? String ?? ""
                    newDog.breed = value?["breed"] as? String ?? ""
                    newDog.creator = value?["creator"] as? String ?? ""
                    newDog.score = Int(value?["score"] as? String ?? "")
                    newDog.imageURL = value?["imageURL"] as? String ?? ""
                    newDog.dogID = snapshot.key
                    
                    URLSession.shared.dataTask(with: URL(string: newDog.imageURL!)!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        newDog.picture = UIImage(data: data!)!
                        self.dogs.append(newDog)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }).resume()
                })
            }
        })

        tableView.estimatedRowHeight = 454
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell
            profileCell.nameLabel.text = user.name
            profileCell.totalReputationLabel.text = String(describing: user.reputation!)
            profileCell.usernameLabel.text = user.username
            return profileCell
        } else {
            let dogCell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! DogTableViewCell
            dogCell.dogBreedLabel.text = dogs[indexPath.row - 1].breed
            dogCell.dogNameLabel.text = dogs[indexPath.row - 1].name
            dogCell.dogScoreLabel.text = String(describing: dogs[indexPath.row - 1].score)
            dogCell.dogImageView.image = dogs[indexPath.row - 1].picture
            dogCell.dogCreatorButton.titleLabel?.text = dogs[indexPath.row - 1].creator
            dogCell.dogVotesLabel.text = "0"
            return dogCell
        }
        
    }
}
