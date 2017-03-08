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
    /** This is the table cell ID */
    let sPrototypeID:String = "one-deletion-row"
    /** This is used to determine if we have dragged the scroll enough to rate a reload. */
    let sScrollToReloadThreshold: CGFloat = -80
    
    /** This has our list of deleted meetings (stored as changes). */
    private var _deletedMeetingChanges: [BMLTiOSLibChangeNode] = []
    
    /** This is the navbar button that acts as a back button. */
    @IBOutlet weak var backButton: UIBarButtonItem!
    /** This is our animated "busy cover." */
    @IBOutlet weak var animationMaskView: UIView!
    /** This is the table view that lists the deletions. */
    @IBOutlet weak var tableView: UITableView!
    /** This is the header for our "Hurry up and wait" message. */
    @IBOutlet weak var deletedWaitHeader: UILabel!
    /** This is our "Hurry up and wait. " message. */
    @IBOutlet weak var deletedWaitMessage: UILabel!
    /** This is the navigation bar at the top. */
    @IBOutlet weak var myNavBar: UINavigationBar!
    
    /** This is a semaphore that we use to prevent too many searches. */
    var searchDone: Bool = false
    /** This references our tab controller (makes it easy to get at it). */
    var myBarTab: EditorTabBarController! = nil
    
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
    // MARK: Overloaded Base Class Methods
    /* ################################################################## */
    /**
     Called just after the view set up its subviews.
     We take this opportunity to create or update the weekday switches.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.title = NSLocalizedString(self.backButton.title!, comment: "")
        self.deletedWaitHeader.text = NSLocalizedString(self.deletedWaitHeader.text!, comment: "")
        self.deletedWaitMessage.text = NSLocalizedString(self.deletedWaitMessage.text!, comment: "")
    }
    
    /* ################################################################## */
    /**
     Called just before the view is to appear.
     We take this opportunity to start a search, if one has not been done.
     
     - parameter animated: True, if the appearance is animated (ignored).
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.tintColor = self.view.tintColor
        }
        
        if !self.searchDone {
            self.getDeletedMeetings()
        } else {
            self.view.setNeedsLayout()
        }
    }
    
    /* ################################################################## */
    /**
     Called when we are to lay out the subviews.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if nil != self.tableView {
            self.tableView.reloadData()
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This searches for all of our deleted meetings.
     Only valid meetings that we can edit with the selected Service bodies are presented.
     */
    func getDeletedMeetings() {
        self.animationMaskView.isHidden = false
        self.tableView.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.myNavBar.isHidden = true
        var ids: [Int] = []
        for sb in AppStaticPrefs.prefs.selectedServiceBodies {
            ids.append(sb.id)
        }
        MainAppDelegate.connectionObject.getDeletedMeetingChanges(serviceBodyIDs: ids)
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     The way the BMLTiOSLib works, is that only deleted meetings that we are allowed to restore are returned.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateDeletedResponse(changeListResults: [BMLTiOSLibChangeNode]) {
        self.animationMaskView.isHidden = true
        self.tableView.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.myNavBar.isHidden = false
        self.searchDone = true
        self._deletedMeetingChanges = changeListResults
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     This is called when the user taps on a deleted meeting in the table.
     We interpret it as a request to restore the meeting.
     An alert is presented, explaining the request and options.
     
     - parameter inRow: An Int, with the row of the change object we'll be restoring.
     */
    func requestMeetingBeRestored(_ inRow: Int) {
        if let meetingObject = self._deletedMeetingChanges[inRow].beforeObject as? BMLTiOSLibEditableMeetingNode {
            let alertController = UIAlertController(title: NSLocalizedString("DELETED-ALERT-HEADER", comment: ""), message: String(format: NSLocalizedString("DELETED-ALERT-FORMAT", comment: ""), meetingObject.name), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("DELETED-RESTORE-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: {(_: UIAlertAction) in self.restoreMeeting(inMeeting: meetingObject, row: inRow)})
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("DELETED-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called to do a restore action.
     
     - parameter inMeeting: The meeting object to be restored.
     - parameter row: The row the meeting is on (will be deleted).
     */
    func restoreMeeting(inMeeting: BMLTiOSLibEditableMeetingNode, row: Int) {
        if MainAppDelegate.connectionObject.restoreDeletedMeeting(inMeeting.id) {
            self._deletedMeetingChanges.remove(at: row)
            self.view.setNeedsLayout()
            if let tabBarController = self.myBarTab {
                tabBarController.select(thisMeetingID: inMeeting.id)
            }
        }
    }
    
    /* ################################################################## */
    // MARK: UIScrollViewDelegate Protocol Methods
    /* ################################################################## */
    /**
     This is called when the scroll view has ended dragging.
     We use this to trigger a reload, if the scroll was pulled beyond its limit by a certain number of display units.
     
     :param: scrollView The text view that experienced the change.
     :param: velocity The velocity of the scroll at the time of this call.
     :param: targetContentOffset We can use this to send an offset to the scroller (ignored).
     */
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if ( (velocity.y < 0) && (scrollView.contentOffset.y < self.sScrollToReloadThreshold) ) {
            self.getDeletedMeetings()
        }
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
                ret.nameLabel.text = String(format: NSLocalizedString("DELETED-NAME-FORMAT", comment: ""), meetingObject.name, meetingObject.id)
                ret.deletionDescription.text = changeObject.description
                if var hour = meetingObject.startTimeAndDay.hour {
                    if let minute = meetingObject.startTimeAndDay.minute {
                        var time = ""
                        
                        if ((23 == hour) && (55 <= minute)) || ((0 == hour) && (0 == minute)) || (24 == hour) {
                            time = NSLocalizedString("MIDNIGHT", comment: "")
                        } else {
                            if (12 == hour) && (0 == minute) {
                                time = NSLocalizedString("NOON", comment: "")
                            } else {
                                let formatter = DateFormatter()
                                formatter.locale = Locale.current
                                formatter.dateStyle = .none
                                formatter.timeStyle = .short
                                
                                let dateString = formatter.string(from: Date())
                                let amRange = dateString.range(of: formatter.amSymbol)
                                let pmRange = dateString.range(of: formatter.pmSymbol)
                                
                                if !(pmRange == nil && amRange == nil) {
                                    var amPm = formatter.amSymbol
                                    
                                    if 12 < hour {
                                        hour -= 12
                                        amPm = formatter.pmSymbol
                                    } else {
                                        if 12 == hour {
                                            amPm = formatter.pmSymbol
                                        }
                                    }
                                    time = String(format: "%d:%02d %@", hour, minute, amPm!)
                                } else {
                                    time = String(format: "%d:%02d", hour, minute)
                                }
                            }
                        }
                        
                        let weekday = AppStaticPrefs.weekdayNameFromWeekdayNumber(meetingObject.weekdayIndex)
                        let localizedFormat = NSLocalizedString("MEETING-TIME-FORMAT", comment: "")
                        ret.addressTextView.text = meetingObject.basicAddress
                        ret.timeLabel.text = String(format: localizedFormat, weekday, time)
                    }
                }
                
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
        self.requestMeetingBeRestored(indexPath.row)
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
    /** This displays the meeting day and time. */
    @IBOutlet weak var timeLabel: UILabel!
    /** This is a text view that contains a basic address for the meeting. */
    @IBOutlet weak var addressTextView: UITextView!
    /** This is a text view that contains a basic description of the change. */
    @IBOutlet weak var deletionDescription: UITextView!
}
