//
//  CustomCalloutView.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/20/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var upvoteCounterLabel: UILabel!
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var dogImageView: UIImageView!
    
    @IBAction func upvoteButtonTapped(_ sender: Any) {
        
    }
}
