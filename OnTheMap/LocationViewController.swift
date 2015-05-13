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

class LocationViewController: UIViewController, MKMapViewDelegate  {

    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var locationMap: MKMapView!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var studyLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var urlLink: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //default the map to hidden until we click ze button
        locationMap.hidden = true
        //and hide the URL link textfield
        urlLink.hidden = true
        //Show the upper labels
        whereLabel.hidden = false
        studyLabel.hidden = false
        todayLabel.hidden = false
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action Methods
    @IBAction func findLocationButtonTouch(sender: UIButton) {
        //Hide the upper labels
        whereLabel.hidden = true
        studyLabel.hidden = true
        todayLabel.hidden = true
        //Now show the map
        locationMap.hidden = false
        //and the URL textfield
        urlLink.hidden = false
    }
    
}
