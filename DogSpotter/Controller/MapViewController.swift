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
import MaterialComponents

class MapViewController: UIViewController, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet var map: MKMapView!
    
    let newDogButton = MDCFloatingButton()
    var dogs: [Dog] = [Dog]()
    var user = User()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.map.mapType = .hybrid
        self.map.addSubview(newDogButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //MARK: Setup newDogButton attributes
        newDogButton.setTitle("+", for: .normal)
        newDogButton.sizeToFit()
        newDogButton.addTarget(self, action: #selector(newDogButtonTapped), for: .touchUpInside)
        newDogButton.backgroundColor = UIColor(red: 233/255, green: 116/255, blue: 81/255, alpha: 1)
        
        //MARK: Setup newDogButton layout
        newDogButton.translatesAutoresizingMaskIntoConstraints = false
        newDogButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        newDogButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //MARK: Check if signed in then load dogs
        if Auth.auth().currentUser == nil {
//            let alert = UIAlertController(title: "Welcome!", message: "It looks like you're not logged in! Let's fix that!", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action) in
//                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
//            }))
//            present(alert, animated: true, completion: nil)
        } else {
            loadDogs()
        }
    }
    
    @objc func newDogButtonTapped() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // Get current location
                DispatchQueue.global(qos: .background).async {
                    self.delegate.locationManager.requestLocation()
                }
                self.performSegue(withIdentifier: "showNewDogViewController", sender: self)
            } else {
                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
            }
        }
    }
    
    fileprivate func loadDogs() {
        //MARK: Download dogs from firebase
        let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs")
        
        userDogRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.value == nil {
                print("no new dog found")
            } else {
                print("new dog found")
                
                let dogID = snapshot.key
                
                let dogRef = Database.database().reference().child("dogs").child(dogID)
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
                    
                    URLSession.shared.dataTask(with: URL(string: newDog.imageURL!)!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        newDog.picture = UIImage(data: data!)!
                        self.dogs.append(newDog)
                        let annotation  = CustomAnnotation(location: newDog.location, title: newDog.name!, subtitle: newDog.creator!)
                        annotation.name = newDog.name!
                        annotation.breed = newDog.breed!
                        annotation.score = newDog.score!
                        annotation.creator = newDog.creator!
                        annotation.picture = newDog.picture
                        DispatchQueue.main.async {
                            self.map.addAnnotation(annotation)
                        }
                    }).resume()
                })
            }
        })
    }
    
//    @IBAction func logOutTapped(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("an error has occurred")
//        }
//        performSegue(withIdentifier: "showLoginViewController", sender: self)
//    }
    
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
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: ident)
            annotationView?.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }
        let image = UIImage(cgImage: (UIImage(named: "pin-bone")?.cgImage)!, scale: 2.5, orientation: UIImageOrientation(rawValue: 0)!)
        annotationView?.image = image
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for aView in views {
            if aView.reuseIdentifier == "pin" {
                aView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                aView.alpha = 0
                UIView.animate(withDuration:0.5) {
                    aView.alpha = 1
                    aView.transform = .identity
                    
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! CustomAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.nameLabel.text = customAnnotation.name
        calloutView.breedLabel.text = customAnnotation.breed
        calloutView.scoreLabel.text = String(describing: customAnnotation.score)
        calloutView.creatorLabel.text = customAnnotation.creator
        calloutView.dogImageView.image = customAnnotation.picture
        calloutView.upvoteButton.addTarget(self, action: #selector(upvoteTapped(_:)), for: .touchUpInside)
        
        calloutView.center = CGPoint(x: view.bounds.size.width/2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        let center = CGPoint(x: calloutView.center.x, y: calloutView.center.y)
        let newCenter = mapView.convert(center, toCoordinateFrom: view)
        mapView.setCenter(newCenter, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: CustomAnnotationView.self){
            for subview in view.subviews{
                UIView.animate(withDuration: 0.2, animations: {
                    subview.alpha = 0
                })
                subview.removeFromSuperview()
            }
        }
    }
    
//    @IBAction func accountButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: "showAccountViewController", sender: self)
//    }
    
//    @IBAction func disoverButtonTapped(_ sender: Any) {
//        self.performSegue(withIdentifier: "showUserSearch", sender: self)
//    }
    
    @objc func upvoteTapped(_ sender: UIButton) {
        
    }
}

