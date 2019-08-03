//  ListEditableMeetingsViewController.swift
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
import MapKit

/* ###################################################################################################################################### */
// MARK: - List Editable Meetings View Controller Class -
/* ###################################################################################################################################### */
/**
 This class controls the list of editable meetings that is the first editor screen to be shown.
 */
class ListEditableMeetingsViewController: EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    /* ################################################################## */
    // MARK: Enums
    /* ################################################################## */
    /**
     This is the enum used for the meeting sort.
     */
    enum SortKey {
        /** Weekday and time */
        case Time
        /** Town or borough */
        case Town
    }
    
    /** This is used to determine if we have dragged the scroll enough to rate a reload. */
    let sScrollToReloadThreshold: CGFloat = -80
    
    /* ################################################################## */
    // MARK: Private Constant Instance Properties
    /* ################################################################## */
    /** This is the table prototype ID for the standard meeting display */
    private let _meetingPrototypeReuseID = "Meeting-Table-View-Prototype"
    /** This is the segue ID for bringing in a meeting to edit. */
    private let _editSingleMeetingSegueID = "show-single-meeting-to-edit"
    /** This will hold our location manager. */
    private var _locationManager: CLLocationManager! = nil
    
    /* ################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################## */
    /** This contains the towns extracted from the meetings. */
    private var _townsAndBoroughs: [String] = []
    /** This is the sort key. It is either day/time (default), or town. */
    private var _resultsSort: SortKey = .Time
    /** This is a semaphore we use to reduce update overhead when checking the "All" weekday checkbox. */
    private var _checkingAll: Bool = false
    /** We can do two tries to determine location. This is set to true after the first one. */
    private var _locationFailedOnce: Bool = false
    /** This is a semaphore we set to tell the view controller that we are looking up our current location. */
    private var _whereAmIInProgress: Bool = false
    /** This contains the coordinates we found when we geolocated. */
    private var _searchCenterCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    /** This contains our weekday checkbox objects. */
    private var _weekdayCheckboxObjects: [ThreeStateCheckbox] = []
    
    /* ################################################################## */
    // MARK: Internal IB Instance Properties
    /* ################################################################## */
    /** If the meeting is unpublished, we have a different color background. */
    /// The background color for even rows.
    @IBInspectable var unpublishedRowColorEven: UIColor!
    /// The background color for odd rows.
    @IBInspectable var unpublishedRowColorOdd: UIColor!
    /** This covers the screen with a busy throbber when we are searching */
    @IBOutlet weak var busyAnimationView: UIView!
    /** This has 8 checkboxes, which allows the user to select certain weekdays. */
    @IBOutlet weak var weekdaySwitchesContainerView: UIView!
    /** This displays the meetings */
    @IBOutlet weak var meetingListTableView: UITableView!
    /** This is a picker view that displays all the towns. */
    @IBOutlet weak var townBoroughPickerView: UIPickerView!
    /** This is the navbar item that allows you to create a new meeting. */
    @IBOutlet weak var addNewMeetingButton: UIBarButtonItem!
    /** This is the navbar button that acts as a back button. */
    @IBOutlet weak var backButton: UIBarButtonItem!
    /** This is the "What Meeting Am I At Now?" button. */
    @IBOutlet weak var whereAmINowButton: UIButton!
    /** This is the navigation bar, shown at the top. */
    @IBOutlet weak var myNavBar: UINavigationBar!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** This carries the state of the selected/unselected weekday checkboxes. */
    var selectedWeekdays: BMLTiOSLibSearchCriteria.SelectableWeekdayDictionary = [.Sunday: .Selected, .Monday: .Selected, .Tuesday: .Selected, .Wednesday: .Selected, .Thursday: .Selected, .Friday: .Selected, .Saturday: .Selected]
    /** This contains all the meetings currently displayed */
    var currentMeetingList: [BMLTiOSLibMeetingNode] = []
    /** This is set to ask the view to scroll to expose a meeting object. */
    var showMeTheMoneyID: Int! = nil
    /** This is a semaphore that we use to prevent too many searches. */
    var searchDone: Bool = false
    
    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     Handles a found location. This starts the process of finding meetings that start today, after our current time.
     We add tomorrow, as well, looping the week if we are at the end.
     
     - parameter coordinate: The coordinate of the user's location.
     */
    private func _startWhereAmISearch(_ coordinate: CLLocationCoordinate2D) {
        self._searchCenterCoords = coordinate
        if let criteriaObject = MainAppDelegate.connectionObject.searchCriteria {
            criteriaObject.clearAll()
            criteriaObject.searchLocation = coordinate
            
            let date = NSDate()
            let calendar = NSCalendar.current
            let today = calendar.component(.weekday, from: date as Date)
            let tomorrow = (7 > today) ? today + 1 : 1
            
            if let todayIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: today) {
                criteriaObject.weekdays[todayIndex] = .Selected
            }
            
            if let tomorrowIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: tomorrow) {
                criteriaObject.weekdays[tomorrowIndex] = .Selected
            }
            
            criteriaObject.searchRadius = 0.057    // We keep the search very tight. Just within 100 yards.
            criteriaObject.performMeetingSearch(.MeetingsOnly)
        }
    }
    
    /* ################################################################## */
    /**
     Displays the busy animation when updating..
     */
    private func _showBusyAnimation() {
        self.busyAnimationView.isHidden = false
        self.meetingListTableView.isHidden = true
    }
    
    /* ################################################################## */
    /**
     Displays the busy animation when updating..
     */
    private func _hideBusyAnimation() {
        self.meetingListTableView.isHidden = false
        self.busyAnimationView.isHidden = true
    }

    /* ################################################################## */
    /**
     Called to sort through the meetings we found in our search, and see if any of them are our meeting.
     
     - parameter inMeetings: The found meetings.
     */
    private func _sortThroughWhereAmI(_ inMeetings: [BMLTiOSLibMeetingNode]) {
        DispatchQueue.main.async {
            self._whereAmIInProgress = false
            // After we fetch all the results, we then sort through them, and remove ones that have already passed today (We leave tomorrow alone).
            var finalResult: BMLTiOSLibEditableMeetingNode! = nil
            let calendar = NSCalendar.current
            let today = calendar.component(.weekday, from: Date())
            let hour = calendar.component(.hour, from: Date())
            let minute = calendar.component(.minute, from: Date())
            let nowInMinutes: Int = (hour * 60) + minute
            
            for meeting in inMeetings {
                let startTimeInMinutes = (meeting.startTime.minute! + (meeting.startTime.hour! * 60)) - AppStaticPrefs.prefs.gracePeriodInMinutes
                let endTimeInMinutes = startTimeInMinutes + meeting.durationInMinutes + AppStaticPrefs.prefs.gracePeriodInMinutes
                if let meetingIsEditable = meeting as? BMLTiOSLibEditableMeetingNode {
                    if (meeting.weekdayIndex == today) && (nowInMinutes >= startTimeInMinutes) && (nowInMinutes <= endTimeInMinutes) {
                        finalResult = meetingIsEditable
                        break
                    }
                }
            }
            
            if nil != finalResult { // We got ourselves a meeting.
                self.scrollToExposeMeeting(finalResult)
                self.editSingleMeeting(finalResult)
            } else { // We ain't got ourselves a meeting.
                MainAppDelegate.displayAlert("NO-MEETING-HEADER", inMessage: "NO-MEETING-MESSAGE", presentedBy: self)
            }
        }
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     - parameter sender: The bar button item that called this.
     */
    @IBAction func backButtonHit(_ sender: UIBarButtonItem) {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager.delegate = nil
            self._locationManager = nil
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    /**
     - parameter sender: The button item that called this.
     */
    @IBAction func whereAmIHit(_ sender: Any) {
        self._locationFailedOnce = false
        self.startLookingForMyMeeting()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called just after the view set up its subviews.
     We take this opportunity to create or update the weekday switches.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.backButton.title = NSLocalizedString(self.backButton.title!, comment: "")
        if CLLocationManager.locationServicesEnabled() {
            self.whereAmINowButton.isHidden = false
            self.whereAmINowButton.setTitle(NSLocalizedString(self.whereAmINowButton.title(for: UIControl.State.normal)!, comment: ""), for: UIControl.State.normal)
        } else {
            self.whereAmINowButton.isHidden = true
        }
        self.setUpWeekdayViews()
    }
    
    /* ################################################################## */
    /**
     Called just after the view did its layout.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateDisplayedMeetings()
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
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.tintColor = self.view.tintColor
        }
    }
    
    /* ################################################################## */
    /**
     - parameter animated: True, if the appearance is animated (ignored).
     */
    override func viewWillDisappear(_ animated: Bool) {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager.delegate = nil
            self._locationManager = nil
            self._locationFailedOnce = false
            self._whereAmIInProgress = false
        }
        super.viewWillDisappear(animated)
    }
    
    /* ################################################################## */
    /**
     Trigger a search upon appearance.
     
     - parameter animated: True, if the appearance is animated (ignored).
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.searchDone {
            self.doSearch()
        }
    }
    
    /* ################################################################## */
    /**
     Reference the selected meeting before bringing in the editor.
     
     - parameter for: The segue object
     - parameter sender: Attached data (We attached the meeting object).
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let meetingObject = sender as? BMLTiOSLibEditableMeetingNode {
            if let destinationController = segue.destination as? EditSingleMeetingViewController {
                destinationController.meetingObject = meetingObject
                destinationController.ownerController = self
            }
        } else {
            if let destinationController = segue.destination as? CreateSingleMeetingViewController {
                destinationController.ownerController = self
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Trigger a search.
     */
    func doSearch() {
        self.tabBarController?.tabBar.isHidden = true
        MainAppDelegate.connectionObject.searchCriteria.clearAll()
        // First, get the IDs of the Service bodies we'll be checking.
        let sbIDArray: [Int] = AppStaticPrefs.prefs.selectedServiceBodies.map { $0.id }
        #if DEBUG
            print("Search Criteria IDs: \(sbIDArray)")
        #endif

        var serviceBodyList: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        
        for sb in MainAppDelegate.connectionObject.searchCriteria.serviceBodies {
            if sb.item.iCanEdit && (.Selected == sb.selection) {
                serviceBodyList.append(sb.item)
            }
        }
        
        // If we didn't have a specific Service body selected, then we assume that all of them are in the mix.
        if serviceBodyList.isEmpty {
            serviceBodyList = MainAppDelegate.connectionObject.serviceBodiesICanEdit
        }

        for sb in serviceBodyList {
            if sbIDArray.contains(sb.id) {
                for i in 0..<MainAppDelegate.connectionObject.searchCriteria.serviceBodies.count where sb.id == MainAppDelegate.connectionObject.searchCriteria.serviceBodies[i].item.id {
                    #if DEBUG
                        print("Search Criteria Service Body Selected: \(MainAppDelegate.connectionObject.searchCriteria.serviceBodies[i].item)")
                    #endif
                    MainAppDelegate.connectionObject.searchCriteria.serviceBodies[i].selection = .Selected
                }
            }
        }
        
        self.currentMeetingList = []
        self._townsAndBoroughs = []
        self.townBoroughPickerView.reloadAllComponents()
        MainAppDelegate.appDelegateObject.meetingObjects = []
        MainAppDelegate.connectionObject.searchCriteria.publishedStatus = .Both
        self._showBusyAnimation()
        self.allChangedTo(inState: BMLTiOSLibSearchCriteria.SelectionState.Selected)
        #if DEBUG
            print("Search Criteria Service Bodies: \(MainAppDelegate.connectionObject.searchCriteria.serviceBodies)")
        #endif
        MainAppDelegate.connectionObject.searchCriteria.performMeetingSearch(.MeetingsOnly)
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects: [BMLTiOSLibMeetingNode]) {
        DispatchQueue.main.async {  // Belt and suspenders...
            self._hideBusyAnimation()
            self.tabBarController?.tabBar.isHidden = false
            if self._whereAmIInProgress {
                self._sortThroughWhereAmI(inMeetingObjects)
                self.doSearch()
            } else {
                self.searchDone = true
                self.currentMeetingList = MainAppDelegate.appDelegateObject.meetingObjects // We start by grabbing all the meetings.
                self.allChangedTo(inState: BMLTiOSLibSearchCriteria.SelectionState.Selected)   // We select all weekdays.
                
                // Extract all the towns and boroughs from the entire list.
                self._townsAndBoroughs = []
                var tempTowns: [String] = []
                
                for meeting in MainAppDelegate.appDelegateObject.meetingObjects {
                    // We give boroughs precedence over towns.
                    let town = meeting.locationBorough.isEmpty ? meeting.locationTown : meeting.locationBorough

                    if !town.isEmpty && !tempTowns.contains(town) {
                        tempTowns.append(town)
                    }
                }
                
                self._townsAndBoroughs = tempTowns.sorted()
                
                // Select every town and borough
                self.townBoroughPickerView.selectRow(0, inComponent: 0, animated: false)
                // If we provide an ID, then we need to scroll to expose that ID, and then open the editor for it.
                if nil != self.showMeTheMoneyID {
                    var meetingObject: BMLTiOSLibEditableMeetingNode! = nil
                    for meeting in self.currentMeetingList where meeting.id == self.showMeTheMoneyID {
                        meetingObject = meeting as? BMLTiOSLibEditableMeetingNode
                        break
                    }
                    
                    if nil != meetingObject {
                        self.scrollToExposeMeeting(meetingObject)
                        self.editSingleMeeting(meetingObject)
                    }
                    self.showMeTheMoneyID = nil
                }
                
                self.view.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a new meeting has been added.
     
     - parameter inMeetingObject: The new meeting object.
     */
    func updateNewMeeting(inMeetingObject: BMLTiOSLibEditableMeetingNode) {
        self.showMeTheMoneyID = inMeetingObject.id
        self.doSearch()
    }
    
    /* ################################################################## */
    /**
     This is called when a meeting rollback is complete.
     
     - parameter inMeeting: The meeting that was updated.
     */
    func updateRollback(_ inMeeting: BMLTiOSLibMeetingNode) {
        if let historyController = self.navigationController?.topViewController as? HistoryListViewController {
            historyController.updateHistory()
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a change fetch is complete.
     */
    func updateChangeFetch() {
        if let historyController = self.navigationController?.topViewController as? HistoryListViewController {
            historyController.updateHistory()
        }
    }
    
    /* ################################################################## */
    /**
     Scrolls the table to expose the given meeting object.
     
     - parameter meetingObject: The meeting object we want to see.
     */
    func scrollToExposeMeeting(_ meetingObject: BMLTiOSLibEditableMeetingNode) {
        var index: Int = 0
        self.updateDisplayedMeetings()  // We need to make sure that we've reprocessed and sorted our meetings before scrolling.
        for meeting in self.currentMeetingList {
            if meeting == meetingObject {
                let indexPath = IndexPath(row: index, section: 0)
                self.meetingListTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: false)
                break
            }
            index += 1
        }
    }
    
    /* ################################################################## */
    /**
     This sorts the meeting list by the weekday, then the start time.
     */
    func sortMeetings() {
        self.currentMeetingList = self.currentMeetingList.sorted(by: { (a, b) -> Bool in
            if .Time == self._resultsSort {
                let aComp = a.timeDayAsInteger
                let bComp = b.timeDayAsInteger
                
                return aComp < bComp
            } else {
                let aTown = a.locationBorough.isEmpty ? a.locationTown : a.locationBorough
                let bTown = b.locationBorough.isEmpty ? b.locationTown : b.locationBorough
                
                return aTown < bTown
            }
        })
    }
    
    /* ################################################################## */
    /**
     This sorts through the available meetings, and filters out the ones we want, according to the weekday checkboxes and the selected town.
     */
    func updateDisplayedMeetings() {
        self.currentMeetingList = []
    
        let row = self.townBoroughPickerView.selectedRow(inComponent: 0) - 2
        let townString: String = (0 <= row) ? self._townsAndBoroughs[row] : ""

        for meeting in MainAppDelegate.appDelegateObject.meetingObjects {
            var weekdayIndex = (meeting.weekdayIndex - AppStaticPrefs.firstWeekdayIndex) + 1
            if 1 > weekdayIndex {
                weekdayIndex += 7
            }

            for weekdaySelection in self.selectedWeekdays {
                if (weekdaySelection.value == .Selected) && (weekdaySelection.key.rawValue == weekdayIndex) {
                    if !townString.isEmpty {
                        if (meeting.locationBorough == townString) || (meeting.locationTown == townString) {
                            self.currentMeetingList.append(meeting)
                            break
                        }
                    } else {
                        self.currentMeetingList.append(meeting)
                        break
                    }
                }
            }
        }
        
        // We do this, because we want the "All" checkbox to be set/cleared if all the rest of the checkboxes are the same value.
        if 8 == self._weekdayCheckboxObjects.count {
            let allCheckBox = self._weekdayCheckboxObjects[0]
            
            var allState: BMLTiOSLibSearchCriteria.SelectionState = .Deselected
            var different: Bool = false
            
            // Look to see if there's a difference of opinion amongst the various days.
            for i in 1..<8 {
                let checkBox = self._weekdayCheckboxObjects[i]
                
                if allState != .Deselected {
                    if allState != checkBox.selectionState {
                        different = true
                        break
                    }
                } else {
                    allState = checkBox.selectionState
                }
            }
            
            // If they all agree on a state, then we set the "All" checkbox to that state.
            if (allState != .Deselected) && !different {
                allCheckBox.selectionState = allState
            }
        }
        
        self.sortMeetings()
        self.meetingListTableView.reloadData()
        self.townBoroughPickerView.reloadAllComponents()
    }
    
    /* ################################################################## */
    /**
     We call this to set up our weekday selectors.
     */
    func setUpWeekdayViews() {
        for subView in self.weekdaySwitchesContainerView.subviews {
            subView.removeFromSuperview()
        }
        
        let containerFrame = self.weekdaySwitchesContainerView.bounds
        
        let individualFrameWidth: CGFloat = containerFrame.size.width / 8
        
        var xOrigin: CGFloat = 0
        self._weekdayCheckboxObjects = []
        for index in 0..<8 {
            let newFrame = CGRect(x: xOrigin, y: 0, width: individualFrameWidth, height: containerFrame.height)
            let newView = WeekdaySwitchContainerView(frame: newFrame, weekdayIndex: index, inOwner: self)
            self.weekdaySwitchesContainerView.addSubview(newView)
            self._weekdayCheckboxObjects.append(newView.selectionSwitchControl)
            xOrigin += individualFrameWidth
        }
    }
    
    /* ################################################################## */
    /**
     This changes all of the checkboxes to match the "All" checkbox state.
     */
    func allChangedTo(inState: BMLTiOSLibSearchCriteria.SelectionState) {
        self._checkingAll = true
        for subView in self.weekdaySwitchesContainerView.subviews {
            if let castView = subView as? WeekdaySwitchContainerView {
                if 0 != castView.weekdayIndex {
                    castView.selectionSwitchControl.selectionState = inState
                }
            }
        }
        self._checkingAll = false
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Called to initiate editing of a meeting.
     
     - parameter inMeetingObject: The meeting to be edited.
     */
    func editSingleMeeting(_ inMeetingObject: BMLTiOSLibMeetingNode!) {
        if nil != inMeetingObject {
            self.performSegue(withIdentifier: self._editSingleMeetingSegueID, sender: inMeetingObject)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when one of the weekday checkboxes is changed.
     
     - parameter inWeekdayIndex: 1-based index of the weekday represented by the checkbox.
     - parameter newSelectionState: The new state for selection.
     */
    func weekdaySelectionChanged(inWeekdayIndex: Int, newSelectionState: BMLTiOSLibSearchCriteria.SelectionState) {
        if 0 == inWeekdayIndex {
            self.allChangedTo(inState: newSelectionState)
        } else {
            if let indexAsEnum = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: inWeekdayIndex) {
                self.selectedWeekdays[indexAsEnum] = newSelectionState
                if !self._checkingAll { // We don't update if we are in the middle of changing all the checkboxes.
                    self.view.setNeedsLayout()
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called to tell the app to start searching for where we are.
     */
    func startLookingForMyMeeting() {
        DispatchQueue.main.async {
            self._showBusyAnimation()
            self._locationManager = CLLocationManager()
            self._locationManager.requestWhenInUseAuthorization()
            self._locationManager.delegate = self
            self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self._whereAmIInProgress = true
            self._locationManager.startUpdatingLocation()
        }
    }

    /* ################################################################## */
    // MARK: Internal CLLocationManagerDelegate Methods
    /* ################################################################## */
    /**
     This is called if the location manager suffers a failure.
     
     - parameter manager: The Location Manager object that had the error.
     - parameter didFailWithError: The error in question.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            if self._locationFailedOnce {   // If at second, you don't succeed...
                self._locationManager.stopUpdatingLocation()
                self._locationManager.delegate = nil
                self._locationManager = nil
                self._locationFailedOnce = false
                MainAppDelegate.displayAlert("LOCATION-ERROR-HEADER", inMessage: "LOCATION-ERROR-MESSAGE", presentedBy: self)
            } else {    // Love me two times, I'm goin' away...
                self._locationFailedOnce = true
                self.startLookingForMyMeeting()
            }
        }
    }

    /* ################################################################## */
    /**
     Callback to handle found locations.
     
     - parameter manager: The Location Manager object that had the event.
     - parameter locations: an array of updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self._locationManager.stopUpdatingLocation()
            self._locationManager.delegate = nil
            self._locationManager = nil
            self._locationFailedOnce = false
            if 0 < locations.count {
                for location in locations where 2 > location.timestamp.timeIntervalSinceNow {
                    let coordinate = location.coordinate
                    DispatchQueue.main.async(execute: {
                        self._whereAmIInProgress = true
                        self._startWhereAmISearch(coordinate)
                    })
                }
            } else {
                MainAppDelegate.displayAlert("LOCATION-ERROR-HEADER", inMessage: "LOCATION-ERROR-MESSAGE", presentedBy: self)
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
        if (velocity.y < 0) && (scrollView.contentOffset.y < self.sScrollToReloadThreshold) {
            self.doSearch()
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
        return self.currentMeetingList.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let baseMeetingObject = self.currentMeetingList[indexPath.row]
        if let meetingObject = baseMeetingObject as? BMLTiOSLibEditableMeetingNode {
            if let ret = tableView.dequeueReusableCell(withIdentifier: self._meetingPrototypeReuseID) as? MeetingTableViewCell {
                // We alternate with slightly darker cells. */
                if meetingObject.published {
                    if 0 == (indexPath.row % 2) {
                        ret.backgroundColor = UIColor.clear
                    } else {
                        ret.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
                    }
                } else {
                    if 0 == (indexPath.row % 2) {
                        ret.backgroundColor = self.unpublishedRowColorEven
                    } else {
                        ret.backgroundColor = self.unpublishedRowColorOdd
                    }
                }
                
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
                                            amPm = formatter.pmSymbol }
                                    }
                                    time = String(format: "%d:%02d %@", hour, minute, amPm!)
                                } else {
                                    time = String(format: "%d:%02d", hour, minute)
                                }
                            }
                        }
                        
                        var weekdayIndex = (meetingObject.weekdayIndex - AppStaticPrefs.firstWeekdayIndex) + 1
                        if 1 > weekdayIndex {
                            weekdayIndex += 7
                        }
                        
                        ret.meetingTimeAndPlaceLabel.text = String(format: NSLocalizedString("MEETING-TIME-FORMAT", comment: ""), AppStaticPrefs.weekdayNameFromWeekdayNumber(weekdayIndex), time) + (meetingObject.formatsAsCSVList.isEmpty ? "" : " (" + meetingObject.formatsAsCSVList + ")")
                    }
                }
                
                return ret
           }
        }
        #if DEBUG
            print("ERROR! Bad Meeting Object: \(baseMeetingObject)")
        #endif
        
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
        self.editSingleMeeting(self.currentMeetingList[indexPath.row])
        
        return nil
    }
    
    /* ################################################################## */
    /**
     Indicate that a row can be edited (for left-swipe delete).
     
     - parameter tableView: The table view being checked
     - parameter canEditRowAt: The indexpath of the row to be checked.
     
     - returns: true, always.
     */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter tableView: The table view being checked
     - parameter commit: The action to perform.
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let meetingObject = self.currentMeetingList[indexPath.row]

            let alertController = UIAlertController(title: NSLocalizedString("DELETE-HEADER", comment: ""), message: String(format: NSLocalizedString("DELETE-MESSAGE-FORMAT", comment: ""), meetingObject.name), preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE-OK-BUTTON", comment: ""), style: UIAlertAction.Style.destructive, handler: {(_: UIAlertAction) in self.doADirtyDeedCheap(tableView, forRowAt: indexPath)})
            
            alertController.addAction(deleteAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("DELETE-CANCEL-BUTTON", comment: ""), style: UIAlertAction.Style.default, handler: {(_: UIAlertAction) in self.dontDoADirtyDeedCheap(tableView)})
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called to do a delete action.
     
     - parameter tableView: The table view being checked
     - parameter forRowAt: The indexpath of the row to be deleted.
     */
    func doADirtyDeedCheap(_ tableView: UITableView, forRowAt indexPath: IndexPath) {
        let meetingObject = self.currentMeetingList[indexPath.row]
        self.currentMeetingList.remove(at: indexPath.row)
        for i in 0..<MainAppDelegate.appDelegateObject.meetingObjects.count {
            let originalMeetingObject = MainAppDelegate.appDelegateObject.meetingObjects[i]
            if originalMeetingObject.id == meetingObject.id {
                MainAppDelegate.appDelegateObject.meetingObjects.remove(at: i)
                break
            }
        }

        MainAppDelegate.connectionObject.deleteMeeting(meetingObject.id)
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        self.townBoroughPickerView.reloadAllComponents()
    }
    
    /* ################################################################## */
    /**
     Called to cancel a delete action.
     
     - parameter tableView: The table view being checked
     */
    func dontDoADirtyDeedCheap(_ tableView: UITableView) {
        tableView.isEditing = false
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDataSource Methods
    /* ################################################################## */
    /**
     We only have 1 component.
     
     - parameter pickerView:The UIPickerView being checked
     
     - returns: 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     We will always have 2 more than the number of towns, as we have the first and second rows.
     
     - parameter pickerView:The UIPickerView being checked
     
     - returns: Either 0, or the number of towns to be displayed, plus 2.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self._townsAndBoroughs.isEmpty {
            return 1
        } else {
            return self._townsAndBoroughs.count + 1
        }
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDelegate Methods
    /* ################################################################## */
    /**
     This returns the name for the given row.
     
     - parameter pickerView: The UIPickerView being checked
     - parameter row: The row being checked
     - parameter forComponent: The component (always 0)
     - parameter reusing: If the view is being reused, it is passed in here.
     
     - returns: a view, containing a label with the string for the row.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = pickerView.rowSize(forComponent: 0)
        var frame = pickerView.bounds
        frame.size.height = size.height
        frame.origin = CGPoint.zero
        
        var pickerValue: String = ""
        
        if 0 == row {
            pickerValue = NSLocalizedString("LOCAL-SEARCH-PICKER-NONE", comment: "")
        } else {
            if 1 < row {
                pickerValue = self._townsAndBoroughs[row - 2]
            }
        }
        
        let ret: UIView = UIView(frame: frame)
        
        ret.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: frame)
        
        if !pickerValue.isEmpty {
            label.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
            label.textColor = UIColor.white
            label.text = pickerValue
            label.textAlignment = NSTextAlignment.center
        } else {
            label.backgroundColor = UIColor.clear
        }
        
        ret.addSubview(label)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when the user finishes selecting a row.
     We use this to add the selected town to the filter.
     
     If it is one of the top 2 rows, we select the first row, and ignore it.
     
     - parameter pickerView:The UIPickerView being checked
     - parameter row:The row being checked
     - parameter component:The component (always 0)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if 1 == row {
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
        
        self.view.setNeedsLayout()
    }
}

/* ###################################################################################################################################### */
// MARK: - Custom Meeting Table View Class -
/* ###################################################################################################################################### */
/**
 This is a simple class that allows us to access the template items.
 */
class MeetingTableViewCell: UITableViewCell {
    /** The top label */
    @IBOutlet weak var meetingTimeAndPlaceLabel: UILabel!
    /** The middle (italic) label */
    @IBOutlet weak var addressLabel: UILabel!
    /** The bottom label */
    @IBOutlet weak var meetingInfoLabel: UILabel!
}

/* ###################################################################################################################################### */
// MARK: - Custom Weekday Switch View Class -
/* ###################################################################################################################################### */
/**
 */
class WeekdaySwitchContainerView: UIView {
    /** This is the weekday index (1-based) */
    var weekdayIndex: Int!
    /** This is the list selection view controller that "owns" this instance */
    var owner: ListEditableMeetingsViewController! = nil
    /** This is the checkbox control object */
    var selectionSwitchControl: ThreeStateCheckbox!
    /** This is the label containing the name being displayed */
    var weekdayNameLabel: UILabel!
    
    /* ################################################################## */
    /**
     The default initializer. It creates the embedded views, and sets the state.
     We set the ThreeStateCheckbox object to be a simple binary checkbox.
     
     - parameter frame: The frame within the superview this will be placed.
     - parameter weekdayIndex: The 1-based weekday index.
     - parameter inOwner: The list view controller that "owns" this view.
     */
    init(frame: CGRect, weekdayIndex: Int, inOwner: ListEditableMeetingsViewController) {
        super.init(frame: frame)
        self.owner = inOwner
        self.weekdayIndex = weekdayIndex
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        if let testImage = UIImage(named: "checkbox-clear") {
            var checkboxFrame: CGRect = CGRect.zero
            checkboxFrame.size.width = min(testImage.size.width, testImage.size.height)
            checkboxFrame.size.height = min(testImage.size.width, testImage.size.height)
            
            checkboxFrame.origin.x = (frame.size.width - checkboxFrame.size.width) / 2  // Center the switch at the top of the view.
            
            self.selectionSwitchControl = ThreeStateCheckbox(frame: checkboxFrame)
            self.selectionSwitchControl.binaryState = true
            
            if 0 < self.weekdayIndex {
                if let indexAsEnum = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: self.weekdayIndex) {
                    if let weekdaySelection = owner.selectedWeekdays[indexAsEnum] {
                        self.selectionSwitchControl.selectionState = weekdaySelection
                    }
                }
            } else {
                var selectionState: BMLTiOSLibSearchCriteria.SelectionState! = nil
                for weekday in owner.selectedWeekdays {
                    if nil == selectionState {
                        selectionState = weekday.value
                    } else {
                        if weekday.value != selectionState {
                            selectionState = .Clear
                            break
                        }
                    }
                }
                
                if nil == selectionState {
                    selectionState = .Clear
                }
                
                self.selectionSwitchControl.selectionState = selectionState!
            }
            
            self.selectionSwitchControl.addTarget(self, action: #selector(WeekdaySwitchContainerView.checkboxSelectionChanged(_:)), for: UIControl.Event.valueChanged)
            
            var labelFrame: CGRect = CGRect.zero
            labelFrame.size.width = frame.size.width
            labelFrame.size.height = frame.size.height - checkboxFrame.size.height
            labelFrame.origin.y = checkboxFrame.size.height
            
            self.weekdayNameLabel = UILabel(frame: labelFrame)
            self.weekdayNameLabel.textColor = inOwner.view.tintColor
            self.weekdayNameLabel.textAlignment = .center
            self.weekdayNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
            self.weekdayNameLabel.text = (0 == weekdayIndex) ? NSLocalizedString("ALL-DAYS", comment: "") : AppStaticPrefs.weekdayNameFromWeekdayNumber(weekdayIndex, isShort: true)
            
            self.addSubview(self.selectionSwitchControl)
            self.addSubview(self.weekdayNameLabel)
        }
    }
    
    /* ################################################################## */
    /**
     This is required. Why? Not sure.
     
     - parameter coder: The decoder for this object.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /* ################################################################## */
    /**
     We override this to make sure we put away all our toys.
     */
    override func removeFromSuperview() {
        self.selectionSwitchControl.removeFromSuperview()
        self.selectionSwitchControl = nil
        self.weekdayNameLabel.removeFromSuperview()
        self.weekdayNameLabel = nil
        super.removeFromSuperview()
    }
    
    /* ################################################################## */
    /**
     The callback for our checkbox changing. We basically reroute to the owner.
     
     - parameter inCheckbox: The ThreeStateCheckbox object that called this.
     */
    @objc func checkboxSelectionChanged(_ inCheckbox: ThreeStateCheckbox) {
        self.owner.weekdaySelectionChanged(inWeekdayIndex: self.weekdayIndex, newSelectionState: inCheckbox.selectionState)
    }
}
