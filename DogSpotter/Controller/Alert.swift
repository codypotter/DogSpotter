//
//  Alert.swift
//  
//
//  Created by Cody Potter on 3/7/18.
//

import UIKit

class Alert: UIViewController {
    var message: String = ""
    var title: String = ""
    var alertController: UIAlertController
    
    init(title: String, message: String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(action)
    }
    
    func display() {
        present(alertController, animated: true, completion: nil)
    }
}
