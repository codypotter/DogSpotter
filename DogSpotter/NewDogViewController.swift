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

protocol NewDogInfo {
	func dogDataReceived(name: String, breed: String, score: Int, image: UIImage)
}

class NewDogViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let delegate = UIApplication.shared.delegate as! AppDelegate
	var dogInfoDelegate: NewDogInfo?
	
    var dogScore: Int = 1
    var image: UIImage?
	var imageData: Data?
	
	@IBOutlet var dogInfoView: ShadowedView?
	@IBOutlet var dogRateSlider: UISlider!
	@IBOutlet var dogScoreLabel: UILabel!
	@IBOutlet var dogBreedTextField: UITextField!
	@IBOutlet var dogNameTextField: UITextField!
    @IBOutlet var dogImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		self.dogNameTextField.delegate = self
		self.dogBreedTextField.delegate = self
    }
	
	override func viewWillLayoutSubviews() {
		dogInfoView?.shadowLayer.elevation = 2.0
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
		present(camera, animated: true)
    }
	
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageData = UIImageJPEGRepresentation(editedImage, 0.70)
			
        }
        self.dismiss(animated: true, completion: {
            self.dogImageView.image = self.image
        })
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
			
			let databaseRef = FIRDatabase.database().reference()
			let dogRef = databaseRef.child("dogs").childByAutoId()
			let userRef = databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("dogs")
			let user = FIRAuth.auth()?.currentUser?.displayName!
			
			let dogValues = ["creator": user!, "name": String(describing: dogNameTextField.text), "breed": String(describing: dogBreedTextField.text), "score": String(dogScore), "latitude": String(describing: latitude!), "longitude": String(describing: longitude!) ]
			let userValues = ["dogAutoId": dogRef.key]
			
			dogRef.updateChildValues(dogValues, withCompletionBlock: { (error, ref) in
				if error != nil {
					print(error!)
					return
					//TODO: Handle malfunction of database update
				} else {
					print("Saved dog successfully!")
				}
			})
			
			userRef.updateChildValues(userValues, withCompletionBlock: { (error, ref) in
				if error != nil {
					print(error!)
					return
					//TODO: Handle malfunction of database update
				} else {
					print("Saved user-dog reference successfully!")
				}
			})
			
			Fir
			
		} else {
			return
			//TODO: Handle delegate location == nil alert
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
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}
