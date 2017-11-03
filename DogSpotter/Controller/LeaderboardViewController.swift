//
//  LeaderboardViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 11/1/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Firebase

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var folllowersFollowingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topUserLabel: UILabel!
    @IBOutlet weak var secondUserLabel: UILabel!
    @IBOutlet weak var thirdUserLabel: UILabel!
    @IBOutlet weak var leaderboardTableView: UITableView!
    var ref: DatabaseReference?
    var userUID: String?
    var myFollowingUsersArray = [User]()
    var myFollowersUsersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var myFollowersStringsArray = [String]()

        
        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        
        if Auth.auth().currentUser != nil {
            userUID = Auth.auth().currentUser?.uid
            ref = Database.database().reference().child("users")
            
            ref?.child(userUID!).child("following").observe(.childAdded, with: { (snapshot) in
                self.ref?.child(snapshot.key).observeSingleEvent(of: .value, with: { (snap) in
                    let userToAdd = User()
                    let userDict = snap.value as? [String : AnyObject] ?? [:]
                    
                    userToAdd.username = userDict["username"] as? String
                    userToAdd.reputation = userDict["reputation"] as? Int
                    userToAdd.uid = userDict["uid"] as? String
                    self.myFollowingUsersArray.append(userToAdd)
                    self.leaderboardTableView.reloadData()
                })
            })
            ref?.child(userUID!).child("followers").observe(.childAdded, with: { (snapshot) in
                self.ref?.child(snapshot.key).observeSingleEvent(of: .value, with: { (snap) in
                    let userToAdd = User()
                    let userDict = snap.value as? [String : AnyObject] ?? [:]
                    
                    userToAdd.username = userDict["username"] as? String
                    userToAdd.reputation = userDict["reputation"] as? Int
                    userToAdd.uid = userDict["uid"] as? String
                    self.myFollowersUsersArray.append(userToAdd)
                    self.leaderboardTableView.reloadData()
                })
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if folllowersFollowingSegmentedControl.selectedSegmentIndex == 0 {
            return myFollowersUsersArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! LeaderboardUserTableViewCell
        if folllowersFollowingSegmentedControl.selectedSegmentIndex == 0 {
            cell.scoreLabel.text = String(describing: myFollowersUsersArray[indexPath.row].reputation)
            cell.rankAndNameLabel.text = "\(indexPath.row + 1). \(String(describing: myFollowersUsersArray[indexPath.row].username!))"
        }
        return cell
    }
}
