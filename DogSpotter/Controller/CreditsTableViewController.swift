//
//  CreditsTableViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 12/17/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class CreditsTableViewController: UITableViewController {

    var credits = ["Dog Bone: Mello at thenounproject.com",
                   "Dog Shadow: Kate Maldjian at thenounproject.com",
                   "Map Plus: NOPIXEL at thenounproject.com",
                   "Newspaper: unlimicon at thenounproject.com",
                   ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return credits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = credits[indexPath.row]

        return cell
    }
}
