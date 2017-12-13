//
//  Dog.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/8/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

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
    
//    convenience init(dictionary: [String: Any], dogUID: String, creatorName: String){
//        self.init()
//        creator = creatorName
//        name = dictionary["name"] as? String
//        breed = dictionary["breed"] as? String
//        score = Int((dictionary["score"] as? String)!)
//        imageURL = dictionary["imageURL"] as? String
//        dogID = dogUID
//        location = CLLocationCoordinate2D(latitude: Double(dictionary["latitude"] as! String)!, longitude: Double(dictionary["longitude"] as! String)!)
//    }
}
