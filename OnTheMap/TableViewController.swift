//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Greybear on 5/12/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Buttons
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var reloadDataButton: UIBarButtonItem!
    //The table view
    @IBOutlet weak var studentTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add the two right bar buttons programmatically, as storyboard won't do the work
        self.navigationController!.toolbar.hidden = true
        self.navigationItem.setRightBarButtonItems([reloadDataButton,addLocationButton], animated: true)
    }//ViewDidLoad

    override func viewWillAppear(animated: Bool) {
        //Load the most recent table data and populate the table
        reloadButtonTouch(self)
    }
    
    //***************************************************
    //Table Delegate functions
    //***************************************************
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OTMClient.sharedInstance().studentInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Set up the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("MapTableCell") as! UITableViewCell
        //get the info
        let student = OTMClient.sharedInstance().studentInfo[indexPath.row]
        
        //Populate the cell
        //Pin graphic
        cell.imageView!.image = UIImage(named: "pin")
        //Student name
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        //This may help differentiate the multiple duplicates, and it adds value
        //Map location string
        cell.detailTextLabel!.text = "\(student.mapString)"
        return cell
    }
    
    //The user selected a cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //get the info
        let student = OTMClient.sharedInstance().studentInfo[indexPath.row]
        let app = UIApplication.sharedApplication()
        //Check for URL validity - if invalid pop an alert
        if OTMClient.sharedInstance().validateUrl(student.mediaURL) == false{
            dispatch_async(dispatch_get_main_queue()){
                //If the URL fails pop an alert
                OTMClient.sharedInstance().errorDialog(self, errTitle: "Unable to Open Page" , action: "OK", errMsg: "The Student's URL is invalid")
            }
            
        }else{
            //Show the user's weblink
            app.openURL(NSURL(string: student.mediaURL)!)
        }
    }
    
    //***************************************************
    //UI Action functions
    //***************************************************
    @IBAction func addLocationButtonTouch(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LocationViewController") as! UIViewController
        self.navigationController!.presentViewController(controller, animated: true, completion: nil)
    }
    
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
                //We now have the struct populated so we reload the table data
                //reload the table
                dispatch_async(dispatch_get_main_queue()){
                    self.studentTable.reloadData()
                }
            }//else
        }//getStudentLocationData

    }
    
    //***************************************************
    // Dismiss the view, the user wants out
    //***************************************************
    @IBAction func mapLogOut(sender: UIBarButtonItem) {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)    }

    
}//class
