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
    var dogPhotoIsSelected = false
    
    fileprivate func loadData() {
        let usersRef = Database.database().reference().child("users")
        let userDogRef = usersRef.child((Auth.auth().currentUser?.uid)!).child("dogs")
        let followingRef = usersRef.child((Auth.auth().currentUser?.uid)!).child("following")
        
        dogs.removeAll()
        
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
                    
                    let reportRef = dogRef.child("reports").child((Auth.auth().currentUser?.uid)!)
                    reportRef.observeSingleEvent(of: .value, with: { (reportSnap) in
                        if !reportSnap.exists(){
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
                        }
                    })
                })
            })
        }
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
        
        let tapPhoto = UILongPressGestureRecognizer(target: self, action: #selector(dogPhotoLongPressed(_:)))
        tapPhoto.minimumPressDuration = 0.7
        dogCell.dogImageView.addGestureRecognizer(tapPhoto)
        dogCell.dogImageView.isUserInteractionEnabled = true
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
                
                let dogID = self.dogs[(indexPath?.row)!].dogID
                
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
            
            let dogID = self.dogs[(indexPath?.row)!].dogID
            
            let dogRef = Database.database().reference().child("dogs").child(dogID!).child("reports").child((Auth.auth().currentUser?.uid)!)
            dogRef.setValue("true")
            
            
            self.dogs.remove(at: (indexPath?.row)!)
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
            
            let dogID = self.dogs[(indexPath?.row)!].dogID
            
            let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs").child(dogID!)
            userDogRef.removeValue()
            let dogRef = Database.database().reference().child("dogs").child(dogID!)
            dogRef.removeValue()
            
            self.dogs.remove(at: (indexPath?.row)!)
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
}
