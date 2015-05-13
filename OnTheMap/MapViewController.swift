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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    //Right Bar Button Items
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var reloadDataButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //***************************************************
        // Get the Student Location Data and populate the map
        //***************************************************

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
                    self.mapView.addAnnotations(OTMClient.sharedInstance().annotations)
                }
            }//else
        }//getStudentLocationData
        
        //Add the two right bar buttons programmatically, as stroyboard won't do the work
        self.navigationController!.toolbar.hidden = true
        self.navigationItem.setRightBarButtonItems([reloadDataButton,addLocationButton], animated: true)
     }//viewDidLoad
    
    
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
    // Reload the user data at the user's request
    //***************************************************
    @IBAction func reloadButtonTouch(sender: AnyObject) {
    }
    
    //***************************************************
    //Add A location to the map or list
    //***************************************************
    @IBAction func addLocationButtonTouch(sender: AnyObject) {
    }



    //***************************************************
    // Back to Login, the user wants out
    //***************************************************

    @IBAction func mapLogOut(sender: UIBarButtonItem) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }




}//Class
    

/* 
These are misc. test functions I used to learn a bit more about map views

//***************************************************
// Check to see if location services are available.
// If so, ask for permission to locate ourselves
//***************************************************

if(CLLocationManager.locationServicesEnabled()){
//Create a location manager
locationManager = CLLocationManager()
// This triggers the didChangeAuthorizationStatus function if not already set
//And pops up a dialog to get permission
locationManager.requestWhenInUseAuthorization()
locationManager.delegate = self

//Set the initial map view
//let location = locations.last as! CLLocation
//let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
//self.mapView.setRegion(region, animated: true)

}

//***************************************************
// Security function to verify the user is OK with us using current location
//***************************************************

func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//If the user authorizes the use of location services, this shows the current location
if status == CLAuthorizationStatus.AuthorizedWhenInUse{
locationManager.desiredAccuracy = kCLLocationAccuracyBest
locationManager.startUpdatingLocation()
//Insert our current location as a test
//mapView.showsUserLocation = true
}

//***************************************************
// Override function to retrieve the current location
//***************************************************

func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//This basically forces the map to hover over our location. It's a test, so remove this or comment out
let location = locations.last as! CLLocation
let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
self.mapView.setRegion(region, animated: true)
}
*/*/*/*/*/*/*/

//***************************************************
// Before we display, get the user data with our id
//***************************************************
//OTMClient.sharedInstance().getUdacityInfo() { (success, errorString) in
//We only care about errors right now
//    if errorString != nil{
//Display the returned error
//       dispatch_async(dispatch_get_main_queue()){
//           OTMClient.sharedInstance().errorDialog(self, errTitle: "Failed to retrieve user information", action: "OK", errMsg: errorString!)
//       }//dispatch
//   }else{
//NOTE - Here's how we access data in OTMClient!
//println(OTMClient.sharedInstance().my.FirstName)

//Check to make sure the dialog will show from here - and it does
//OTMClient.sharedInstance().errorDialog(self, errTitle: "Success", action: "OK", errMsg: "Got my user data")

//   }//if
//}// getUdacityInfo


