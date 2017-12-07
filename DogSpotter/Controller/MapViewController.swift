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
    @IBOutlet weak var repLabel: UILabel!
    
    let newDogButton = UIButton()
    var dogs: [Dog] = [Dog]()
    var user = User()
    var dogIDOfUpvoteTapped: String = ""
    var dogPhotoIsSelected = false
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.map.mapType = .standard
        self.map.showsUserLocation = true
        self.map.userTrackingMode = .follow
        self.map.delegate = self
        self.map.addSubview(newDogButton)
        
        let reference = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("reputation")
        reference.observe(.value) { (snapshot) in
            DispatchQueue.main.async {
                self.repLabel.text = "👑\(snapshot.value ?? "0")"
            }
        }
        
        //MARK: Check if signed in then load dogs
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Welcome!", message: "It looks like you're not logged in! Let's fix that!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "showLoginViewController", sender: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            loadDogs()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //MARK: Setup newDogButton attributes
        newDogButton.addTarget(self, action: #selector(newDogButtonTapped), for: .touchUpInside)
        newDogButton.setBackgroundImage(UIImage(named: "add-dog"), for: .normal)
        
        //MARK: Setup newDogButton layout
        newDogButton.translatesAutoresizingMaskIntoConstraints = false
        newDogButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        newDogButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        newDogButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        newDogButton.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
        newDogButton.contentMode = .scaleAspectFit
        
    }
    
    @objc func newDogButtonTapped() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // Get current location
                DispatchQueue.global(qos: .background).async {
                    self.delegate.locationManager.requestLocation()
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showNewDogViewController", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showLoginViewController", sender: self)
                }
            }
        }
    }
    
    fileprivate func loadDogs() {
        //MARK: Download dogs from firebase
        var friendID = ""
        let userDogRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("dogs")
        let followingRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("following")
        
        followingRef.observe(.childAdded) { (snapshot) in
            if snapshot.value == nil {
                print("not following any users")
            } else {
                friendID = snapshot.key
                Database.database().reference().child("users").child(friendID).child("dogs").observe(.childAdded, with: { (snap1) in
                    if snap1.value == nil {
                        print("no new dog found")
                    } else {
                        print("new dog found")
                        
                        let dogID = snap1.key
                        
                        let dogRef = Database.database().reference().child("dogs").child(dogID)
                        dogRef.observeSingleEvent(of: .value, with: { (snap2) in
                            print("Found dog data!")
                            let value = snap2.value as! Dictionary<String, String>
                            let newDog = Dog()
                            
                            let creatorID = value["creator"]!
                            let userRef = Database.database().reference().child("users")
                            userRef.child(creatorID).child("username").observeSingleEvent(of: .value, with: { (snip) in
                                newDog.creator = snip.value as? String
                            })
                            newDog.name = value["name"]!
                            newDog.breed = value["breed"]!
                            newDog.score = Int(value["score"]!)!
                            newDog.imageURL = value["imageURL"]!
                            newDog.dogID = snap2.key
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
                                annotation.dogID = newDog.dogID!
                                DispatchQueue.main.async {
                                    self.map.addAnnotation(annotation)
                                }
                            }).resume()
                        })
                    }
                })
                
            }
        }
        
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
                    
                    let creatorID = value["creator"]!
                    let userRef = Database.database().reference().child("users")
                    userRef.child(creatorID).child("username").observeSingleEvent(of: .value, with: { (snip) in
                        newDog.creator = snip.value as? String
                    })
                    newDog.name = value["name"]!
                    newDog.breed = value["breed"]!
                    newDog.score = Int(value["score"]!)!
                    newDog.imageURL = value["imageURL"]!
                    newDog.dogID = snap.key
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
                        annotation.dogID = newDog.dogID!
                        DispatchQueue.main.async {
                            self.map.addAnnotation(annotation)
                        }
                    }).resume()
                })
            }
        })
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
        let customAnnotation = annotation as! CustomAnnotation
        
        let usernameRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("username")
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ident)
        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: customAnnotation, reuseIdentifier: ident)
            annotationView?.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }
        
        usernameRef.observeSingleEvent(of: .value) { (snapshot) in
            if customAnnotation.creator == snapshot.value as! String {
                let image = UIImage(cgImage: (UIImage(named: "pin-bone-burnt-sienna")?.cgImage)!, scale: 2.5, orientation: UIImageOrientation(rawValue: 0)!)
                annotationView?.image = image
            } else {
                let image = UIImage(cgImage: (UIImage(named: "pin-bone")?.cgImage)!, scale: 2.5, orientation: UIImageOrientation(rawValue: 0)!)
                annotationView?.image = image
            }
        }
        return annotationView!
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
        let tapPhoto = UILongPressGestureRecognizer(target: self, action: #selector(dogPhotoLongPressed(_:)))
        tapPhoto.minimumPressDuration = 1.0
        
        calloutView.dogImageView.addGestureRecognizer(tapPhoto)
        calloutView.nameLabel.text = customAnnotation.name
        calloutView.breedLabel.text = customAnnotation.breed
        calloutView.scoreLabel.text = String(describing: customAnnotation.score)
        var score = customAnnotation.score
        if score == 0 {
            score = 1
        }
        var text = ""
        for _ in 0 ..< score {
            if text.isEmpty {
                text = "🔥"
            } else {
                text += "🔥"
            }
        }
        dogIDOfUpvoteTapped = customAnnotation.dogID
        
        calloutView.scoreLabel.text = text
        calloutView.creatorLabel.text = customAnnotation.creator
        calloutView.dogImageView.image = customAnnotation.picture
        
        let reference = Database.database().reference().child("dogs").child(dogIDOfUpvoteTapped).child("upvotes")
        reference.observe(.value) { (snapshot) in
            DispatchQueue.main.async {
                calloutView.upvoteCounterLabel.text = snapshot.value as? String
            }
        }
        
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
                UIView.animate(withDuration: 0.4, animations: {
                    subview.alpha = 0
                    self.dogPhotoIsSelected = false
                    subview.removeFromSuperview()
                })
            }
        }
    }
    
    @IBAction func accountButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showAccountViewController", sender: self)
    }
    
    @objc func upvoteTapped(_ sender: UIButton) {
        let ref = Database.database().reference().child("dogs").child(dogIDOfUpvoteTapped)
        let userRef = Database.database().reference().child("users")

        ref.child("creator").observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.value as! String == (Auth.auth().currentUser?.uid)! {
                return
            }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    sender.transform = .init(scaleX: 0.5, y: 0.5)
                }
                UIView.animate(withDuration: 0.25) {
                    sender.transform = .identity
                }
            }
            
            userRef.child(snapshot.value as! String).child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                var currentRep = Int(snap.value as! String)!
                currentRep += 1
                userRef.child(snapshot.value as! String).child("reputation").setValue(String(currentRep))
            })
            
            ref.child("upvotes").observeSingleEvent(of: .value, with: { (snap) in
                var currentUpvotes = Int(snap.value as! String)!
                currentUpvotes += 1
                ref.child("upvotes").setValue(String(currentUpvotes))
            })
        userRef.child(Auth.auth().currentUser!.uid).child("reputation").observeSingleEvent(of: .value, with: { (snap) in
                var currentRep = Int(snap.value as! String)!
                currentRep += 1
                userRef.child(Auth.auth().currentUser!.uid).child("reputation").setValue(String(currentRep))
            })
            
        }
    }
    
    @objc func dogPhotoLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            if !dogPhotoIsSelected {
                let imageView = sender.view
                
                let blur = UIBlurEffect(style: .dark)
                let effectView = UIVisualEffectView()
                effectView.frame = (imageView?.frame)!
                
                let reportButton = UIButton()
                reportButton.setTitle("Report...", for: .normal)
                reportButton.setTitleColor(UIColor.white, for: .normal)
                reportButton.sizeThatFits(reportButton.intrinsicContentSize)
                reportButton.alpha = 0.0
                
                let shareButton = UIButton()
                shareButton.setTitle("Share...", for: .normal)
                shareButton.setTitleColor(UIColor.white, for: .normal)
                shareButton.sizeThatFits(shareButton.intrinsicContentSize)
                shareButton.alpha = 0.0
                shareButton.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
                
                imageView?.addSubview(effectView)
                imageView?.addSubview(reportButton)
                imageView?.addSubview(shareButton)
                
                reportButton.translatesAutoresizingMaskIntoConstraints = false
                reportButton.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!, constant: 0).isActive = true
                reportButton.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: 30).isActive = true
                
                shareButton.translatesAutoresizingMaskIntoConstraints = false
                shareButton.centerXAnchor.constraint(equalTo: (imageView?.centerXAnchor)!, constant: 0).isActive = true
                shareButton.centerYAnchor.constraint(equalTo: (imageView?.centerYAnchor)!, constant: -30).isActive = true
                
                UIView.animate(withDuration: 0.15, animations: {
                    effectView.effect = blur
                    reportButton.alpha = 1.0
                    shareButton.alpha = 1.0
                    self.dogPhotoIsSelected = true
                })
            }
        }
    }
    
    @objc func shareTapped(_ sender: UIButton) {
        guard let blurview = sender.superview else {return}
        guard let dogCard = blurview.superview as? CustomCalloutView else {return}
        let image = dogCard.dogImageView.image!
        
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
}

















