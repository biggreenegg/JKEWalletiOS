//
//  ViewController.swift
//  test
//
//  Created by Tim Choo on 3/13/16.
//  Copyright © 2016 Tim Choo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "nightfall")
        self.view.insertSubview(backgroundImage, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func textFieldDoneEditing(sender: UITextField) {
            sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

}

