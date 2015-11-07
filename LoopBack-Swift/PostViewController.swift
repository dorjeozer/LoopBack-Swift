//
//  ViewController.swift
//  
//
//  Created by Jesse Sipola on 6.11.2015.
//  Copyright © 2015 . All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITextFieldDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var postTextField: UITextField!
    
    @IBAction func saveButtonTouched(sender: UIButton) {
        if nameTextField.text != nil && !nameTextField.text!.isEmpty && postTextField.text != nil && !postTextField.text!.isEmpty {
            let post = Post()
            post.name = nameTextField.text!
            post.post = postTextField.text!
            post.saveInBackground {
                (success, error) -> Void in
                if error == nil {
                    print("Hurray, save was succesful.")
                } else {
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        postTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

