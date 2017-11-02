//
//  LeaderboardViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 11/1/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var folllowersFollowingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topUserLabel: UILabel!
    @IBOutlet weak var secondUserLabel: UILabel!
    @IBOutlet weak var thirdUserLabel: UILabel!
    @IBOutlet weak var leaderboardTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! LeaderboardUserTableViewCell
        
        return cell
    }
}
