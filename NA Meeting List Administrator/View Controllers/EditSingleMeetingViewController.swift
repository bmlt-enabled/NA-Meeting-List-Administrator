//  EditSingleMeetingViewController.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
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
class EditSingleMeetingViewController: MeetingEditorBaseViewController {
    /** This is the bar button item for canceling editing. */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /** This is the bar button item for saving changes. */
    @IBOutlet weak var saveButton: UIBarButtonItem!

    /** The mask for the animation. */
    @IBOutlet weak var animationCover: UIView!
    
    /** The button that nukes the changes */
    @IBOutlet weak var historyEraserButton: UIButton!
    
    /** The list controller that "owns" this instance. */
    var ownerController: ListEditableMeetingsViewController! = nil
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        if (0 < self.meetingObject.id) && (nil != self.navigationItem.title) {
            self.navigationItem.title = String(format: NSLocalizedString("MEETING-ID-FORMAT", comment: ""), self.meetingObject.id)
        }
        let backButton = UIBarButtonItem()
        backButton.title = NSLocalizedString("CANCEL-BUTTON", comment: "")
        self.navigationItem.backBarButtonItem = backButton
        
        self.cancelButton.title = NSLocalizedString(self.cancelButton.title!, comment: "")
        self.saveButton.title = NSLocalizedString(self.saveButton.title!, comment: "")
        self.historyEraserButton.setTitle(NSLocalizedString(self.historyEraserButton.title(for: UIControl.State.normal)!, comment: ""), for: UIControl.State.normal)
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
        }
        
        self.updateEditorDisplay()
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
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
    /**
     Called before we bring in the history for this meeting..
     
     - parameter segue: The segue being triggered.
     - parameter sender: Any data associated with this segue (there isn't any).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? HistoryListViewController {
            destination.meetingObject = self.meetingObject
        }
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
            
            let saveAction = UIAlertAction(title: NSLocalizedString("SAVE-CHANGES-BUTTON", comment: ""), style: UIAlertAction.Style.destructive, handler: self.saveOKCallback)
            
            alertController.addAction(saveAction)
            
            let saveCopyAction = UIAlertAction(title: NSLocalizedString("SAVE-COPY-BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: self.saveOKCopyCallback)
            
            alertController.addAction(saveCopyAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("SAVE-CANCEL-BUTTON", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("SAVE-AS-COPY", comment: ""), message: NSLocalizedString("SAVE-AS-COPY-MESSAGE", comment: ""), preferredStyle: .alert)
            
            let saveCopyAction = UIAlertAction(title: NSLocalizedString("SAVE-COPY-BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: self.saveOKCopyCallback)
            
            alertController.addAction(saveCopyAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("SAVE-CANCEL-BUTTON", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
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
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("CANCEL-LOSE-CHANGES-BUTTON", comment: ""), style: UIAlertAction.Style.destructive, handler: self.cancelOKCallback)
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL-CANCEL-BUTTON", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.updateEditorDisplay()
            _ = self.navigationController?.popViewController(animated: true)
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
        self.updateEditorDisplay()
        _ = self.navigationController?.popViewController(animated: true)
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
        self.ownerController.searchDone = false
        _ = self.navigationController?.popViewController(animated: true)
    }
}
