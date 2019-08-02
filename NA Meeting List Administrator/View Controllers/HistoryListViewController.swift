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
class HistoryListViewController: EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    /** The reuse ID for the history prototype. */
    private let _reuseID = "history-item"
    /** The segue ID for the manually-triggered "More Details" viewer. */
    private let _detailSegueID = "more-info-segue"
    /** This contains a list of changelists, associated with more info buttons. */
    private var _moreDetailHistoryItems: [UIButton: BMLTiOSLibChangeNode] = [:]
    /** This is the table view that displays all the history items. */
    @IBOutlet weak var tableView: UITableView!
    /** This is the "busy" animation. */
    @IBOutlet weak var animationCoverView: UIView!
    /** This label is displayed when we have an empty history. */
    @IBOutlet weak var noHistoryLabel: UILabel!
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
    /**
     Called to tell the controller to update it's appearance.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HistoryDetailViewController {
            if let changeObject = sender as? BMLTiOSLibChangeNode {
                destination.changeObject = changeObject
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the load is complete. We use this to set the text for the hidden "no history" item.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noHistoryLabel.text = NSLocalizedString(self.noHistoryLabel.text!, comment: "")
        self.noHistoryLabel.isHidden = true
    }
    
    /* ################################################################## */
    /**
     Called when the layout is complete. We use this to trigger a new table update.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.reloadData()
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the More Info button is hit.
     */
    @IBAction func moreInfoButtonHit(_ sender: UIButton) {
        if let changeObject = self._moreDetailHistoryItems[sender] {
            self.performSegue(withIdentifier: self._detailSegueID, sender: changeObject)
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
        self.view.setNeedsLayout()
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
        let ret = (nil != self.meetingObject.changes) ? self.meetingObject.changes.count : 0
        self.noHistoryLabel.isHidden = !self.animationCoverView.isHidden || (0 < ret)
        return ret
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
            let descriptionText = changeObject.description
            ret.textView.text = descriptionText
            ret.revertButton.setTitle(NSLocalizedString(ret.revertButton.title(for: UIControl.State.normal)!, comment: ""), for: UIControl.State.normal)
            ret.revertButton.isHidden = (nil == changeObject.beforeObject)
            self._moreDetailHistoryItems[ret.moreInfoButton] = changeObject
            ret.owner = self
            ret.changeObject = changeObject
            ret.backgroundColor = (0 == (indexPath.row % 2)) ? UIColor.clear : UIColor.init(white: 0, alpha: 0.1)
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
class HistoryListTableViewCell: UITableViewCell {
    /// This is the controller that "owns" this instance.
    var owner: HistoryListViewController! = nil
    /// This is the associated change node.
    var changeObject: BMLTiOSLibChangeNode! = nil
    /// This is the text view that displays the change.
    @IBOutlet weak var textView: UITextView!
    /// This is a button to find out more about this change.
    @IBOutlet weak var moreInfoButton: UIButton!
    /// This button triggers a roolback/revert operation.
    @IBOutlet weak var revertButton: UIButton!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when someone hits the "revert" button.
     
     - parameter sender: The button object
     */
    @IBAction func revertButtonHit(_ sender: UIButton) {
        if self.owner.meetingObject.revertMeetingToBeforeThisChange(self.changeObject) {
            _ = self.owner.navigationController?.popViewController(animated: true)
        }
    }
}
/* ###################################################################################################################################### */
// MARK: - List History Items View Controller Class -
/* ###################################################################################################################################### */
/**
 This class controls the display of a detailed history of the one event.
 */
class HistoryDetailViewController: EditorViewControllerBaseClass {
    /** This is our change object. */
    var changeObject: BMLTiOSLibChangeNode! = nil
    /** This contains our details. */
    @IBOutlet var historyDetailTextView: UITextView!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called as the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.historyDetailTextView.text = self.changeObject.details
    }
}
