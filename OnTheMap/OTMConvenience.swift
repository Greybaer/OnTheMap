//
//  OTMConvenience.swift
//  OnTheMap
//
//  Convenience functions
//
//  Created by Greybear on 4/28/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit
import Foundation

extension OTMClient{
    
    //***************************************************
    // Strip the first five chars out of response data from Udacity
    //***************************************************
    func subset(data: NSData) -> NSData{
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
        return newData
    }
    
    //***************************************************
    // Create an AlertView to display an error message
    //***************************************************
    func errorDialog(viewController:UIViewController, errTitle: String, action: String, errMsg:String) -> Void{
        let alertController = UIAlertController(title: errTitle, message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //***************************************************
    // Check an error message to see if it's a Udacity error and 
    // make it look nice
    //***************************************************
    func formatError(error: String) -> String{
        //Check for the telltale colon
        if error.rangeOfString(":") != nil{
            //Break up the string - Should always result in two strings. May want to do better error checkin in the future...
            var errArray = error.componentsSeparatedByString(":")
            return errArray[1] as String
        }else{
            // Nope, looks OK so just send it back
            return error
        }
    }//formatError
    
    //***************************************************
    // validateURL - Thanks to Dan Riehs!
    //***************************************************
    func validateUrl(url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let match = url.rangeOfString(pattern, options: .RegularExpressionSearch){
            return true
        }
        return false
    }
    
}//class

