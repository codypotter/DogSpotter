//
//  LeaderboardUserTableViewCell.swift
//  DogSpotter
//
//  Created by Cody Potter on 11/1/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class LeaderboardUserTableViewCell: UITableViewCell {

    @IBOutlet weak var rankAndNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
