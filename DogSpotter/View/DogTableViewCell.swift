//
//  DogTableViewCell.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/21/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class DogTableViewCell: UITableViewCell {
    var dogID = ""
    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var dogNameLabel: UILabel!
    @IBOutlet weak var dogBreedLabel: UILabel!
    @IBOutlet weak var dogScoreLabel: UILabel!
    @IBOutlet weak var dogCreatorLabel: UILabel!
    @IBOutlet weak var dogVotesLabel: UILabel!
    @IBOutlet weak var dogUpvoteButton: UIButton!
}
