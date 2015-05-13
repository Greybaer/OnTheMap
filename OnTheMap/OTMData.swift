//
//  OTMData.swift
//  OnTheMap
//
// Data structures for the On the Map App
//
//  Created by Greybear on 5/11/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import Foundation
import MapKit


//***************************************************
// My Udacity User Data
// I don't know if this is all needed, but it's a good exercise
//***************************************************

struct My{
    var FirstName: String? = ""
    var LastName: String? = ""
    var Email: String? = ""
    var mapString: String? = ""
    var Weblink: String? = ""
}

//***************************************************
// Student location information
//***************************************************

struct StudentInformation{
    var firstName = ""
    var lastName = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mapString = ""
    var mediaURL = ""
    
    init(dictionary: [String : AnyObject]){
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
    }
    
    static func studentInfoFromData(results: NSArray) -> [StudentInformation]{
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result as! [String : AnyObject]))
        }
        return students
    }
    
}