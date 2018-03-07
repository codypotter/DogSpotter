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
    var dogPhotoIsSelected = false
    var currentUID = (Auth.auth().currentUser?.uid)!
    var noDogs = false
    
    @IBOutlet weak var followBarButtonItem: UIBarButtonItem!
    
    fileprivate func loadData() {
        let userDogRef = Database.database().reference().child("users").child(user.uid!).child("dogs")
        let userRef = Database.database().reference().child("users").child(user.uid!)
        let isFollowingRef = Database.database().reference().child("users").child(currentUID).child("following").child(user.uid!)
        
        dogs.removeAll()
        
        isFollowingRef.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                self.followBarButtonItem.title = "Unfollow"
            }
        }
        
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
                self.noDogs = true;
            } else {
                self.noDogs = false;
                
                let dogID = snapshot.key
                
                let dogRef = Database.database().reference().child("dogs").child(dogID)
                let reportRef = dogRef.child("reports").child(self.currentUID)
                
                dogRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { (snap) in
                    
                    reportRef.observeSingleEvent(of: .value, with: { (reportSnap) in
                        if !reportSnap.exists() {
                            let value  = snap.value as? NSDictionary
                            let newDog = Dog()
                            
                            userRef.child("username").observeSingleEvent(of: .value, with: { (snip) in
                                newDog.creator = snip.value as? String
                            })
                            
                            newDog.name = value?["name"] as? String ?? ""
                            newDog.breed = value?["breed"] as? String ?? ""
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
                        }
                    })
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh...")
        self.tableView.sendSubview(toBack: refreshControl!)
        tableView.refreshControl = self.refreshControl
        
        self.navigationController?.navigationBar.isHidden = false
        loadData()
    }
    
    @objc func refresh() {
        loadData()
        self.refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noDogs {
            let noDogCell = tableView.dequeueReusableCell(withIdentifier: "noDogCell")
            noDogCell?.textLabel?.text = "No dogs found! Follow your friends or post some dogs!"
            return noDogCell!
        }
        if !noDogs && indexPath.row == 0 {
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
            let tapPhoto = UILongPressGestureRecognizer(target: self, action: #selector(dogPhotoLongPressed(_:)))
            tapPhoto.minimumPressDuration = 0.7
            dogCell.dogImageView.addGestureRecognizer(tapPhoto)
            dogCell.dogImageView.isUserInteractionEnabled = true
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
        if user.uid! == currentUID {
            return
        }
        let followingRef = Database.database().reference().child("users/\(currentUID)/following/\(self.user.uid!)")
        let followersRef = Database.database().reference().child("users/\(user.uid!)/followers/\(currentUID)")
        
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
        let userRef = Database.database().reference().child("users")
        
        ref.child("creator").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.value as! String != self.currentUID {
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
                
                userRef.child(self.currentUID).child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                    var currentRep = Int(snap.value as! String)!
                    currentRep += 1
                    userRef.child(self.currentUID).child("reputation").setValue(String(currentRep))
                })
            }
        }
    }
    
    @objc func dogPhotoLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            if !dogPhotoIsSelected {
                let imageView = sender.view
                
                let blur = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView()
                effectView.frame = (imageView?.bounds)!
                effectView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(effectViewLongPressed(_:))))
                
                let cell = sender.view?.superview?.superview as! DogTableViewCell
                let indexPath = self.tableView.indexPath(for: cell)
                
                let dogID = self.dogs[(indexPath?.row)! - 1].dogID
                
                let isMyDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs").child(dogID!)
                isMyDogRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        //it's my dog
                        let deleteButton = UIButton()
                        deleteButton.setTitle("Delete...", for: .normal)
                        deleteButton.setTitleColor(UIColor.white, for: .normal)
                        deleteButton.sizeThatFits(deleteButton.intrinsicContentSize)
                        deleteButton.alpha = 0.0
                        deleteButton.addTarget(self, action: #selector(self.deleteTapped(_:)), for: .touchUpInside)
                        
                        DispatchQueue.main.async {
                            imageView?.addSubview(deleteButton)
                            deleteButton.translatesAutoresizingMaskIntoConstraints = false
                            deleteButton.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!, constant: 0).isActive = true
                            deleteButton.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: 30).isActive = true
                            UIView.animate(withDuration: 0.15, animations: {
                                deleteButton.alpha = 1.0
                            })
                        }
                    } else {
                        //it's not my dog
                        let reportButton = UIButton()
                        reportButton.setTitle("Report...", for: .normal)
                        reportButton.setTitleColor(UIColor.white, for: .normal)
                        reportButton.sizeThatFits(reportButton.intrinsicContentSize)
                        reportButton.alpha = 0.0
                        reportButton.addTarget(self, action: #selector(self.reportTapped(_:)), for: .touchUpInside)
                        
                        DispatchQueue.main.async {
                            imageView?.addSubview(reportButton)
                            reportButton.translatesAutoresizingMaskIntoConstraints = false
                            reportButton.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!, constant: 0).isActive = true
                            reportButton.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: 30).isActive = true
                            UIView.animate(withDuration: 0.15, animations: {
                                reportButton.alpha = 1.0
                            })
                        }
                    }
                })
                
                let shareButton = UIButton()
                shareButton.setTitle("Share...", for: .normal)
                shareButton.setTitleColor(UIColor.white, for: .normal)
                shareButton.sizeThatFits(shareButton.intrinsicContentSize)
                shareButton.alpha = 0.0
                shareButton.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
                
                imageView?.addSubview(effectView)
                imageView?.addSubview(shareButton)
                
                effectView.translatesAutoresizingMaskIntoConstraints = false
                effectView.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!).isActive = true
                effectView.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: 0).isActive = true
                effectView.heightAnchor.constraint(equalTo: (imageView?.heightAnchor)!).isActive = true
                effectView.widthAnchor.constraint(equalTo: (imageView?.widthAnchor)!).isActive = true
                
                shareButton.translatesAutoresizingMaskIntoConstraints = false
                shareButton.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!, constant: 0).isActive = true
                shareButton.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: -30).isActive = true
                
                UIView.animate(withDuration: 0.15, animations: {
                    effectView.effect = blur
                    shareButton.alpha = 1.0
                    self.dogPhotoIsSelected = true
                })
            }
        }
    }
    
    @objc func shareTapped(_ sender: UIButton) {
        guard let imageview = sender.superview as? UIImageView else {return}
        let image = imageview.image!
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true) {
            for subview in imageview.subviews {
                subview.removeFromSuperview()
            }
        }
    }
    
    @objc func reportTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Report", message: "Are you sure you want to report this post? You should only report a post if it does not feature a dog, or it features offensive content. This action is irreversible.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes, report this post", style: .destructive, handler: { (action) in
            let cell = sender.superview?.superview?.superview! as! DogTableViewCell
            let imageview = sender.superview! as! UIImageView
            let indexPath = self.tableView.indexPath(for: cell)
            
            let dogID = self.dogs[(indexPath?.row)! - 1].dogID
            
            let dogRef = Database.database().reference().child("dogs").child(dogID!).child("reports").child(self.currentUID)
            dogRef.setValue("true")
            
            
            self.dogs.remove(at: (indexPath?.row)! - 1)
            DispatchQueue.main.async {
                for subview in (imageview.subviews) {
                    subview.removeFromSuperview()
                }
                self.dogPhotoIsSelected = false
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func deleteTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post? This action is irreversible. There's no going back.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes, delete this post", style: .destructive, handler: { (action) in
            let cell = sender.superview?.superview?.superview! as! DogTableViewCell
            let imageview = sender.superview! as! UIImageView
            let indexPath = self.tableView.indexPath(for: cell)
            
            let dogID = self.dogs[(indexPath?.row)! - 1].dogID
            
            let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs").child(dogID!)
            userDogRef.removeValue()
            let dogRef = Database.database().reference().child("dogs").child(dogID!)
            dogRef.removeValue()
            
            self.dogs.remove(at: (indexPath?.row)! - 1)
            DispatchQueue.main.async {
                for subview in (imageview.subviews) {
                    subview.removeFromSuperview()
                }
                self.dogPhotoIsSelected = false
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView.reloadData()
            }
            
            let userRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
            userRef.child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                var currentRep = Int(snap.value as! String)!
                currentRep -= 25
                userRef.child("reputation").setValue(String(currentRep))
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func effectViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let imageview = sender.view?.superview as? UIImageView else {return}
        for subview in (imageview.subviews) {
            subview.removeFromSuperview()
        }
        dogPhotoIsSelected = false
    }
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        let ref = Database.database().reference()
        let blockRef = ref.child("users").child(self.user.uid!).child("blocked").child(self.currentUID)
        
        blockRef.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {
                alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { (action) in
                    if self.user.uid! == self.currentUID {
                        return
                    }
                    let myFollowersRef = ref.child("users").child(self.currentUID).child("followers").child(self.user.uid!)
                    let myFollowingRef = ref.child("users").child(self.currentUID).child("following").child(self.user.uid!)
                    let blockedFollowersRef = ref.child("users").child(self.user.uid!).child("followers").child(self.currentUID)
                    let blockedFollowingRef = ref.child("users").child(self.user.uid!).child("following").child(self.currentUID)
                    myFollowersRef.removeValue()
                    myFollowingRef.removeValue()
                    blockedFollowersRef.removeValue()
                    blockedFollowingRef.removeValue()
                    
                    blockRef.setValue("true")
                    
                    self.followBarButtonItem.title = "Follow"
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)

            } else {
                alert.addAction(UIAlertAction(title: "Unblock", style: .default, handler: { (action) in
                    if self.user.uid! == self.currentUID {
                        return
                    }
                    
                    blockRef.removeValue()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        
        
        
    }
}





















