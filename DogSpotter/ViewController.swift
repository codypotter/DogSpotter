//
//  ViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 8/3/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import Photos
import MapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    var image: UIImage?
    var location: CLLocation?
    @IBOutlet var newDogScore: UILabel!
    @IBOutlet var newDogName: UITextField!
    @IBOutlet var newDogView: UIView!
    @IBOutlet var preview: UIImageView!
    @IBOutlet var map: MKMapView!
    let locman = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locman.delegate = self
        self.locman.requestWhenInUseAuthorization()
        self.locman.desiredAccuracy = kCLLocationAccuracyBest
        self.map.mapType = .hybrid
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func submitDog(_ sender: Any) {
        let newDog = Dog(name: newDogName.text!, score: Int(newDogScore.text!)!, picture: image!, location: location!)
        print(newDog)
    }
    
    @IBAction func newDogTapped(_ sender: Any) {
        presentCamera()
        getLocation()
    }

    func presentCamera() {
        let source = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(source)
            else { return }
        let camera = UIImagePickerController()
        camera.sourceType = source
        camera.delegate = self
        self.present(camera, animated: true)
    }
    
    func getLocation() {
        self.locman.requestLocation()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
        self.newDogView.isHidden = true
        self.view.addSubview(newDogView)
        newDogView.translatesAutoresizingMaskIntoConstraints = false
        newDogView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -50).isActive = true
        newDogView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1, constant: -50).isActive = true
        newDogView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newDogView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        preview.image = image
        self.newDogView.isHidden = false
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        let coord = loc.coordinate
        location = loc
        print("You are at \(coord.latitude) \(coord.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
}

