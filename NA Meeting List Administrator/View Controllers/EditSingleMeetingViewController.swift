//
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
 */
class EditSingleMeetingViewController : MeetingEditorBaseViewController {
    /** THis is the bar button item for canceling editing. */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cancelButton.title = NSLocalizedString(self.cancelButton.title!, comment: "")
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the NavBar Cancel button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func cancelButtonTouched(_ sender: UIBarButtonItem) {
        self.meetingObject.restoreToOriginal()
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
