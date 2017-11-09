//
//  Dog.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/8/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MapKit

class Dog: NSObject {
    var creator: String?
    var upvotes: Int?
    var name: String?
    var timestamp: String?
    var breed: String?
    var score: Int?
    var imageURL: String?
    var dogID: String?
    var picture = UIImage()
    var location = CLLocationCoordinate2D()
}
