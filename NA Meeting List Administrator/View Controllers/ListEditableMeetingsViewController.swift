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
class ListEditableMeetingsViewController : EditorViewControllerBaseClass {
    @IBOutlet weak var busyAnimationView: UIView!
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
    }
}
