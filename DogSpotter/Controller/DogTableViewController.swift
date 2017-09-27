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

    var currentUserIsFollowing = false
    var user = User()
    var dogs = [Dog]()
    
    @IBOutlet weak var followBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDogRef = Database.database().reference().child("users").child(user.uid!).child("dogs")
        
        //MARK: Download dogs from firebase
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let dogID = snapshot.key
                
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
    }

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
            dogCell.dogScoreLabel.text = String(describing: dogs[indexPath.row - 1].score!)
            dogCell.dogImageView.image = dogs[indexPath.row - 1].picture
            dogCell.dogCreatorLabel.text = dogs[indexPath.row - 1].creator
            dogCell.dogVotesLabel.text = "0"
            return dogCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 186.0
        } else {
            let imageHeight = Int(view.bounds.width)
            let labelsHeight = 3 * 20
            let spacing = 12 + 24
            let creatorHeight = 30
            return CGFloat(imageHeight + labelsHeight + spacing + creatorHeight + 8)
        }
    }
    

    
    @IBAction func followUserButtonPressed(_ sender: Any) {
        followOrUnfollow()
    }
    
    func followOrUnfollow() {
        
        let followingRef = Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/following/\(self.user.uid!)")
        let followersRef = Database.database().reference().child("users/\(user.uid!)/followers/\(Auth.auth().currentUser!.uid)")
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                print("no following found")
                followingRef.setValue("true") { (error, ref) in
                    if error != nil {
                        print(String(describing: error?.localizedDescription))
                    }
                    
                }
            } else {
                print("unfollowing")
                snapshot.ref.removeValue()
            }
        })
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                print("no followers found")
                followersRef.setValue("true") { (error, ref) in
                    if error != nil {
                        print(String(describing: error?.localizedDescription))
                    }
                    DispatchQueue.main.async {
                        self.followBarButtonItem.title = "Unfollow"
                    }
                }
            } else {
                print("unfollowing")
                snapshot.ref.removeValue()
                DispatchQueue.main.async {
                    self.followBarButtonItem.title = "Follow"
                }
            }
        })
    }

}
