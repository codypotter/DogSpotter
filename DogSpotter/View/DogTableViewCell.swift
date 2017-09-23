//
//  DogTableViewCell.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/21/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class DogTableViewCell: UITableViewCell {

    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var dogNameLabel: UILabel!
    @IBOutlet weak var dogBreedLabel: UILabel!
    @IBOutlet weak var dogScoreLabel: UILabel!
    @IBOutlet weak var dogCreatorButton: UIButton!
    @IBOutlet weak var dogVotesLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
