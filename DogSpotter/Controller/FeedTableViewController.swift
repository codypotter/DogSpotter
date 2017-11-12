//
//  FeedTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 11/6/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class FeedTableViewController: UITableViewController {
    var user = User()
    var dogs = [Dog]()
    var dogIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = false
        
        let usersRef = Database.database().reference().child("users")
        let userDogRef = usersRef.child((Auth.auth().currentUser?.uid)!).child("dogs")
        let followingRef = usersRef.child((Auth.auth().currentUser?.uid)!).child("following")
        
        //MARK: Download my dog IDs from firebase
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                let dogRef = Database.database().reference().child("dogs").child(snapshot.key)
                dogRef.observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value  = snap.value as? NSDictionary
                    let newDog = Dog()
                    
                    let creatorID = value?["creator"] as? String ?? ""
                    usersRef.child(creatorID).child("username").observeSingleEvent(of: .value, with: { (snip) in
                        newDog.creator = snip.value as? String
                    })
                    
                    newDog.name = value?["name"] as? String ?? ""
                    newDog.breed = value?["breed"] as? String ?? ""
                    newDog.score = Int(value?["score"] as? String ?? "0")
                    newDog.imageURL = value?["imageURL"] as? String ?? ""
                    newDog.timestamp = value?["timestamp"] as? String ?? ""
                    newDog.upvotes = Int(value?["upvotes"] as? String ?? "0")
                    newDog.dogID = snap.key
                    
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
                    self.dogs = self.dogs.sorted {
                        $0.timestamp! > $1.timestamp!
                    }
                    self.tableView.reloadData()
                })
            }
        })
        
        //MARK: Download my following dogs from firebase
        followingRef.observe(.childAdded) { (snapshot) in
            usersRef.child(snapshot.key).child("dogs").observe(.childAdded, with: { (snap) in
                let dogRef = Database.database().reference().child("dogs").child(snap.key)
                dogRef.observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value  = snap.value as? NSDictionary
                    let newDog = Dog()
                    
                    let creatorID = value?["creator"] as? String ?? ""
                    usersRef.child(creatorID).child("username").observeSingleEvent(of: .value, with: { (snip) in
                        newDog.creator = snip.value as? String
                    })
                    
                    newDog.name = value?["name"] as? String ?? ""
                    newDog.breed = value?["breed"] as? String ?? ""
                    newDog.score = Int(value?["score"] as? String ?? "0")
                    newDog.imageURL = value?["imageURL"] as? String ?? ""
                    newDog.timestamp = value?["timestamp"] as? String ?? ""
                    newDog.upvotes = Int(value?["upvotes"] as? String ?? "0")
                    newDog.dogID = snap.key
                    
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
                    self.dogs = self.dogs.sorted {
                        $0.timestamp! > $1.timestamp!
                    }
                    self.tableView.reloadData()
                })
            })
        }
        
        //MARK: Download
        //        for dogID in dogIDs {
        //            let dogRef = Database.database().reference().child("dogs").child(dogID)
        //            dogRef.observeSingleEvent(of: .value, with: { (snap) in
        //                print("Found dog data!")
        //                let value  = snap.value as? NSDictionary
        //                let newDog = Dog()
        //
        //                newDog.name = value?["name"] as? String ?? ""
        //                newDog.breed = value?["breed"] as? String ?? ""
        //                newDog.creator = value?["creator"] as? String ?? ""
        //                newDog.score = Int(value?["score"] as? String ?? "0")
        //                newDog.imageURL = value?["imageURL"] as? String ?? ""
        //                newDog.upvotes = Int(value?["upvotes"] as? String ?? "0")
        //                newDog.dogID = dogID
        //
        //                URLSession.shared.dataTask(with: URL(string: newDog.imageURL!)!, completionHandler: { (data, response, error) in
        //                    if error != nil {
        //                        print(error!)
        //                        return
        //                    }
        //                    newDog.picture = UIImage(data: data!)!
        //                    DispatchQueue.main.async {
        //                        self.tableView.reloadData()
        //                    }
        //                }).resume()
        //
        //                self.dogs.insert(newDog, at: 0)
        //                self.dogs = self.dogs.sorted {
        //                    $0.timestamp! > $1.timestamp!
        //                }
        //                self.tableView.reloadData()
        //            })
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dogCell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! DogTableViewCell
        dogCell.dogBreedLabel.text = dogs[indexPath.row].breed
        dogCell.dogNameLabel.text = dogs[indexPath.row].name
        dogCell.dogScoreLabel.text = String(describing: dogs[indexPath.row].score!)
        dogCell.dogVotesLabel.text = String(describing: dogs[indexPath.row].upvotes!)
        dogCell.dogUpvoteButton.tag = indexPath.row
        
        var score = (dogs[indexPath.row].score!)
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
        dogCell.dogScoreLabel.text = text
        dogCell.dogImageView.image = dogs[indexPath.row].picture
        dogCell.dogCreatorLabel.text = dogs[indexPath.row].creator
        
        let dogUpvoteRef = Database.database().reference().child("dogs").child(dogs[indexPath.row].dogID!).child("upvotes")
        dogUpvoteRef.observe(.value) { (snapshot) in
            DispatchQueue.main.async {
                dogCell.dogVotesLabel.text = snapshot.value as? String
            }
        }
        return dogCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageHeight = Int(view.bounds.width)
        let labelsHeight = 3 * 20
        let spacing = 12 + 24
        let creatorHeight = 30
        return CGFloat(imageHeight + labelsHeight + spacing + creatorHeight + 8)
    }
    
    @IBAction func upvoteTapped(_ sender: UIButton) {
        let ref = Database.database().reference().child("dogs").child(dogs[sender.tag].dogID!)
        let userRef = Database.database().reference().child("users")
        
        ref.child("creator").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value as! String != (Auth.auth().currentUser?.uid)! {
                ref.child("upvotes").observeSingleEvent(of: .value, with: { (snap) in
                    var currentUpvotes = Int(snap.value as! String)!
                    currentUpvotes += 1
                    ref.child("upvotes").setValue(String(currentUpvotes))
                })
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.25) {
                        sender.transform = .init(scaleX: 0.5, y: 0.5)
                    }
                    UIView.animate(withDuration: 0.25) {
                        sender.transform = .identity
                    }
                }
                
                userRef.child(snapshot.value as! String).child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                    var currentRep = Int(snap.value as! String)!
                    currentRep += 2
                    userRef.child(snapshot.value as! String).child("reputation").setValue(String(currentRep))
                })
                
                userRef.child(Auth.auth().currentUser!.uid).child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                    var currentRep = Int(snap.value as! String)!
                    currentRep += 1
                    userRef.child(Auth.auth().currentUser!.uid).child("reputation").setValue(String(currentRep))
                })
            }
        }
    }
}
