//  EditSingleMeetingViewController.swift
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
class EditSingleMeetingViewController : MeetingEditorBaseViewController {
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
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = false
            if (0 < self.meetingObject.id) && (nil != self.navigationItem.title) {
                let title = self.navigationItem.title!
                self.navigationItem.title = String(format: NSLocalizedString(title, comment: ""), self.meetingObject.id)
            }
        }
        
        self.cancelButton.title = NSLocalizedString(self.cancelButton.title!, comment: "")
        self.saveButton.title = NSLocalizedString(self.saveButton.title!, comment: "")
        self.updateEditorDisplay()
    }
    
    /* ################################################################## */
    // MAR: Instance Methods
    /* ################################################################## */
    /**
     Called when something changes in the various controls.
     
     - parameter inChangedCell: The table cell object that experienced the change. If nil, then no meeting cell was changed. nil is default.
     */
    override func updateEditorDisplay(_ inChangedCell: MeetingEditorViewCell! = nil) {
        if self.meetingObject.isDirty {
            self.saveButton.title = NSLocalizedString("SAVE-BUTTON", comment: "")
        } else {
            self.saveButton.title = NSLocalizedString("SAVE-BUTTON-DUPLICATE", comment: "")
        }
        
        super.updateEditorDisplay(inChangedCell)
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
            let alertController = UIAlertController(title: NSLocalizedString("SAVE-AS-OR-COPY", comment: ""), message: NSLocalizedString("SAVE-AS-OR-COPY-MESSAGE", comment: ""), preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: NSLocalizedString("SAVE-CHANGES-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: self.saveOKCallback)
            
            alertController.addAction(saveAction)
            
            let saveCopyAction = UIAlertAction(title: NSLocalizedString("SAVE-COPY-BUTTON", comment: ""), style: UIAlertActionStyle.default, handler: self.saveOKCopyCallback)
            
            alertController.addAction(saveCopyAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("SAVE-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("SAVE-AS-COPY", comment: ""), message: NSLocalizedString("SAVE-AS-COPY-MESSAGE", comment: ""), preferredStyle: .alert)
            
            let saveCopyAction = UIAlertAction(title: NSLocalizedString("SAVE-COPY-BUTTON", comment: ""), style: UIAlertActionStyle.default, handler: self.saveOKCopyCallback)
            
            alertController.addAction(saveCopyAction)
            
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
        if self.meetingObject.isDirty {
            let alertController = UIAlertController(title: NSLocalizedString("CANCEL-HEADER", comment: ""), message: NSLocalizedString("CANCEL-MESSAGE", comment: ""), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("CANCEL-LOSE-CHANGES-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: self.cancelOKCallback)
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     If the user wants to delete the changes they made, do so here.
     
     - parameter inAction: The alert action object (ignored)
     */
    func cancelOKCallback(_ inAction: UIAlertAction) {
        self.meetingObject.restoreToOriginal()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     If the user wants to save the meeting, we do so here..
     
     - parameter inAction: The alert action object (ignored)
     */
    func saveOKCallback(_ inAction: UIAlertAction) {
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
    func callMeWhenYoureDone(_ inEditor : ListEditableMeetingsViewController) -> Bool {
        self.meetingObject = inEditor.currentMeetingList[0] as! BMLTiOSLibEditableMeetingNode
        self.animationCover.isHidden = true
        self.updateEditorDisplay()
        return true
    }
}
