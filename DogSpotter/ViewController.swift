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

    
    @IBOutlet var newDogScrollView: UIScrollView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
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
        
        self.visualEffectView.alpha = 0
        self.locman.requestWhenInUseAuthorization()
        self.locman.delegate = self
        self.locman.desiredAccuracy = kCLLocationAccuracyBest
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.newDogName.delegate = self
        
        
        view.addSubview(newDogView)
        newDogView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func newDogTapped(_ sender: Any) {
        // Get current location
        DispatchQueue.global(qos: .background).async {
            self.locman.requestLocation()
        }
        
        // Setup Camera and present it
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
        self.present(camera, animated: true)
        map.isUserInteractionEnabled = false
        
    }
    
    override func viewWillLayoutSubviews() {
        newDogView.translatesAutoresizingMaskIntoConstraints = false
        newDogScrollView.translatesAutoresizingMaskIntoConstraints = false
        newDogScrollView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true
        //newDogScrollView.widthAnchor.constraint(equalToConstant: 960.0).isActive = true
        newDogScrollView.contentSize = CGSize(width: 960, height: 320)
        newDogView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true
        newDogView.widthAnchor.constraint(equalToConstant: 320.0).isActive = true
        newDogView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newDogView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.preview.layer.cornerRadius = 10
        self.newDogView.layer.cornerRadius = 10
        self.newDogScrollView.layer.cornerRadius = 10
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        self.dismiss(animated: true, completion: {
            self.preview.image = self.image
            self.visualEffectView.alpha = 1
            self.newDogView.alpha = 1
        })
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
            
            self.newDogView.alpha = 0
            self.visualEffectView.alpha = 0
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

