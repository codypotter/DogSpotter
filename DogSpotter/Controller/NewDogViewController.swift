//
//  NewDogViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/2/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase
import AVFoundation
import CoreML
import Vision

class NewDogViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let delegate = UIApplication.shared.delegate as! AppDelegate
	let storageRef = Storage.storage().reference()
	let uid = Auth.auth().currentUser?.uid
	
	var breedGuess: String = "" {
		didSet {
			dogBreedTextField.text = breedGuess
		}
	}
	
    var dogScore: Int = 1
    var image: UIImage?
	var imageData: Data?
	
	@IBOutlet var dogInfoView: ShadowedView?
	@IBOutlet var dogRateSlider: UISlider!
	@IBOutlet var dogScoreLabel: UILabel!
	@IBOutlet var dogBreedTextField: UITextField!
	@IBOutlet var dogNameTextField: UITextField!
    @IBOutlet var dogImageView: UIImageView!
	@IBOutlet var dogInfoViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dogNameTextField.delegate = self
		self.dogBreedTextField.delegate = self

		let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
		swipeUp.direction = UISwipeGestureRecognizerDirection.up
		dogInfoView?.addGestureRecognizer(swipeUp)
    }
	
	@objc func handleSwipeUp(gesture: UISwipeGestureRecognizer) {
		UIView.animate(withDuration: 0.4) {
			self.dogInfoViewBottomConstraint.constant = self.view.layer.bounds.height
			self.view.layoutIfNeeded()
		}
		dismiss(animated: true, completion: nil)
	}
	
	override func viewWillLayoutSubviews() {
		dogInfoView?.shadowLayer.elevation = ShadowElevation(rawValue: 2.0)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		dogInfoViewBottomConstraint.constant = -view.layer.bounds.height
		self.view.layoutIfNeeded()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		UIView.animate(withDuration: 0.4) {
			self.dogInfoViewBottomConstraint.constant = 28
			self.view.layoutIfNeeded()
		}
	}

    @IBAction func newPhotoTapped(_ sender: UIButton) {
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
		camera.allowsEditing = true
        camera.delegate = self
		
		if AVCaptureDevice.authorizationStatus(for: .video) != AVAuthorizationStatus.authorized {
			let alert = UIAlertController(title: "Camera Error", message: "Oops! Looks like Dog Spotter doesn't have access to your camera! Please open Settings to give Dog Spotter permission to use the camera.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			
			present(alert, animated: true)
			return
		}
		
		present(camera, animated: true)
    }
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageData = UIImageJPEGRepresentation(editedImage, 0.70)
			
			guard let ciimage = CIImage(image: editedImage) else {
				fatalError("Could not convert UIImage to CIImage.")
			}
			
			detect(image: ciimage)
			
			image = editedImage
        }
        self.dismiss(animated: true, completion: {
            self.dogImageView.image = self.image
        })
    }
	
	func detect(image: CIImage) {
		guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
			fatalError("Loading CoreML model failed.")
		}
		
		let request = VNCoreMLRequest(model: model) { (request, error) in
			guard let results = request.results as? [VNClassificationObservation] else {
				fatalError("Model failed to process image")
			}
			
			if let firstResult = results.first {
				self.breedGuess = firstResult.identifier
			}
		}
		
		let handler = VNImageRequestHandler(ciImage: image)
		
		do {
			try handler.perform([request])
		} catch {
			print(error)
		}
	}
	
	@IBAction func dogRateChanged(_ sender: UISlider) {
		var score = (Int(dogRateSlider.value * 10))
		if score == 0 {
			score = 1
		}
		var text = ""
		for _ in 0..<score {
			if text.isEmpty {
				text = "🔥"
			} else {
				text += "🔥"
			}
		}
		dogScoreLabel.text = text
		self.dogScore = score
	}
	
	@IBAction func submitDog(_ sender: Any) {
		let metadata = StorageMetadata()
		metadata.contentType = "image/jpeg"
		
		if dogNameTextField.text == "" {
			let alert = UIAlertController(title: "Woops", message: "Please enter a name for the dog.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true)
			return
		} else if dogBreedTextField.text == "" {
			let alert = UIAlertController(title: "Woops", message: "Please enter a breed for the dog.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true)
			return
		} else if dogImageView.image == nil {
			let alert = UIAlertController(title: "Woops", message: "Please add a photo of the dog.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alert, animated: true)
			return
		}
		
		if delegate.location != nil {
			let latitude = delegate.location?.coordinate.latitude
			let longitude = delegate.location?.coordinate.longitude
			
			let newDogUUID = UUID.init()
			var dogDownloadURL = ""
			
			let databaseRef = Database.database().reference()
			let dogRef = databaseRef.child("dogs").childByAutoId()
			let userRef = databaseRef.child("users").child((Auth.auth().currentUser?.uid)!)
			
			let user = Auth.auth().currentUser?.uid
			
			let dogPhotosReference = storageRef.child("dogPhotos").child("\(String(describing: newDogUUID)).jpg")
			
			dogPhotosReference.putData(imageData!, metadata: metadata, completion: { (metatada, error) in
				if error != nil {
					print(error!.localizedDescription)
					return
				}
				
				// Image upload was success! Let's get a reference to the dogPhoto URL.
				dogPhotosReference.downloadURL(completion: { (url, error) in
					if error != nil {
						print(error!)
						return
						//TODO: Handle download url error
					}
					// Successfuly got a URL, let's save that along with our dog info to the DB.
					dogDownloadURL = (url?.absoluteString)!
					
					let dogValues = ["creator": user!,
					                 "name": self.dogNameTextField.text!,
					                 "breed": self.dogBreedTextField.text!,
					                 "score": String(self.dogScore),
					                 "latitude": String(describing: latitude!),
					                 "longitude": String(describing: longitude!),
					                 "imageURL": dogDownloadURL,
					                 "timestamp": String(describing: NSDate.timeIntervalSinceReferenceDate),
									 "upvotes": "0"]
					
					let dogKey = dogRef.key
					
					dogRef.updateChildValues(dogValues, withCompletionBlock: { (error, ref) in
						if error != nil {
							print(error!.localizedDescription)
							return
						}
						
					})
					
					// At the same time, let's update the user's list of dogs with the dog we've made
					userRef.child("dogs").child(dogKey).setValue("true", withCompletionBlock: { (error, ref) in
						if error != nil {
							print(error!.localizedDescription)
							return
						}
					})
					
					userRef.child("reputation").observeSingleEvent(of: .value, with: { (snap) in
						var currentRep = Int(snap.value as! String)!
						currentRep += 25
						userRef.child("reputation").setValue(String(currentRep))
					})
				})
			})
			
			
		} else {
			let alert = UIAlertController(title: "Location", message: "It looks like Dog Spotter doesn't have access to your location. You can't post a dog. To enable location, go to Settings > Privacy > Location Services.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
				self.dismiss(animated: true, completion: nil)
			}))
			present(alert, animated: true)
			return
		}
		self.dismiss(animated: true, completion: nil)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.dogNameTextField {
			self.dogBreedTextField.becomeFirstResponder()
		}
		else if textField == self.dogBreedTextField {
			textField.resignFirstResponder()
		}
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.3) {
			self.dogInfoViewBottomConstraint.constant = 250
			self.view.layoutIfNeeded()
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 0.3) {
			self.dogInfoViewBottomConstraint.constant = 28
			self.view.layoutIfNeeded()
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}
