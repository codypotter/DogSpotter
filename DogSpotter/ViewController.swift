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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet var newDogViewVisualEffect: UIVisualEffectView!
    var image: UIImage?
    var location: CLLocation?
    var dogs: [Dog] = []
    @IBOutlet var newDogButton: UIButton!
    @IBOutlet var newDogScore: UILabel!
    @IBOutlet var newDogName: UITextField!
    @IBOutlet var newDogView: UIView!
    @IBOutlet var preview: UIImageView!
    @IBOutlet var map: MKMapView!
    let locman = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locman.requestWhenInUseAuthorization()
        self.locman.delegate = self
        self.locman.desiredAccuracy = kCLLocationAccuracyBest
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.newDogName.delegate = self
        
        view.addSubview(newDogView)
        setupNewDogViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func newDogTapped(_ sender: Any) {
        let source = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(source)
            else {
                let alert = UIAlertController(title: "Camera Error", message: "Oops! Looks like Dog Spotter doesn't have access to your camera! Please open Settings to give Dog Spotter permission to use the camera.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true)
                return
        }
        let camera = UIImagePickerController()
        camera.sourceType = source
        camera.delegate = self
        camera.allowsEditing = true
        
        self.present(camera, animated: true)
        DispatchQueue.global(qos: .background).async {
            self.locman.requestLocation()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        
        self.dismiss(animated: true, completion: nil)
        map.isUserInteractionEnabled = false
        view.addSubview(newDogView)
        setupNewDogViewConstraints()
        newDogView.isHidden = false
        preview.image = self.image
    }
    
    func setupNewDogViewConstraints() {
        newDogView.isHidden = true
        newDogView.translatesAutoresizingMaskIntoConstraints = false
        newDogView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -50).isActive = true
        newDogView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1, constant: -50).isActive = true
        newDogView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newDogView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        newDogView.layer.cornerRadius = 10
        newDogViewVisualEffect.layer.cornerRadius = 10
        newDogButton.layer.cornerRadius = 10
        preview.layer.cornerRadius = 10
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        let coord = loc.coordinate
        location = loc
        print("You are at \(coord.latitude) \(coord.longitude)")
    }
    
    @IBAction func submitDog(_ sender: Any) {
        if newDogName.text == "" {
            let alert = UIAlertController(title: "Woops", message: "Please enter a name for the dog.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        if location != nil {
            let newDog = Dog(name: newDogName.text!, score: 11, picture: image!, location: location!)
            dogs.append(newDog)
            print(dogs.last!)
            
            self.newDogName.text = ""
            self.map.isUserInteractionEnabled = true
            
            dropNewPin(locatedAt: dogs.last!.location, name: dogs.last!.name, rate: dogs.last!.score)
        }
    }
    
    func dropNewPin(locatedAt: CLLocation, name: String, rate: Int) {
        let annotation = Annotation(location: CLLocationCoordinate2D(latitude: locatedAt.coordinate.latitude, longitude: locatedAt.coordinate.longitude))
        annotation.title = name
        annotation.subtitle = "\(rate)/10"
        self.map.addAnnotation(annotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //to avoid make a custom Annotation view for your user location
        if(annotation is MKUserLocation){
            return nil
        }
        
        let ident = "pin"
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: ident) 
            v?.image = UIImage(named: "pin")
            v?.centerOffset = CGPoint(x: 0, y: -15)
            v?.bounds.size.height /= 1.5
            v?.bounds.size.width /= 1.5
            v?.canShowCallout = true
            
        }
        v?.annotation = annotation
        return v
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for aView in views {
            if aView.reuseIdentifier == "pin" {
                aView.transform = CGAffineTransform(scaleX: 0, y: 0)
                aView.alpha = 0
                UIView.animate(withDuration:0.8) {
                    aView.alpha = 1
                    aView.transform = .identity
                }
            }
        }
    }
}

