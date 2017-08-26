//
//  AnnotationView.swift
//  Pods
//
//  Created by Cody Potter on 8/24/17.
//
//

import Foundation
import MapKit

class AnnotationView : MKAnnotationView {
    override init(annotation:MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation,
                   reuseIdentifier: reuseIdentifier)
        let im = UIImage(named: "pin")!
        self.frame = CGRect(x: 0, y: 0, width: im.size.width / 3.0 + 5, height: im.size.height / 3.0 + 5)
        self.centerOffset = CGPoint(x: 0, y: -20)
        self.isOpaque = false
    }
    required init (coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    override func draw(_ rect: CGRect) {
        let im = UIImage(named: "pin")!
        im.draw(in: self.bounds.insetBy(dx: 5, dy: 5))
    }
}
