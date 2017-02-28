//  CreateSingleMeetingViewController.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
//
//  Copyright 2017 MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NA Meeting List Administrator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Single Meeting Editor View Controller Class -
/* ###################################################################################################################################### */
/**
 This is the subclass for the editor (as opposed to the new meeting creator).
 */
class CreateSingleMeetingViewController : MeetingEditorBaseViewController {
    /** This is the bar button item for canceling editing. */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /** This is the bar button item for saving changes. */
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var animationCover: UIView!
    
    var ownerController: ListEditableMeetingsViewController! = nil
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let serviceBodyID: Int = AppStaticPrefs.prefs.selectedServiceBodies[0].id
        let initialValues: [String:String] = ["published":"0",
                                              "id_bigint":"0",
                                              "meeting_name":NSLocalizedString("BMLTiOSLib-Default-Meeting-Name", comment: ""),
                                              "weekday_tinyint":"1",
                                              "service_body_bigint": String(serviceBodyID),
                                              "start_time":"20:30:00",
                                              "duration_time":"1:00:00",
                                              "longitude":String(MainAppDelegate.connectionObject.defaultLocation.longitude),
                                              "latitude":String(MainAppDelegate.connectionObject.defaultLocation.latitude)
                                              ]
        self.meetingObject = BMLTiOSLibEditableMeetingNode(initialValues, inHandler: MainAppDelegate.connectionObject)
        self.meetingObject.name = NSLocalizedString(self.meetingObject.name, comment: "")
    }
    
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = false
            if let title = self.navigationItem.title {
                self.navigationItem.title = NSLocalizedString(title, comment: "")
            }
        }
        
        self.cancelButton.title = NSLocalizedString(self.cancelButton.title!, comment: "")
        self.saveButton.title = NSLocalizedString(self.saveButton.title!, comment: "")
        self.updateEditorDisplay()
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the NavBar Save button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        if self.meetingObject.isDirty {
            let alertController = UIAlertController(title: NSLocalizedString("SAVE-NEW-TITLE", comment: ""), message: NSLocalizedString("SAVE-NEW-MESSAGE", comment: ""), preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: NSLocalizedString("SAVE-NEW-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: self.saveOKCallback)
            
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("SAVE-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the NavBar Cancel button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.meetingObject.restoreToOriginal()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Called when something changes in the various controls.
     
     - parameter inChangedCell: The table cell object that experienced the change. If nil, then no meeting cell was changed. nil is default.
     */
    override func updateEditorDisplay(_ inChangedCell: MeetingEditorViewCell! = nil) {
        super.updateEditorDisplay(inChangedCell)
    }
   
    /* ################################################################## */
    /**
     If the user wants to save the meeting, we do so here..
     
     - parameter inAction: The alert action object (ignored)
     */
    func saveOKCallback(_ inAction: UIAlertAction) {
        self.ownerController.newMeetingBeingSaved = true
        self.meetingObject.saveChanges()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     If the user wants to save the meeting as a copy, we generate a change URI, and send it to the server.
     
     - parameter inAction: The alert action object (ignored)
     */
    func saveOKCopyCallback(_ inAction: UIAlertAction) {
        self.animationCover.isHidden = false
        self.ownerController.callMeWhenYoureDone = self.callMeWhenYoureDone
        MainAppDelegate.connectionObject.saveMeetingAsCopy(self.meetingObject)
    }
    
    /* ################################################################## */
    /**
     - parameter inEditor: The list view controller.
     */
    func callMeWhenYoureDone(_ inEditor : ListEditableMeetingsViewController, _ meetingObject: BMLTiOSLibEditableMeetingNode?) -> Bool {
        self.meetingObject = meetingObject
        self.animationCover.isHidden = true
        self.updateEditorDisplay()
        return true
    }
}
