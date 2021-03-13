//  CreateSingleMeetingViewController.swift
//  NA Meeting List Administrator
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Single Meeting Editor View Controller Class -
/* ###################################################################################################################################### */
/**
 This is the subclass for the editor (as opposed to the new meeting creator).
 */
class CreateSingleMeetingViewController: MeetingEditorBaseViewController {
    /** This is the bar button item for canceling editing. */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /** This is the bar button item for saving changes. */
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /** This is the mask for the animation. */
    @IBOutlet weak var animationCover: UIView!
    
    /** This is the list controller that "owns" us. */
    var ownerController: ListEditableMeetingsViewController! = nil
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let serviceBodyID: Int = AppStaticPrefs.prefs.selectedServiceBodies[0].id
        let initialValues: [String: String] = ["published": "0",
                                              "id_bigint": "0",
                                              "worldid_mixed": "",
                                              "meeting_name": NSLocalizedString("BMLTiOSLib-Default-Meeting-Name", comment: ""),
                                              "weekday_tinyint": "1",
                                              "service_body_bigint": String(serviceBodyID),
                                              "start_time": "20:30:00",
                                              "duration_time": "1:00:00",
                                              "longitude": String(MainAppDelegate.connectionObject.defaultLocation.longitude),
                                              "latitude": String(MainAppDelegate.connectionObject.defaultLocation.latitude)
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
        let alertController = UIAlertController(title: NSLocalizedString("SAVE-NEW-TITLE", comment: ""), message: NSLocalizedString("SAVE-NEW-MESSAGE", comment: ""), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("SAVE-NEW-BUTTON", comment: ""), style: UIAlertAction.Style.destructive, handler: self.saveOKCallback)
        
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("SAVE-CANCEL-BUTTON", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* ################################################################## */
    /**
     Called when the NavBar Cancel button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.meetingObject.restoreToOriginal()
        _ = self.navigationController?.popViewController(animated: true)
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
        self.meetingObject.saveChanges()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     If the user wants to save the meeting as a copy, we generate a change URI, and send it to the server.
     
     - parameter inAction: The alert action object (ignored)
     */
    func saveOKCopyCallback(_ inAction: UIAlertAction) {
        MainAppDelegate.connectionObject.saveMeetingAsCopy(self.meetingObject)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     - parameter inEditor: The list view controller.
     */
    func callMeWhenYoureDone(_ inEditor: ListEditableMeetingsViewController, _ meetingObject: BMLTiOSLibEditableMeetingNode?) -> Bool {
        self.meetingObject = meetingObject
        self.animationCover.isHidden = true
        self.updateEditorDisplay()
        return true
    }
}
