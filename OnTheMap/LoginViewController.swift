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
    
    // UI items
    @IBOutlet weak var udacityEmail: UITextField!
    @IBOutlet weak var udacityPassword: UITextField!
    @IBOutlet weak var udacityLogin: UIButton!
    @IBOutlet weak var udacitySignUp: UIButton!
    @IBOutlet weak var activityIndivator: UIActivityIndicatorView!
   
    //***************************************************
    //Variables
    //***************************************************

    var appDelegate: AppDelegate!
    var session: NSURLSession!

    //***************************************************
    // Udacity SignUp URL - declared here so it's easy to 
    // find and change later if needed
    //***************************************************

    var udacitySignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
    
    //***************************************************
    //The default housekeeping functions for the controller
    //***************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
    }
    
    
    //***************************************************
    //Delegate functions for the textfields. 
    //I still like my return solution better than Udacity's touchtap so I'm using it here
    //***************************************************
    
    //The user hit return, so stop editing and disregard the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
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
        UIApplication.sharedApplication().openURL(NSURL(string: udacitySignUpURL)!)
    }

    
    //***************************************************
    // The essential function required for login
    //***************************************************
    @IBAction func loginButtonTouch(sender: UIButton) {
        //Start the acitity indicator
        activityIndivator.startAnimating()
        // Call the login verification function
        OTMClient.sharedInstance().doUdacityLogin(udacityEmail.text, password: udacityPassword.text) { (success, error) in
            if success{
               //We're logged in so present the tab controller with map/list
                dispatch_async(dispatch_get_main_queue(), {
                    //Stop the indicator
                    self.activityIndivator.stopAnimating()
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
                    self.activityIndivator.stopAnimating()
                    OTMClient.sharedInstance().errorDialog(self, errTitle: "Login Failed" , action: "OK", errMsg: error!)
                }
            }// error sequence
        }// doUdacityLogin
    }// loginButtonTouch
    
}// Class declaration

