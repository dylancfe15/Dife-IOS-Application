//
//  feedbackViewController.swift
//  Dife
//
//  Created by Difeng Chen on 3/21/18.
//  Copyright © 2018 Difeng Chen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
class feedbackViewController: UIViewController,UITextViewDelegate {
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var submitBotton: UIButton!
    var ref: DatabaseReference!
    let user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        submitBotton.layer.cornerRadius = submitBotton.frame.height/2
        feedbackTextView.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
//        if(emailTextField.text == ""){
//            AlerController.showAllert(self, title: "Alert", Message: "Please enter your email.")
//        }else
        if(feedbackTextView.text != "Enter your feedback here..." && feedbackTextView.text != ""){
            ref.child("Feedback").child(String(arc4random_uniform(1000000)).replacingOccurrences(of: ".", with: "")).child("Content").setValue(feedbackTextView.text)
            feedbackTextView.textColor = UIColor.lightGray
            feedbackTextView.endEditing(true)
            AlerController.showAllert(self, title: "Thank you", Message: "Your feedback is sent.")
            feedbackTextView.text = "Enter your feedback here..."
            
        }else{
            AlerController.showAllert(self, title: "Alert", Message: "Please enter your feedback.")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(feedbackTextView.text == "Enter your feedback here..."){
            feedbackTextView.text = ""
            feedbackTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(feedbackTextView.text == ""){
            feedbackTextView.text = "Enter your feedback here..."
            feedbackTextView.textColor = UIColor.lightGray
        }
    }

}
