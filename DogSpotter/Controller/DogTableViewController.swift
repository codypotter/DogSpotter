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
    var followersCount = 0
    var followingCount = 0
    
    @IBOutlet weak var followBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        let userDogRef = Database.database().reference().child("users").child(user.uid!).child("dogs")
        let userRef = Database.database().reference().child("users").child(user.uid!)
        
        userRef.child("followers").observe(.childAdded) { (snapshot) in
            self.followersCount += 1
            self.tableView.reloadData()
        }
        userRef.child("following").observe(.childAdded) { (snapshot) in
            self.followingCount += 1
            self.tableView.reloadData()
        }

        //MARK: Download dogs from firebase
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let dogID = snapshot.key
                
                let dogRef = Database.database().reference().child("dogs").child(dogID)
                dogRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value  = snap.value as? NSDictionary
                    let newDog = Dog()

                    newDog.name = value?["name"] as? String ?? ""
                    newDog.breed = value?["breed"] as? String ?? ""
                    newDog.creator = value?["creator"] as? String ?? ""
                    newDog.score = Int(value?["score"] as? String ?? "0")
                    newDog.imageURL = value?["imageURL"] as? String ?? ""
                    newDog.dogID = snapshot.key
                    newDog.upvotes = Int(value?["upvotes"] as? String ?? "0")
                    
                    URLSession.shared.dataTask(with: URL(string: newDog.imageURL!)!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        newDog.picture = UIImage(data: data!)!
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }).resume()
                    
                    self.dogs.insert(newDog, at: 0)
                    self.tableView.reloadData()
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
            profileCell.totalFollowersLabel.text = String(describing: followersCount)
            profileCell.totalFollowingLabel.text = String(describing: followingCount)
            return profileCell
        } else {
            let dogCell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! DogTableViewCell
            dogCell.dogBreedLabel.text = dogs[indexPath.row - 1].breed
            dogCell.dogNameLabel.text = dogs[indexPath.row - 1].name
            dogCell.dogScoreLabel.text = String(describing: dogs[indexPath.row - 1].score!)
            dogCell.dogVotesLabel.text = String(describing: dogs[indexPath.row - 1].upvotes!)
            
            var score = (dogs[indexPath.row - 1].score!)
            if score == 0 {
                score = 1
            }
            var text = ""
            for _ in 0 ..< score {
                if text.isEmpty {
                    text = "🔥"
                } else {
                    text += "🔥"
                }
            }
            dogCell.dogUpvoteButton.tag = indexPath.row
            dogCell.dogScoreLabel.text = text
            dogCell.dogImageView.image = dogs[indexPath.row - 1].picture
            dogCell.dogCreatorLabel.text = dogs[indexPath.row - 1].creator
            
            let dogUpvoteRef = Database.database().reference().child("dogs").child(dogs[indexPath.row - 1].dogID!).child("upvotes")
            dogUpvoteRef.observe(.value) { (snapshot) in
                DispatchQueue.main.async {
                    dogCell.dogVotesLabel.text = snapshot.value as? String
                }
            }
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
        if user.uid! == Auth.auth().currentUser?.uid {
            return
        }
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
    
    @IBAction func upvoteTapped(_ sender: UIButton) {
        let ref = Database.database().reference().child("dogs").child(dogs[sender.tag - 1].dogID!)
        ref.child("upvotes").observeSingleEvent(of: .value, with: { (snap) in
            var currentUpvotes = Int(snap.value as! String)!
            currentUpvotes += 1
            ref.child("upvotes").setValue(String(currentUpvotes))
        })
        UIView.animate(withDuration: 0.25) {
            sender.transform = .init(scaleX: 0.5, y: 0.5)
        }
        UIView.animate(withDuration: 0.25) {
            sender.transform = .identity
        }
    }
    
}
