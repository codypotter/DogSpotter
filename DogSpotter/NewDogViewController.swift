//
//  NewDogViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/2/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class NewDogViewController: UIViewController {

    var dogScore: Int = 1
    @IBOutlet var dogRateSlider: UISlider!
    @IBOutlet var dogScoreLabel: UILabel!
    @IBOutlet var dogBreedTextField: UITextField!
    @IBOutlet var dogNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func dogRateChanged(_ sender: UISlider) {
        var score = (Int(dogRateSlider.value * 10))
        if score == 0 {
            score = 1
        }
        var text = ""
        for _ in 0..<score {
            if text.isEmpty {
                text = "🔥"
            } else {
                text += "🔥"
            }
        }
        dogScoreLabel.text = text
        dogScore = score
    }

    @IBAction func submitDog(_ sender: Any) {
        
    }
    
}
