//
//  AlertController.swift
//  Dife
//
//  Created by Difeng Chen on 3/21/18.
//  Copyright © 2018 Difeng Chen. All rights reserved.
//

import UIKit

class AlerController{
    static func showAllert(_ inViewController: UIViewController, title: String, Message: String){
        let alert = UIAlertController(title: title, message: Message, preferredStyle:.alert)
        let action = UIAlertAction(title: "OK", style: .default, handler:nil)
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }
}
