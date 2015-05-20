//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Greybear on 5/4/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {

    //MapView
    @IBOutlet weak var mapView: MKMapView!
    //Logout Button
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    //Right Bar Button Items
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var reloadDataButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add the two right bar buttons programmatically, as storyboard won't do the work
        self.navigationController!.toolbar.hidden = true
        self.navigationItem.setRightBarButtonItems([reloadDataButton,addLocationButton], animated: true)
     }//viewDidLoad
   
    override func viewWillAppear(animated: Bool) {
        reloadButtonTouch(self)
    }
    //***************************************************
    // Map delegate Methods
    //***************************************************

    
    //***************************************************
    // Re-use method for displaying pins - 
    // ripped from the PinSample code. I have plenty to do without re-inventing the wheel
    //***************************************************
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //***************************************************
    // Ditto - ripped from PinSample. As Ron Swanson would say - "Please and Thank YOU"
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    //***************************************************
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            //TODO: Need to check for URL validity here - if invalid pop an alert
            if OTMClient.sharedInstance().validateUrl(annotationView.annotation.subtitle!) == false{
                dispatch_async(dispatch_get_main_queue()){
                    //If the URL fails pop an alert
                    OTMClient.sharedInstance().errorDialog(self, errTitle: "Unable to Open Page" , action: "OK", errMsg: "The Student's URL is invalid")
                }
                
            }else{
                //Show the user's weblink
                app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
            }

         }
    }
    
    
    //***************************************************
    // UI Action functions
    //***************************************************

    
    //***************************************************
    // Load/Reload the user data 
    // On view appearing or at the user's request
    //***************************************************
    @IBAction func reloadButtonTouch(sender: AnyObject) {
        // Get the Student Location Data and populate the map
        // Calling this here because this will auto refresh after location entry
        
        OTMClient.sharedInstance().getStudentLocationData() { (success, errorString) in
            if errorString != nil{
                //Display the returned error
                dispatch_async(dispatch_get_main_queue()){
                    OTMClient.sharedInstance().errorDialog(self, errTitle: "Failed to retrieve student information", action: "OK", errMsg: errorString!)
                }//dispatch
            }else{
                //We now have the struct populated so we create annotations
                OTMClient.sharedInstance().getAnnotationData()
                //and add them to the map
                dispatch_async(dispatch_get_main_queue()){
                    //Clear the map if needed
                    let annotationsToRemove = self.mapView.annotations
                    if annotationsToRemove.count > 0 {
                        self.mapView.removeAnnotations(annotationsToRemove)
                    }
                    self.mapView.addAnnotations(OTMClient.sharedInstance().annotations)
                }
            }//else
        }//getStudentLocationData
    }
    
    //***************************************************
    //Display Location View to add user location
    //***************************************************
    @IBAction func addLocationButtonTouch(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LocationViewController") as! UIViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }



    //***************************************************
    // Back to Login, the user wants out
    //***************************************************
    @IBAction func mapLogOut(sender: UIBarButtonItem) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}//Class
