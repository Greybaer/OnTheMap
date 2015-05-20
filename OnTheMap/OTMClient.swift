//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Greybear on 4/28/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//
//  Client Network and housekeeping functions
//

//import UIKit
import Foundation
import MapKit
import CoreLocation

class OTMClient: NSObject {
    
    //***************************************************
    //Variables
    //***************************************************

    var session: NSURLSession
    
    //Udacity session ID
    var sessionID: AnyObject? = nil
    //Udacity Account (user) id
    var userID: String? = nil
    
    
    // Create an instance of my info struct
    var my = My()
    
    //Student Info struct
    var studentInfo: [StudentInformation] = [StudentInformation]()
    
    //The array of annotations we'll use to populate the map
    var annotations = [MKPointAnnotation]()
    
    
    //***************************************************
    // Housekeeping functions
    //***************************************************
    
    //***************************************************
    //Create a shared session for the NSURLSession calls
    //***************************************************
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    
    //***************************************************
    // Shared Instance
    //***************************************************
    class func sharedInstance() -> OTMClient {
        
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        
        return Singleton.sharedInstance
    }
    
    //***************************************************
    // Network call functions
    //***************************************************

    //***************************************************
    // Udacity Login function
    //***************************************************
    
    func doUdacityLogin(email: String!, password: String!, completionHandler: (success: Bool, errorString: String?) -> Void) {
        //Build the request
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacitySessionURL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        //Get the session
        //let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil{
                completionHandler(success: false, errorString: String(stringInterpolationSegment: downloadError.localizedDescription))
            }else{
                //subset the data and save the id after checkin for errors
                var userdata = self.subset(data)
                OTMClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError?.localizedDescription)
                    }else{
                        if let sessionData = JSONData["session"] as? NSDictionary{
                            //Save the session and user ids for future use
                            self.sessionID = sessionData["id"]
                            //We have to dig the user ID out of the account dictionary
                            if let accountData = JSONData["account"] as? NSDictionary{
                                self.userID = accountData["key"] as? String
                                //We saved the ids so go ahead and grab our user data for later
                                completionHandler(success: true, errorString: nil)
                            }else{
                                //Failed to get the userID, so return a generic error
                                completionHandler(success: false, errorString: "Unable to obtain UserID. Please re-try login.")
                            }
                        }else{
                            if let sessionError = JSONData["error"] as? String{
                                //We got an error, but Udacity sends some different messages. Let's pretty those up
                                //Fromat the error if needed
                                var formattedError = self.formatError(sessionError)
                                //And then show it
                                completionHandler(success: false, errorString: formattedError)
                            }else{
                                //Failed to get the sessionID some other way, so return a generic error
                                completionHandler(success: false, errorString: "Unable to obtain Session ID. Please re-try login.")
                            }//else
                        }//else
                    }//else
                }//parseJSON
           }//else
        }//taskrequest
        task.resume()
    }//doUdacityLogin
    
    //***************************************************
    // Get Udacity Information on ourselves, 
    // using the user id
    //***************************************************
    func getUdacityInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        //Build the request
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityUserURL + self.userID!)!)

        //Get the session
        //let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if downloadError != nil{
                //println(error)
                completionHandler(success: false, errorString: downloadError.localizedDescription)
            }else{
                //subset the data and save the id after checking for errors
                var userdata = self.subset(data)
                OTMClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                    //println("JSON User Data: \(JSONData)")
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                    //We seem to have gotten the info, so extract and save it
                    }else{
                        if let sessionData = JSONData["user"] as? NSDictionary{
                            //println("User Data: \(sessionData)")
                            self.my.FirstName = sessionData["first_name"] as? String
                            self.my.LastName = sessionData["last_name"] as? String
                            //Store the userID so we can get it later!
                            self.my.userID = self.userID
                            
                            //These probably won't be used, but hey, who knows?
                            self.my.Weblink = sessionData["website_url"] as? String
                            //We need to dig the email out of a separate dictionary
                            if let emailData = sessionData["email"] as? NSDictionary{
                                //println("Email Data: \(emailData)")
                                self.my.Email = emailData["address"] as? String
                                //println(self.myEmail!)
                                completionHandler(success: true, errorString: nil)
                            }//emailData
                        }//sessionData
                    }//else
                }//parseJSONData
            }// else
        }// sessionDataTask
        task.resume()
    }// getUdacityInfo
    
    //***************************************************
    // Get Student location data (Parse API)
    // and create the student information structure
    //***************************************************
    func getStudentLocationData(completionHandler: (success: Bool, errorString: String?) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.ParseAPIURL)!)
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if downloadError != nil { // Handle any download error...
                completionHandler(success: false, errorString: downloadError.localizedDescription)
            }else{
                OTMClient.parseJSONWithCompletionHandler(data) { (JSONData, parseError) in
                        //If we failed to parse the data return the reason why
                        if parseError != nil{
                            completionHandler(success: false, errorString: parseError!.localizedDescription)
                            //We seem to have gotten the info, so extract and save it
                        }else{
                            //O.M.G. - it's an array of dictionaries. I might just figure this all out yet...
                            var results = JSONData["results"] as! NSArray
                            //Now we can use the StudenInformation struct to return us an array of dictionary info we need to create the annotations
                            self.studentInfo = StudentInformation.studentInfoFromData(results)
                            completionHandler(success: true, errorString: nil)
                        }
                }//parseJSONData
            }//else
        }//dataTask
        task.resume()
    }//getStudentDataLocation
    
    //***************************************************
    // Post our location from the 
    // LocationViewController input and our saved data
    //***************************************************
    func postMyLocation(location: MKPointAnnotation, completionHandler: (success: Bool, errorString: String?) -> Void){
        // extract the lat and long from the location annotation
        let coordinates = location.coordinate
        let lat = coordinates.latitude
        let long = coordinates.longitude
        //Create the request
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.ParseAPIURL)!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //Create the string for posting
        request.HTTPBody = "{\"uniqueKey\": \"\(self.my.userID!)\", \"firstName\": \"\(self.my.FirstName!)\", \"lastName\": \"\(self.my.LastName!)\", \"mapString\": \"\(self.my.mapString!)\", \"mediaURL\": \"\(self.my.Weblink!)\", \"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
        //Make the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle any download error...
                completionHandler(success: false, errorString: error.localizedDescription)
            }else{
                OTMClient.parseJSONWithCompletionHandler(data) { (JSONData, parseError) in
                    //If we failed to parse the data return the reason why
                    if parseError != nil{
                        completionHandler(success: false, errorString: parseError!.localizedDescription)
                    }else{
                        completionHandler(success: true, errorString: nil)
                    }
                }//parseJSONData
            }//else
        }//taskrequest
        task.resume()
    }//postMyLocation
    
    
    //***************************************************
    // Geocode function for user's location
    //***************************************************
    func geocodeAddress(address: String!, completionHandler: (annotation: AnyObject?, error: String?)-> Void) {
        //call the geocoding function
       let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [AnyObject]!, error: NSError?) in
            if error != nil{
                completionHandler(annotation: nil, error: error!.localizedDescription)
            }else if placemarks.count > 0{
                //Only want one for this app
                let placemark = placemarks[0] as! CLPlacemark
                let location = placemark.location
                //And add the pin for the new location
                var annotation = MKPointAnnotation()
                //Convert to CLLocationCoordinate2D
                let coords = location.coordinate
                annotation.coordinate = coords
                annotation.title = "\(self.my.FirstName!) \(self.my.LastName!)"
                completionHandler(annotation: annotation, error: nil)
            }//if/else
        })//completionhandler
    }//geocodeAddress
    

    //***************************************************
    // Helper functions
    //***************************************************
    
    //***************************************************
    // Helper: Given raw JSON, return a usable Foundation object
    //***************************************************
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    //***************************************************
    // Create the annotation structure from student data
    //***************************************************
    func getAnnotationData(){
       
        for student in self.studentInfo {
           //Get the geolocation
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            //The annotation object
            //This was a point of some confusion - the annotation object MUST be re-created for every student
            var annotation = MKPointAnnotation()
            //populate the coordinates
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            //Get the first and last name
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            //and append it to the annotations list
            self.annotations.append(annotation)
        }//for
    }//getAnnotationData
}
