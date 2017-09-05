//
//  NewDogViewController.swift
//  DogSpotter
//
//  Created by Cody Potter on 9/2/17.
//  Copyright © 2017 Cody Potter. All rights reserved.
//

import UIKit

class NewDogViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let delegate = UIApplication.shared.delegate as! AppDelegate
    var dogScore: Int = 1
    var image: UIImage?
    var dogs: [Dog] = []
    
    @IBOutlet var dogRateSlider: UISlider!
    @IBOutlet var dogScoreLabel: UILabel!
    @IBOutlet var dogBreedTextField: UITextField!
    @IBOutlet var dogNameTextField: UITextField!
    @IBOutlet var dogImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        dogScore = score
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
        camera.delegate = self
		present(camera, animated: true)
    }
    
    @IBAction func submitDog(_ sender: Any) {
        if dogNameTextField.text == "" {
            let alert = UIAlertController(title: "Woops", message: "Please enter a name for the dog.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }

        if delegate.location != nil {
            let newDog = Dog(name: dogNameTextField.text!, score: dogScore, picture: image!, location: delegate.location!)
            dogs.append(newDog)
            print(dogs.last!)
            
            //dropNewPin(locatedAt: dogs.last!.location, name: dogs.last!.name, rate: dogs.last!.score)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        self.dismiss(animated: true, completion: {
            self.dogImageView.image = self.image
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
