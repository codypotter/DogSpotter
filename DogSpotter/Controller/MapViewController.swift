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
import Cluster

class MapViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, NewDogInfo {

    @IBOutlet var map: MKMapView!
    
    var authHandle: FIRAuthStateDidChangeListenerHandle?
    var dogs: [Dog] = [Dog]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let clusterManager = ClusterManager()
    

    
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
        let userDogRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dogs")
        
        //MARK: Auto-Logout handler
        authHandle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if FIRAuth.auth()?.currentUser == nil {
                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
            }
        })
        
        //MARK: Auto-Map-Update handler
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let snapshotValue = snapshot.value as! Dictionary<String, String>
                let dogID = snapshotValue["dogID"]!
                
                let dogRef = FIRDatabase.database().reference().child("dogs").child(dogID)
                dogRef.observeSingleEvent(of: .value, with: { (snap) in
                    print("Found dog data!")
                    let value = snap.value as! Dictionary<String, String>
                    
                    let name = value["name"]!
                    let breed = value["breed"]!
                    let creator = value["creator"]!
                    let score = Int(value["score"]!)!
                    let lat = Double(value["latitude"]!)!
                    let lon = Double(value["longitude"]!)!
                    let url = value["imageURL"]!
                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    let newDog = Dog()
                    newDog.name = name
                    newDog.breed = breed
                    newDog.creator = creator
                    newDog.score = score
                    newDog.imageURL = url
                    newDog.location = location
                    
                    let downloadURL = URL(string: newDog.imageURL)!
                    URLSession.shared.dataTask(with: downloadURL, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        
                        newDog.picture = UIImage(data: data!)!
                        
                        
                    }).resume()
                    
                    self.dogs.append(newDog)
                    
                })
                
            }
        })
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        performSegue(withIdentifier: "showLoginViewController", sender: self)
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
        
    }
}

