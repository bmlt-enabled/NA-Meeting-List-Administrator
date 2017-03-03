//  HistoryListViewController.swift
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
// MARK: - List History Items View Controller Class -
/* ###################################################################################################################################### */
/**
 This class controls the list of history items for a meeting, with some allowing rollback.
 */
class HistoryListViewController : EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    /** The reuse ID for the history prototype. */
    private let _reuseID = "history-item"
    /** This is the table view that displays all the history items. */
    @IBOutlet weak var tableView: UITableView!
    /** This is the "busy" animation. */
    @IBOutlet weak var animationCoverView: UIView!
    /** This is the meeting object for this instance. */
    var meetingObject: BMLTiOSLibEditableMeetingNode! = nil

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
            self.navigationItem.title = NSLocalizedString(self.navigationItem.title!, comment: "")
        }
        
        if nil == self.meetingObject.changes {
            self.animationCoverView.isHidden = false
            self.meetingObject.getChanges()
        } else {
            self.updateHistory()
        }
    }

    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     Called to tell the controller to update it's appearance.
     */
    func updateHistory() {
        self.animationCoverView.isHidden = true
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
        return (nil != self.meetingObject.changes) ? self.meetingObject.changes.count : 0
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ret = tableView.dequeueReusableCell(withIdentifier: self._reuseID) as? HistoryListTableViewCell {
            let changeObject = self.meetingObject.changes[indexPath.row]
            ret.textView.text = changeObject.description + "\n" + changeObject.details
            ret.revertButton.setTitle(NSLocalizedString(ret.revertButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
            ret.revertButton.isHidden = (nil == changeObject.beforeObject)
            return ret
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
// MARK: - List History Items Table Cell View Class -
/* ###################################################################################################################################### */
/**
 This class controls one history list row.
 */
class HistoryListTableViewCell : UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var revertButton: UIButton!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when someone hits the "revert" button.
     
     - parameter sender: The button object
     */
    @IBAction func revertButtonHit(_ sender: UIButton) {
    }
}
