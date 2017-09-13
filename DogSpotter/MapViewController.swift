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
import Firebase

class MapViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, NewDogInfo {

    @IBOutlet var map: MKMapView!
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    var newDogImage: UIImage?
    var newDogName: String?
    var newDogBreed: String?
    var newDogScore: Int?
    var dogs: [Dog] = []
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.map.mapType = .hybrid
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if FIRAuth.auth()?.currentUser == nil {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    @IBAction func newDogTapped(_ sender: Any) {
        // Get current location
        DispatchQueue.global(qos: .background).async {
            self.delegate.locationManager.requestLocation()
        }
        performSegue(withIdentifier: "showNewDogViewController", sender: self)
    }
    
    func dropNewPin(locatedAt: CLLocation, name: String, rate: Int) {
        let annotation = Annotation(location: CLLocationCoordinate2D(latitude: locatedAt.coordinate.latitude, longitude: locatedAt.coordinate.longitude))
        annotation.title = name
        annotation.subtitle = "\(rate)/10"
        self.map.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewDogViewController" {
            let newDogViewController = segue.destination as! NewDogViewController
            newDogViewController.dogInfoDelegate = self
        }
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
    
    func dogDataReceived(name: String, breed: String, score: Int, image: UIImage) {
        self.newDogName = name
        self.newDogBreed = breed
        self.newDogScore = score
        self.newDogImage = image
        let latitude = delegate.location?.coordinate.latitude
        let longitude = delegate.location?.coordinate.longitude
        
        //let user = FIRAuth.auth()?.currentUser?.uid
        
        if delegate.location != nil {
            let newDog = Dog(name: name, score: score, picture: image, location: delegate.location!)
            dogs.append(newDog)
            
            let databaseRef = FIRDatabase.database().reference()
            let dogRef = databaseRef.child("dogs").childByAutoId()
            let userRef = databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dogs")
            let user = FIRAuth.auth()?.currentUser?.displayName!
            
            let dogValues = ["creator": user!, "name": name, "breed": breed, "score": String(score), "latitude": String(describing: latitude!), "longitude": String(describing: longitude!) ]
            let userValues = ["dogAutoId": dogRef.key]
            
            dogRef.updateChildValues(dogValues, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                } else {
                    print("Saved dog successfully!")
                }
            })
            
            userRef.updateChildValues(userValues, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                } else {
                    print("Saved user-dog reference successfully!")
                }
            })
            
            
            
            
            
            
            
            
            
            
            
            
            dropNewPin(locatedAt: dogs.last!.location, name: dogs.last!.name, rate: dogs.last!.score)
        }
    }
}

