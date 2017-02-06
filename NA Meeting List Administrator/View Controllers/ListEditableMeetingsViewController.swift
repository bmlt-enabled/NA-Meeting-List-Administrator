//
//  ListEditableMeetingsViewController.swift
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
// MARK: - List Editable Meetings View Controller Class -
/* ###################################################################################################################################### */
/**
 */
class ListEditableMeetingsViewController : EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    private let _meetingPrototypeReuseID = "Meeting-Table-View-Prototype"
    
    @IBOutlet weak var busyAnimationView: UIView!
    @IBOutlet weak var meetingListTableView: UITableView!
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called just after the view loads.
     We take this opportunity to load all the available meetings. We will filter through these in the future.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // First, get the IDs of the Service bodies we'll be checking.
        let sbArray = AppStaticPrefs.prefs.selectedServiceBodies
        
        let sbSelectorArray = MainAppDelegate.connectionObject.searchCriteria.serviceBodies
        
        for sb in sbSelectorArray {
            if sbArray.contains(sb.item) {
                sb.selection = .Selected
            }
        }
        
        MainAppDelegate.appDelegateObject.meetingObjects = []
        self.meetingListTableView.reloadData()
        MainAppDelegate.connectionObject.searchCriteria.publishedStatus = .Both
        
        self.busyAnimationView.isHidden = false
        MainAppDelegate.connectionObject.searchCriteria.performMeetingSearch(.MeetingsOnly)
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects:[BMLTiOSLibMeetingNode]) {
        self.busyAnimationView.isHidden = true
        self.meetingListTableView.reloadData()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDelegate Methods
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter numberOfRowsInSection: The section index (0-based).
     
     - returns the number of rows to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MainAppDelegate.appDelegateObject.meetingObjects.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let ret = tableView.dequeueReusableCell(withIdentifier: self._meetingPrototypeReuseID) as? MeetingTableViewCell {
            ret.backgroundColor = (0 == (indexPath.row % 2)) ? UIColor.clear : UIColor.init(white: 0, alpha: 0.1)
            if let meetingObject = MainAppDelegate.appDelegateObject.meetingObjects[indexPath.row] as? BMLTiOSLibEditableMeetingNode {
                ret.meetingInfoLabel.text = meetingObject.name
                ret.addressLabel.text = meetingObject.basicAddress
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
                        let formats = meetingObject.formatsAsCSVList.isEmpty ? "" : " (" + meetingObject.formatsAsCSVList + ")"
                        ret.meetingTimeAndPlaceLabel.text = String(format: localizedFormat, weekday, time) + formats
                    }
                }
            }
            
            return ret
        } else {
            return UITableViewCell()
        }
    }
}
/* ###################################################################################################################################### */
// MARK: - Custom Meeting Table View Class -
/* ###################################################################################################################################### */
/**
 */
class MeetingTableViewCell : UITableViewCell {
    @IBOutlet weak var meetingTimeAndPlaceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var meetingInfoLabel: UILabel!
    
    /* ################################################################## */
    /**
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /* ################################################################## */
    /**
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
