//
//  Annotation.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/24/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    dynamic var coordinate : CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(location coord:CLLocationCoordinate2D) {
        self.coordinate = coord
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
