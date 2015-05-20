//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Greybear on 5/13/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {


    //Our map view
    @IBOutlet weak var locationMap: MKMapView!
    //Labels
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    //TextFields
    @IBOutlet weak var locationAddress: UITextField!
    @IBOutlet weak var urlLink: UITextField!
    //Buttons
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitURLButton: UIButton!
    //Activity Indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Save a copy of the location annotation to add the URL
    //We'll also pass this to the post method
    var userlocation = MKPointAnnotation()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //We're our own delegate
        locationAddress.delegate = self
        urlLink.delegate = self
        
        //default the map to hidden until we click ze button
        locationMap.hidden = true
        submitURLButton.hidden = true
        //and hide the URL link textfield
        urlLink.hidden = true
        
        //Show the upper labels
        whereLabel.hidden = false
        studyLabel.hidden = false
        todayLabel.hidden = false
        
        //Hide the activity indicator
        activityIndicator.hidesWhenStopped = true
        
        //And the location field gets the focus
        self.locationAddress.becomeFirstResponder()
    }

    
    //***************************************************
    // Action Methods
    //***************************************************
    @IBAction func findLocationButtonTouch(sender: UIButton) {
        //Make sure the string contains something
        if self.locationAddress.text == ""{
            dispatch_async(dispatch_get_main_queue()){
                OTMClient.sharedInstance().errorDialog(self, errTitle: "Empty Address" , action: "OK", errMsg: "Please supply an address to locate")
            }//dispatch
            
        }else{  //address check
            //Start the acitivty indicator
            self.activityIndicator.startAnimating()
            //Attempt to geocode the location
            OTMClient.sharedInstance().geocodeAddress(self.locationAddress.text) { (annotation, error) in
                if error != nil{
                    dispatch_async(dispatch_get_main_queue()){
                        OTMClient.sharedInstance().errorDialog(self, errTitle: "Location Error" , action: "OK", errMsg: error!)
                    }//dispatch
                }else{
                    //Copy the location string to the user struct
                    OTMClient.sharedInstance().my.mapString = self.locationAddress.text
                    
                    //Prep the view for the transition to posting
                    //Hide the upper labels
                    self.whereLabel.hidden = true
                    self.studyLabel.hidden = true
                    self.todayLabel.hidden = true

                    //Now show the map
                    self.locationMap.hidden = false
                    
                    //and the URL textfield/Submit Button
                    self.urlLink.hidden = false
                    self.submitURLButton.hidden = false

                    //We want to be able to access the annotaiton properties here
                    let location = annotation as! MKPointAnnotation
                    //Keep a copy for later, d00d!
                    self.userlocation = location
                    
                    //Zoom the map to the annotation
                    let center = location.coordinate
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
                    self.locationMap.setRegion(region, animated: true)
                    
                    //and add the annotation we got back to the map
                    dispatch_async(dispatch_get_main_queue()){
                        self.locationMap.addAnnotation(location)
                    }//dispatch
                }//else
                //Stop the indicator
                self.activityIndicator.stopAnimating()
          }//geocodeAddress
        }//else
    }
    
    @IBAction func cancelButtonTouch(sender: AnyObject) {
        //The user changed his/her mind about adding a location, flee!
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitURLButtonTouch(sender: UIButton) {
        //Make sure the indicator is on top
        self.locationMap.bringSubviewToFront(self.activityIndicator)
        //Make it dark
        self.activityIndicator.color = UIColor.blackColor()
       
        //Check for a valid URL
        if OTMClient.sharedInstance().validateUrl(self.urlLink.text) == false{
            dispatch_async(dispatch_get_main_queue()){
                //If the URL fails pop an alert
                self.activityIndicator.stopAnimating()
                OTMClient.sharedInstance().errorDialog(self, errTitle: "Invalid URL" , action: "OK", errMsg: "Please enter a valid URL")
            }
        }else{
            //Start the indicator
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.startAnimating()
            }
            //Save the new URL over the retrieved one - no harm done
            OTMClient.sharedInstance().my.Weblink = self.urlLink.text
            //And call the post function with the new location coords
            OTMClient.sharedInstance().postMyLocation(self.userlocation) { (success, error) in
                if error != nil{
                    dispatch_async(dispatch_get_main_queue()){
                        self.activityIndicator.stopAnimating()
                        OTMClient.sharedInstance().errorDialog(self, errTitle: "Error Posting Location" , action: "OK", errMsg: error!)
                    }//dispatch
                }else{
                    //stop indicator
                    self.activityIndicator.stopAnimating()
                    //Dismiss the view
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }//else
  }//submitURLButton
}
