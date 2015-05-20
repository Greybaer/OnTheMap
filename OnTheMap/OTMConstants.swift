//
//  OTMConstants.swift
//  OnTheMap
//
//  Constant values for the OTM app
//
//  Created by Greybear on 4/28/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

extension OTMClient {

    //***************************************************
    // Constant values
    //***************************************************

    struct Constants{
        //API and ID Keys
        static let ParseAppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //***************************************************
        //URLS
        //***************************************************

        //Udacity API
        static let udacitySignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
        static let UdacitySessionURL: String = "https://www.udacity.com/api/session"
        static let UdacityUserURL: String = "https://www.udacity.com/api/users/"
        
               
        //Parse API
        static let ParseAPIURL = "https://api.parse.com/1/classes/StudentLocation"
                
    }

}
