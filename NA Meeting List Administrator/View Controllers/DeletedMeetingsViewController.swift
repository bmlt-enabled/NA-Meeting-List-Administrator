//  DeletedMeetingsViewController.swift
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
// MARK: - List Deleted Meetings View Controller Class -
/* ###################################################################################################################################### */
/**
 This class controls the list of deleted meetings that can be restored.
 */
class DeletedMeetingsViewController : EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    let sPrototypeID:String = "one-deletion-row"
    
    private var _deletedMeetingChanges: [BMLTiOSLibChangeNode] = []
    /** This is the navbar button that acts as a back button. */
    @IBOutlet weak var backButton: UIBarButtonItem!
    /** This is our animated "busy cover." */
    @IBOutlet weak var animationMaskView: UIView!
    /** This is the table view that lists the deletions. */
    @IBOutlet weak var tableView: UITableView!
    /** This is a semaphore that we use to prevent too many searches. */
    var searchDone: Bool = false
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     - parameter sender: The bar button item that called this.
     */
    @IBAction func backButtonHit(_ sender: UIBarButtonItem) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /* ################################################################## */
    // MARK:
    /* ################################################################## */
    /**
     Called just after the view set up its subviews.
     We take this opportunity to create or update the weekday switches.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.title = NSLocalizedString(self.backButton.title!, comment: "")
    }
    
    /* ################################################################## */
    /**
     - parameter animated: True, if the appearance is animated (ignored).
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        if !self.searchDone {
            self.animationMaskView.isHidden = false
            var ids: [Int] = []
            for sb in AppStaticPrefs.prefs.selectedServiceBodies {
                ids.append(sb.id)
            }
            MainAppDelegate.connectionObject.getDeletedMeetingChanges(serviceBodyIDs: ids)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     The way the BMLTiOSLib works, is that only deleted meetings that we are allowed to restore are returned.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateDeletedResponse(changeListResults: [BMLTiOSLibChangeNode]) {
        self.animationMaskView.isHidden = true
        self.searchDone = true
        self._deletedMeetingChanges = changeListResults
        self.tableView.reloadData()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDataSource Methods
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter numberOfRowsInSection: The section index (0-based).
     
     - returns the number of rows to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._deletedMeetingChanges.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let changeObject = self._deletedMeetingChanges[indexPath.row]
        
        if let ret = tableView.dequeueReusableCell(withIdentifier: self.sPrototypeID) as? DeletedRowTableCellView {
            // We alternate with slightly darker cells. */
            if let meetingObject = changeObject.beforeObject as? BMLTiOSLibEditableMeetingNode {
                ret.backgroundColor = (0 == (indexPath.row % 2)) ? UIColor.clear : UIColor.init(white: 0, alpha: 0.1)
                ret.nameLabel.text = meetingObject.name
                return ret
            }
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDelegate Methods
    /* ################################################################## */
    /**
     Called before a row is selected.
     
     - parameter tableView: The table view being checked
     - parameter willSelectRowAt: The indexpath of the row being selected.
     
     - returns: nil (don't let selection happen).
     */
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - List Deleted Meetings Single Cell Class -
/* ###################################################################################################################################### */
/**
 This class controls the list of deleted meetings that can be restored.
 */
class DeletedRowTableCellView: UITableViewCell {
    /** This displays the meeting name. */
    @IBOutlet weak var nameLabel: UILabel!
}
