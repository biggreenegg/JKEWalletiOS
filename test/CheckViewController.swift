//
//  CheckViewController.swift
//  test
//
//  Created by Tim Choo on 3/28/16.
//  Copyright © 2016 Tim Choo. All rights reserved.
//

import UIKit
import IBMMobileFirstPlatformFoundation

class CheckViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WLDelegate {

    var accountsArray = [String]()
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    weak var activeField: UITextField?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let barViewControllers = self.tabBarController?.viewControllers
        let accountsVC = barViewControllers![0] as! AssetViewController
        accountsArray = accountsVC.accountsArray
        
        
        // Do any additional setup after loading the view.
        let accountPickerView = UIPickerView()
        accountPickerView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 68/255, green: 108/255, blue: 179/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        submitButton.layer.borderColor = UIColor.blueColor().CGColor
        submitButton.layer.borderWidth = 1
        submitButton.layer.cornerRadius = 5
        
        accountTextField.inputView = accountPickerView
        accountTextField.inputAccessoryView = toolBar
        dateTextField.inputAccessoryView = toolBar
        
    }
    
    override func viewWillAppear(animated: Bool) {
        setFieldDefaultValues()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setFieldDefaultValues() {
        accountTextField.text = accountsArray[0]
        let todayDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(todayDate)
    }
    
    @IBAction func dateFieldEditing(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateTextField.text = dateFormatter.stringFromDate(sender.date)
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accountsArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accountsArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        accountTextField.text = accountsArray[row]
    }
    
    func donePicker() {
        dateTextField.resignFirstResponder()
        accountTextField.resignFirstResponder()
    }
    
    
    @IBAction func SubmitCheck(sender: UIButton) {
        
        /* 7.1 stuffz
        let invocationData = WLProcedureInvocationData(adapterName: "NativeiosAdapter", procedureName: "jkeEnterCheck")
        var randomID: Int = 0
        randomID = Int(arc4random_uniform(900000)+100000)
        let amountParam = Float(amountTextField.text!)
        let username = "elong"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        let dt = dateFormatter.dateFromString(dateTextField.text!)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateParam = dateFormatter.stringFromDate(dt!)
        
        invocationData.parameters = [randomID,amountParam!,dateParam,accountTextField.text!,descriptionTextField.text!,username]
        WLClient.sharedInstance().invokeProcedure(invocationData, withDelegate: self)
        */
        var randomID: Int = 0
        randomID = Int(arc4random_uniform(900000)+100000)
        let amountParam = Float(amountTextField.text!)
        let username = "elong"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        let dt = dateFormatter.dateFromString(dateTextField.text!)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateParam = dateFormatter.stringFromDate(dt!)
        
        let request = WLResourceRequest(URL: NSURL(string:"/adapters/NativeiosAdapter/jkeEnterCheck"), method: WLHttpMethodPost)
      
        //request.setQueryParameterValue("[\(randomID),\(amountTextField.text!),\(String(dateParam)),\(accountTextField.text!),\(descriptionTextField.text!),\(username)]", forName: "params")
        /*
        request.setQueryParameterValue("['63459','75','04/17/2016','Checking 2','stuffing','elong']", forName: "params")
         
         request.sendWithCompletionHandler{
            (response, error) -> Void in
            if(error == nil){
                NSLog(response.responseText)
                self.onSuccess(response)
            }
            else{
                //NSLog(request.getQueryString())
                NSLog(error.description)
            }
         }
        */

       
        
    
        let formParams = ["params" : "['\(randomID)','\(amountParam!)','\(dateParam)','\(accountTextField.text!)','\(descriptionTextField.text!)','\(username)']"]
        
        //let formParams = ["params" : "[66598, 89, 04/17/2016, Checking 2, important things, elong]"]
        
        request.sendWithFormParameters(formParams){(response, error) -> Void in
            if(error == nil){
                NSLog(response.responseText)
                self.onSuccess(response)
            }
            else{
                NSLog(String(formParams))
                NSLog(error.description)
            }
        }
    
    }
    
    func onSuccess(response: WLResponse!) {
        NSLog(response.responseText)
        print("------onSuccess")
        
        //--- Display an alert dialog
        let alertController = UIAlertController(title: "Success", message: "Check has been saved", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        //--- Clear all the fields
        amountTextField.text = ""
        setFieldDefaultValues()
        descriptionTextField.text = ""
        if descriptionTextField.isFirstResponder() {
            descriptionTextField.resignFirstResponder()
        }
        
    }
    
    func onFailure(response: WLFailResponse!) {
        
        print("----- onFailure")
        //--- Display an alert dialog
        let alertController = UIAlertController(title: "Error", message: "The check could not be saved", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        //--- Clear all the fields
        amountTextField.text = ""
        setFieldDefaultValues()
        descriptionTextField.text = ""
        if descriptionTextField.isFirstResponder() {
            descriptionTextField.resignFirstResponder()
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
    }
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        amountTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
