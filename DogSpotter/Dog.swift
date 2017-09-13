//
//  Dog.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/8/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MapKit

class Dog {
    var name: String
    var score: Int
    var picture: UIImage
    var location: CLLocation
    
    init(name: String, score: Int, picture: UIImage, location: CLLocation) {
        self.name = name
        self.score = score
        self.picture = picture
        self.location = location
    }
}
