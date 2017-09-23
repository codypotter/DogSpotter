//
//  User.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/22/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var name: String?
    var username: String?
    var reputation: Int?
    var timestamp: Int?
    var uid: String?
    var dogIDList = [Int]()
}
