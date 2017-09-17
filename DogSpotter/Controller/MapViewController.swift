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
    
    var authHandle: FIRAuthStateDidChangeListenerHandle?
    var dogs: [Dog] = [Dog]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.map.mapType = .hybrid
        let userDogRef = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dogs")
        
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

                    let newDog = Dog()
                    newDog.name = value["name"]!
                    newDog.breed = value["breed"]!
                    newDog.creator = value["creator"]!
                    newDog.score = Int(value["score"]!)!
                    newDog.imageURL = value["imageURL"]!
                    newDog.location = CLLocationCoordinate2D(latitude: Double(value["latitude"]!)!, longitude: Double(value["longitude"]!)!)

                    URLSession.shared.dataTask(with: URL(string: newDog.imageURL)!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        newDog.picture = UIImage(data: data!)!
                        self.dogs.append(newDog)
                        let annotation  = CustomAnnotation(location: newDog.location, title: newDog.name, subtitle: newDog.creator)
                        DispatchQueue.main.async {
                            self.map.addAnnotation(annotation)
                        }
                        
                    }).resume()
                })
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        //MARK: Auto-Logout handler
        authHandle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if FIRAuth.auth()?.currentUser == nil {
                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
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
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: ident)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        configureDetailView(annotationView!)
        return annotationView
    }
    
    func configureDetailView(_ annotationView: MKAnnotationView) {
        let width = 300
        let height = 300
        
        let dogPhotoView = UIView()
        let views = ["dogPhotoView": dogPhotoView]
        dogPhotoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[dogPhotoView(\(height))]", options: [], metrics: nil, views: views))
        dogPhotoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dogPhotoView(\(width))]", options: [], metrics: nil, views: views))
        
        
        for dog in self.dogs {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
            imageView.image = dog.picture
            
            DispatchQueue.main.async {
                dogPhotoView.addSubview(imageView)
                self.view.layoutIfNeeded()
            }
            
        }
        
        annotationView.detailCalloutAccessoryView = dogPhotoView
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

