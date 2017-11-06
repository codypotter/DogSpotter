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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.isHidden = false
        let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs")
        
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
                    newDog.score = Int(value?["score"] as? String ?? "")
                    newDog.imageURL = value?["imageURL"] as? String ?? ""
                    newDog.dogID = snapshot.key
                    
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
                    
                })
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dogCell = tableView.dequeueReusableCell(withIdentifier: "dogCell", for: indexPath) as! DogTableViewCell
        dogCell.dogBreedLabel.text = dogs[indexPath.row - 1].breed
        dogCell.dogNameLabel.text = dogs[indexPath.row - 1].name
        dogCell.dogScoreLabel.text = String(describing: dogs[indexPath.row - 1].score!)
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
        dogCell.dogScoreLabel.text = text
        dogCell.dogImageView.image = dogs[indexPath.row - 1].picture
        dogCell.dogCreatorLabel.text = dogs[indexPath.row - 1].creator
        dogCell.dogVotesLabel.text = "0"
        return dogCell
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
}
