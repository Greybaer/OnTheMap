//
//  LoginViewController.swift
//  OnTheMap
//
//  App Login View Controller - Heavy lifting functions in OTMClient
//
//  Created by Greybear on 4/28/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //TextFields
    @IBOutlet weak var udacityEmail: UITextField!
    @IBOutlet weak var udacityPassword: UITextField!
    //Burrons
    @IBOutlet weak var udacityLogin: UIButton!
    @IBOutlet weak var udacitySignUp: UIButton!
    //Activity Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
    //***************************************************
    //Variables
    //***************************************************

    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    //***************************************************
    //The default housekeeping functions for the controller
    //***************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the app Delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Get the shared session
        session = NSURLSession.sharedSession()
        
        //We're the delegate for the textfields
        udacityEmail.delegate = self
        udacityPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Hide the nav bar on the login view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //If we're looping back from logout we want these empty
        udacityEmail.text = ""
        udacityPassword.text = ""
        //Make the username field the responder by default to avoid having to click
        udacityEmail.becomeFirstResponder()
        
    }
    
    
    //***************************************************
    //Delegate function for the textfields.
    //***************************************************
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //The user hit return, so stop editing and use the signal to change the field focus
        switch (textField){
        //This implements textfield entry progressiion without clicks using return.
        case udacityEmail:
            udacityEmail.resignFirstResponder()
            udacityPassword.becomeFirstResponder()
        default:
            udacityPassword.resignFirstResponder()
            udacityLogin.becomeFirstResponder()
        }//switch
        //discard the return
        return false
    }
    
    //When the user edits the password field, the text should become obscured, but not before. We'll manually set that attribute when the field is editing
    func textFieldDidBeginEditing(textField: UITextField) {
        if udacityPassword.editing{
            udacityPassword.secureTextEntry = true
        }
    }
    
    //***************************************************
    // User wants to create a Udacity Account
    //***************************************************
    @IBAction func showUdacitySignUpPage(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: OTMClient.Constants.udacitySignUpURL)!)
    }

    
    //***************************************************
    // The essential function required for login
    //***************************************************
    @IBAction func loginButtonTouch(sender: UIButton) {
        //Start the acitity indicator
        activityIndicator.startAnimating()
        // Call the login verification function
        OTMClient.sharedInstance().doUdacityLogin(udacityEmail.text, password: udacityPassword.text) { (success, error) in
            if success{
                //Grab our user data for later use
                OTMClient.sharedInstance().getUdacityInfo() { (success, errorString) in
                    //We only care about errors right now
                        if errorString != nil{
                    //Display the returned error
                           dispatch_async(dispatch_get_main_queue()){
                               OTMClient.sharedInstance().errorDialog(self, errTitle: "Failed to retrieve user information", action: "OK", errMsg: errorString!)
                            }//dispatch
                    }//erroString
                    }//getUdacityInfo
               //We're logged in so present the tab controller with map/list
                dispatch_async(dispatch_get_main_queue(), {
                    //Stop the indicator
                    self.activityIndicator.stopAnimating()
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MapTabViewController") as! UITabBarController
                    //self.navigationController!.pushViewController(controller, animated: true)
                    //Modal presentation makes logout much easier.
                    self.navigationController!.presentViewController(controller, animated: true, completion: nil)
                })
            }// Success sequence
            else{
                //Display the returned error
                dispatch_async(dispatch_get_main_queue()){
                    //Stop the indicator
                    self.activityIndicator.stopAnimating()
                    OTMClient.sharedInstance().errorDialog(self, errTitle: "Login Failed" , action: "OK", errMsg: error!)
                }
            }// error sequence
        }// doUdacityLogin
    }// loginButtonTouch    
}// Class declaration

