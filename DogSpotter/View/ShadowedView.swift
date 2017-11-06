//
//  ShadowedView.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/7/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MaterialComponents

class ShadowedView: UIView {
    override class var layerClass: AnyClass {
        return MDCShadowLayer.self
    }
    
    var shadowLayer: MDCShadowLayer {
        return self.layer as! MDCShadowLayer
    }
    
    func setDefaultElevation() {
        self.shadowLayer.elevation = ShadowElevation.cardResting
    }
}
