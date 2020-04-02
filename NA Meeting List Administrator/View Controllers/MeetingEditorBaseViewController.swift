//  MeetingEditorBaseViewController.swift
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
// MARK: - This view extension allows us to fetch the first responder -
/* ###################################################################################################################################### */
/**
 This class describes the basic functionality for a full meeting editor.
 */
extension UIView {
    /**
     - returns: The actual Responder, if this view (or a subview) is the current first responder (recursive check). Nil, if no first responders.
     */
    var currentFirstResponder: UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder {
                return responder
            }
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Single Meeting Editor View Controller Class -
/* ###################################################################################################################################### */
/**
 This class describes the basic functionality for a full meeting editor.
 */
class MeetingEditorBaseViewController: EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    /** The height of the published cell if we only have one Service body. */
    private let _publishedSingleServiceBody: CGFloat    = 37
    /** The height of the Published cell if we can select Service bodies. */
    private let _publishedMultiServiceBody: CGFloat     = 155
    /** We use this as a common prefix for our reuse IDs, and the index as the suffix. */
    private let _reuseIDBase = "editor-row-"
    
    /** This is a table of heights for our table rows. */
    private var _internalRowHeights: [String: CGFloat] = ["editor-row-0": 0,
                                                         "editor-row-1": 60,
                                                         "editor-row-2": 60,
                                                         "editor-row-3": 60,
                                                         "editor-row-4": 100,
                                                         "editor-row-5": 100,
                                                         "editor-row-6": 820,
                                                         "editor-row-7": 0,
                                                         "editor-row-8": 210,
                                                         "editor-row-9": 100,
                                                         "editor-row-10": 300
    ]
    
    /** These store the original (unpublished) colors for the background gradient. */
    /// The gradient top color for a published meeting.
    private var _publishedTopColor: UIColor! = nil
    /// The gradient bottom color for a published meeting.
    private var _publishedBottomColor: UIColor! = nil
    
    /** This holds our geocoder object when we are looking up addresses. */
    private var _geocoder: CLGeocoder! = nil
    
    /** This will hold our location manager. */
    private var _locationManager: CLLocationManager! = nil
    
    /** This will hold our address section (for geocoding and reverse geocoding). */
    private var _addressInstance: AddressEditorTableViewCell! = nil
    
    /** This will hold our long/lat section (for geocoding and reverse geocoding). */
    private var _longLatInstance: LongLatTableViewCell! = nil
    
    /** This will hold our map section (for geocoding and reverse geocoding). */
    private var _mapInstance: MapTableViewCell! = nil
    
    /** This will reference our formats container. */
    private var _formatContainerView: FormatsEditorTableViewCell! = nil
    
    /** This tracks the state of the keyboard */
    private var _keyboardShown: Bool = false
    
    /** This tracks the state of the keyboard */
    private var _keyboardOffset: CGFloat = 0.0
    
    /** This will reference the top item in the window (the "Published" handler). */
    var publishedItems: PublishedEditorTableViewCell! = nil
    
    /** This is the meeting object for this instance. */
    var meetingObject: BMLTiOSLibEditableMeetingNode! = nil

    /** This is the structural table view */
    @IBOutlet var tableView: UITableView!
    
    /** If the meeting is unpublished, we have a different color background gradient. */
    /// The gradient top color for an unpublished meeting.
    @IBInspectable var unpublishedTopColor: UIColor!
    /// The gradient bottom color for an unpublished meeting.
    @IBInspectable var unpublishedBottomColor: UIColor!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We take this opportunity to save our published colors.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self._publishedTopColor = (self.view as? EditorViewBaseClass)?.topColor
        self._publishedBottomColor = (self.view as? EditorViewBaseClass)?.bottomColor
        self.tableView.rowHeight = UITableView.automaticDimension
        self._keyboardOffset = 0.0
        // We use these to get notified when the keyboard will appear and disappear.
        NotificationCenter.default.addObserver(self, selector: #selector(MeetingEditorBaseViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MeetingEditorBaseViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /* ################################################################## */
    /**
     We take this opportunity to save our published colors.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if nil != self._formatContainerView {
            self.tableView.reloadData()
        }
        
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager = nil
        }
    }
    
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillDisappear(_ animated: Bool) {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
            self._locationManager = nil
        }
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     De-Initializer.
     */
    deinit {
        // Make sure that we don't get any notifications, as they will crash.
        NotificationCenter.default.removeObserver(self)
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the main view is tapped (closes any open keyboards).
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func tapInBackground(_ sender: UITapGestureRecognizer) {
        self.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This is a callback for when the keyboard will appear. It makes sure that we have room to diplay whatever we're editing.
     
     We will adjust the screen to show the text item above the keyboard.
     
     If the text item is below the keyboard, we temporarily enlarge the content size for the table, and scroll down, then reset it when we're done.
     
     - parameter: The notification object
     */
    @objc func keyboardWillShow(_ inNotification: NSNotification) {
        if 0.0 == self._keyboardOffset {   // Only if it's not already up.
            if let keyboardFrame: NSValue = inNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                if let window = self.view.window {
                    if let currentResponder = window.currentFirstResponder as? UIView {
                        let convertedFrame = window.convert(currentResponder.frame, from: currentResponder.superview)
                        let ypos = convertedFrame.origin.y + convertedFrame.size.height
                        let kpos = window.bounds.size.height - keyboardFrame.cgRectValue.size.height
                        let newOffset = ypos - kpos
                        if 0.0 < newOffset {
                            self._keyboardOffset = newOffset
                            var newKeyboardOffset = self.tableView.contentOffset
                            newKeyboardOffset.y += newOffset
                            self.tableView.contentSize.height += self._keyboardOffset
                            self.tableView.setContentOffset(newKeyboardOffset, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is a callback for when the keyboard will disappear.
     
     We use this to unwind any scroll and content size changes.
     
     - parameter: The notification object (ignored)
     */
    @objc func keyboardWillHide(_: NSNotification) {
        let oldOffset = self._keyboardOffset
        self._keyboardOffset = 0.0
        if 0.0 < oldOffset {   // Only if it's already up.
            var newKeyboardOffset = self.tableView.contentOffset
            newKeyboardOffset.y -= oldOffset
            self.tableView.contentSize.height -= oldOffset
            self.tableView.setContentOffset(newKeyboardOffset, animated: true)
        }
    }

    /* ################################################################## */
    /**
     Called when something changes in the various controls.
     
     - parameter inChangedCell: The table cell object that experienced the change. If nil, then no meeting cell was changed. nil is default.
     */
    func updateEditorDisplay(_ inChangedCell: MeetingEditorViewCell! = nil) {
        DispatchQueue.main.async(execute: {
            if (nil == inChangedCell) || (self.publishedItems == inChangedCell) {
                if self.meetingObject.published {
                    (self.view as? EditorViewBaseClass)?.topColor = self._publishedTopColor
                    (self.view as? EditorViewBaseClass)?.bottomColor = self._publishedBottomColor
                } else {
                    (self.view as? EditorViewBaseClass)?.topColor = self.unpublishedTopColor
                    (self.view as? EditorViewBaseClass)?.bottomColor = self.unpublishedBottomColor
                }
                
                self.view.setNeedsLayout()

                self.navigationController?.navigationBar.barTintColor = (self.view as? EditorViewBaseClass)?.topColor
                self.tabBarController?.tabBar.barTintColor = (self.view as? EditorViewBaseClass)?.bottomColor
                
                if self.publishedItems == inChangedCell {
                    self.tableView.superview?.setNeedsLayout()
                }
            }
        })
    }
    
    /* ################################################################## */
    /**
     Closes any open keyboards.
     */
    func closeKeyboard() {
        if let firstResponder = self.view.currentFirstResponder {
            firstResponder.resignFirstResponder()
        }
    }
    
    /* ################################################################## */
    /**
     Updates the coordinates in our Long/Lat editor
     
     - parameter inCoords: The coordinates to set the text items to.
     */
    func updateCoordinates(_ inCoords: CLLocationCoordinate2D) {
        if nil != self._longLatInstance {
            self._longLatInstance.coordinate = inCoords
        }
    }
    
    /* ################################################################## */
    /**
     This starts a geocode, based on the current address in the address editor.
     */
    func lookUpAddressForMe() {
        let addressString = self.meetingObject.basicAddress
        self._geocoder = CLGeocoder()
        self._geocoder.geocodeAddressString(addressString, completionHandler: self.gecodeCompletionHandler )
    }
    
    /* ################################################################## */
    /**
     Called after the address geocode is done.
     
     :param: placeMarks
     :param: error
     */
    func gecodeCompletionHandler (_ placeMarks: [CLPlacemark]?, error: Error?) {
        DispatchQueue.main.async(execute: {
            self._geocoder = nil
            if (nil != error) || (nil == placeMarks) || (0 == placeMarks!.count) {
                MainAppDelegate.displayAlert("LOCAL-EDIT-GEOCODE-FAIL-TITLE", inMessage: "LOCAL-EDIT-GEOCODE-FAILURE-MESSAGE")
            } else {
                if let location = placeMarks![0].location {
                    if nil != self._longLatInstance {
                        self._longLatInstance.coordinate = location.coordinate
                    }
                    
                    if nil != self._mapInstance {
                        self._mapInstance.moveMeetingMarkerToLocation(location.coordinate, inSetZoom: false)
                    }
                }
            }
        })
    }
    
    /* ################################################################## */
    /**
     This starts a reverse geocode, based on the coordinates in the map/long/lat editor.
     */
    func lookUpCoordinatesForMe() {
        if nil != self._longLatInstance {
            let location = CLLocation(latitude: self._longLatInstance.coordinate.latitude, longitude: self._longLatInstance.coordinate.longitude)
            self._geocoder = CLGeocoder()
            self._geocoder.reverseGeocodeLocation(location, completionHandler: self.reverseGecodeCompletionHandler )
        }
    }
    
    /* ################################################################## */
    /**
     Called after the long/lat is reverse geocoded.
     
     :param: placeMarks
     :param: error
     */
    func reverseGecodeCompletionHandler (_ placeMarks: [CLPlacemark]?, error: Error?) {
        DispatchQueue.main.async(execute: {
            self._geocoder = nil
            self._longLatInstance.animationMaskView.isHidden = true    // Yuck. But this is the best place for this.
            if (nil != error) || (nil == placeMarks) || (0 == placeMarks!.count) {
                MainAppDelegate.displayAlert("LOCAL-EDIT-REVERSE-GEOCODE-FAIL-TITLE", inMessage: "LOCAL-EDIT-REVERSE-GEOCODE-FAILURE-MESSAGE")
            } else {
                if let placeMark = placeMarks?[0] {
                    if let locationName = placeMark.name {
                        self.meetingObject.locationName = locationName
                        self._addressInstance.venueNameTextField.text = locationName
                    }
                    
                    if let street = placeMark.thoroughfare {
                        if let number = placeMark.subThoroughfare {
                            self.meetingObject.locationStreetAddress = number + " " + street
                        } else {
                            self.meetingObject.locationStreetAddress = street
                        }
                    } else {
                        if let number = placeMark.subThoroughfare {
                            self.meetingObject.locationStreetAddress = number
                        }
                    }
                    
                    self._addressInstance.streetAddressTextField.text = self.meetingObject.locationStreetAddress
                    
                    if let borough = placeMark.subLocality {
                        self.meetingObject.locationBorough = borough
                        self._addressInstance.boroughTextField.text = borough
                    }
                    
                    if let town = placeMark.locality {
                        self.meetingObject.locationTown = town
                        self._addressInstance.townTextField.text = town
                    }
                    
                    if let county = placeMark.subAdministrativeArea {
                        self.meetingObject.locationCounty = county
                        self._addressInstance.countyTextField.text = county
                    }
                    
                    if let state = placeMark.administrativeArea {
                        self.meetingObject.locationState = state
                        self._addressInstance.stateTextField.text = state
                    }
                    
                    if let zip = placeMark.postalCode {
                        self.meetingObject.locationZip = zip
                        self._addressInstance.zipTextField.text = zip
                    }
                    
                    if let nation = placeMark.isoCountryCode {
                        self.meetingObject.locationNation = nation
                        self._addressInstance.nationTextField.text = nation
                    }
                    
                    self.updateEditorDisplay(self._addressInstance)
                }
            }
        })
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
        return self._internalRowHeights.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = self._reuseIDBase + String(indexPath.row)
        
        if let returnableCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as? MeetingEditorViewCell {
            returnableCell.owner = self
            returnableCell.meetingObject = self.meetingObject
            // These are special sections that we hang onto.
            if "editor-row-0" == reuseID {
                // This is the first cell of the table.
                self.publishedItems = returnableCell as? PublishedEditorTableViewCell
            } else {
                if "editor-row-6" == reuseID {
                    // This contains all the address fields.
                    self._addressInstance = returnableCell as? AddressEditorTableViewCell
                } else {
                    if "editor-row-7" == reuseID {
                        // This contains the map editor.
                        self._mapInstance = returnableCell as? MapTableViewCell
                    } else {
                        if "editor-row-8" == reuseID {
                            // This contains the longitude and latitude editor.
                            self._longLatInstance = returnableCell as? LongLatTableViewCell
                        } else {
                            if "editor-row-10" == reuseID {
                                self._formatContainerView = returnableCell as? FormatsEditorTableViewCell
                            }
                        }
                    }
                }
            }
            
            // This allows us to close the keyboard for taps pretty much everywhere.
            let newGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(MeetingEditorBaseViewController.tapInBackground(_:)))
            returnableCell.addGestureRecognizer(newGestureReconizer)
            return returnableCell
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDelegate Methods
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter heightForRowAt: The IndexPath of the requested cell.
     
     - returns the height of the cell.
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reuseID = self._reuseIDBase + String(indexPath.row)
        
        switch reuseID {   // This allows us to set dynamic heights.
        case "editor-row-0":    // If we are editing more than one Service body, then we can switch between them.
            if 1 < AppStaticPrefs.prefs.selectedServiceBodies.count {
                return self._publishedMultiServiceBody
            } else {
                return self._publishedSingleServiceBody
            }
            
        case "editor-row-7":    // The map view is a big square.
            return tableView.bounds.width
            
        case "editor-row-10":
            return (nil != self._formatContainerView) ? self._formatContainerView.cellHeight : self._internalRowHeights[reuseID]!

        default:
            if let height = self._internalRowHeights[reuseID] { // By default, we use our table, but we may not have something there.
                return height
            }
        }
        
        return tableView.rowHeight  // All else fails, use the default table row height.
    }
    
    /* ################################################################## */
    // MARK: CLLocationManagerDelegate Methods
    /* ################################################################## */
    /**
     Called if there was a failure with the location manager.
     
     :param: manager The Location Manager object that had the error.
     :param: error The error in question.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self._locationManager.stopUpdatingLocation()
        self._locationManager = nil
        MainAppDelegate.displayAlert("LOCAL-EDIT-LOCATION-FAIL-TITLE", inMessage: "LOCAL-EDIT-LOCATION-FAILURE-MESSAGE")
    }
    
    /* ################################################################## */
    /**
     Called when the location manager updates the locations.
     
     :param: manager The Location Manager object that had the event.
     :param: locations an array of updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self._locationManager.stopUpdatingLocation()
        self._locationManager = nil
        if 0 < locations.count {
            for location in locations where 2 > location.timestamp.timeIntervalSinceNow {
                self._geocoder = CLGeocoder()
                self._geocoder.reverseGeocodeLocation(location, completionHandler: self.reverseGecodeCompletionHandler )
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Editor Table Cell Base Class -
/* ###################################################################################################################################### */
/**
 This is the base table view class for the various cell prototypes.
 */
class MeetingEditorViewCell: UITableViewCell {
    /** This will contain the meeting object associated with this object. */
    private var _meetingObject: BMLTiOSLibEditableMeetingNode! = nil
    
    /** This is our "owner" meeting editor View Controller */
    var owner: MeetingEditorBaseViewController! = nil
    
    /* ################################################################## */
    /**
     This is an accessor for the meeting object. Getting is no big deal, but setting calls our meetingObjectUpdated() method.
     */
    var meetingObject: BMLTiOSLibEditableMeetingNode! {
        get { return self._meetingObject }
        set {
            self._meetingObject = newValue
            self.meetingObjectUpdated()
        }
    }
    
    /* ################################################################## */
    /**
     This is designed to be overloaded. This is called when the meetingObject property is set, and gives us a chance to set up our object.
     */
    func meetingObjectUpdated() {}
}

/* ###################################################################################################################################### */
// MARK: - Meeting Published Status Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class PublishedEditorTableViewCell: MeetingEditorViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    /** This is the meeting name section. */
    /// This is the container for the "published" switch.
    @IBOutlet weak var publishedContainerView: UIView!
    /// The label for the published switch
    @IBOutlet weak var publishedLabel: UILabel!
    /// The published switch
    @IBOutlet weak var publishedSwitch: UISwitch!
    /// The label for the Service body picker
    @IBOutlet weak var serviceBodyPickerLabel: UILabel!
    /// The Service body picker view.
    @IBOutlet weak var serviceBodyPickerView: UIPickerView!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to weekday selection changing in the segmented control.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func publishedChanged(_ sender: UISwitch) {
        self.meetingObject.published = sender.isOn
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.publishedLabel.text = NSLocalizedString(self.publishedLabel.text!, comment: "")
        self.publishedSwitch.isOn = self.meetingObject.published
        if 1 < AppStaticPrefs.prefs.selectedServiceBodies.count {
            self.serviceBodyPickerLabel.text = NSLocalizedString(self.serviceBodyPickerLabel.text!, comment: "")
            var index: Int = 0
            for serviceBody in AppStaticPrefs.prefs.selectedServiceBodies {
                if serviceBody.id == self.meetingObject.serviceBodyId {
                    break
                }
                index += 1
            }
            
            if index < AppStaticPrefs.prefs.selectedServiceBodies.count {
                self.serviceBodyPickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDelegate Methods
    /* ################################################################## */
    /**
     This returns the name for the given row.
     
     - parameter pickerView: The UIPickerView being checked
     - parameter row: The row being checked
     - parameter component: The component (always 0)
     
     - returns: a view, containing a label with the string for the row.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = pickerView.rowSize(forComponent: 0)
        var frame = pickerView.bounds
        frame.size.height = size.height
        frame.origin = CGPoint.zero
        
        let ret: UIView = UIView(frame: frame)
        
        ret.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: frame)
        
        label.textColor = self.tintColor
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        
        label.text = AppStaticPrefs.prefs.selectedServiceBodies[row].name
        
        ret.addSubview(label)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when the user finishes selecting a row.
     We use this to set the Service body.
     
     - parameter pickerView: The UIPickerView being checked
     - parameter row: The row being checked
     - parameter component: The component (always 0)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.meetingObject.serviceBodyId = AppStaticPrefs.prefs.selectedServiceBodies[row].id
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDataSource Methods
    /* ################################################################## */
    /**
     We only have 1 component.
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     Returns the number of Service bodies
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns the number of Service bodies to display.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AppStaticPrefs.prefs.selectedServiceBodies.count
    }
}

/* ###################################################################################################################################### */
// MARK: - World ID Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the World (NAWS) ID editor prototype.
 */
class WorldIDEditorTableViewCell: MeetingEditorViewCell {
    /** This is the meeting name section. */
    /// The label for the world ID text entry
    @IBOutlet weak var worldIDLabel: UILabel!
    /// The world ID text entry
    @IBOutlet weak var worldIDTextField: UITextField!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func worldIDTextChanged(_ sender: UITextField) {
        self.meetingObject.worldID = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.worldIDLabel.text = NSLocalizedString(self.worldIDLabel.text!, comment: "")
        self.worldIDTextField.placeholder = NSLocalizedString(self.worldIDTextField.placeholder!, comment: "")
        self.worldIDTextField.text = self.meetingObject.worldID
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Name Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class MeetingNameEditorTableViewCell: MeetingEditorViewCell {
    /** This is the meeting name section. */
    /// The label for the meeting name text entry
    @IBOutlet weak var meetingNameLabel: UILabel!
    /// The meeting name text entry
    @IBOutlet weak var meetingNameTextField: UITextField!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func meetingNameTextChanged(_ sender: UITextField) {
        self.meetingObject.name = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.meetingNameLabel.text = NSLocalizedString(self.meetingNameLabel.text!, comment: "")
        self.meetingNameTextField.placeholder = NSLocalizedString(self.meetingNameTextField.placeholder!, comment: "")
        self.meetingNameTextField.text = self.meetingObject.name
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Weekday Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class WeekdayEditorTableViewCell: MeetingEditorViewCell {
    /** This is the weekday section. */
    /// The label for the weekday selection segnmented control
    @IBOutlet weak var weekdayLabel: UILabel!
    /// The weekday section segmented control
    @IBOutlet weak var weekdaySegmentedView: UISegmentedControl!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to weekday selection changing in the segmented control.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func weekdayChanged(_ sender: UISegmentedControl) {
        var weekdayIndex = sender.selectedSegmentIndex + AppStaticPrefs.firstWeekdayIndex
        if 6 < weekdayIndex {
            weekdayIndex -= 7
        }

        self.meetingObject.weekdayIndex = weekdayIndex
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.weekdayLabel.text = NSLocalizedString(self.weekdayLabel.text!, comment: "")
        for i in 0..<7 {
            let weekdayName = AppStaticPrefs.weekdayNameFromWeekdayNumber(i + 1, isShort: true)
            self.weekdaySegmentedView.setTitle(weekdayName, forSegmentAt: i)
        }
        
        var weekdayIndex = self.meetingObject.weekdayIndex - AppStaticPrefs.firstWeekdayIndex
        if 0 > weekdayIndex {
            weekdayIndex += 7
        }
        
        self.weekdaySegmentedView.selectedSegmentIndex = weekdayIndex
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Start Time Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class StartTimeEditorTableViewCell: MeetingEditorViewCell {
    /** This is the start time section. */
    /// The label for the start time time picker
    @IBOutlet weak var startTimeLabel: UILabel!
    /// The start time picker
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to start time selection changing in the date picker control.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func startTimeChanged(_ sender: UIDatePicker) {
        let startTimeDate = sender.date
        let unitFlags: NSCalendar.Unit = [.hour, .minute]
        let startComponents = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.components(unitFlags, from: startTimeDate)
        self.meetingObject.startTime = startComponents
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.startTimeLabel.text = NSLocalizedString(self.startTimeLabel.text!, comment: "")
        self.startTimeDatePicker.setValue(self.owner.view.tintColor, forKeyPath: "textColor")
        if let components = self.meetingObject.startTimeAndDay {
            if let date = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: components) {
                self.startTimeDatePicker.setDate(date, animated: false)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Duration Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class DurationEditorTableViewCell: MeetingEditorViewCell {
    /** This is the duration section. */
    /// The label for the duration time picker
    @IBOutlet weak var durationLabel: UILabel!
    /// The duration time picker
    @IBOutlet weak var durationDatePicker: UIDatePicker!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to duration selection changing in the date picker control.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func durationChanged(_ sender: UIDatePicker) {
        let startTimeDate = sender.date
        let unitFlags: NSCalendar.Unit = [.hour, .minute]
        let durationComponents = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.components(unitFlags, from: startTimeDate)
        self.meetingObject.durationInMinutes = ((durationComponents?.hour)! * 60) + (durationComponents?.minute)!
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.durationLabel.text = NSLocalizedString(self.durationLabel.text!, comment: "")
        self.durationDatePicker.setValue(self.owner.view.tintColor, forKeyPath: "textColor")
        let minutes = self.meetingObject.durationInMinutes
        let timeDuration: TimeInterval = Double(minutes) * 60
        
        self.durationDatePicker.countDownDuration = timeDuration
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Address Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the address entry section (several components).
 */
class AddressEditorTableViewCell: MeetingEditorViewCell {
    /// The label for the venue name text entry
    @IBOutlet weak var venueNameLabel: UILabel!
    /// The vanue name text entry
    @IBOutlet weak var venueNameTextField: UITextField!
    
    /// The label for the street address text entry
    @IBOutlet weak var streetAddressLabel: UILabel!
    /// The text entry for the street address
    @IBOutlet weak var streetAddressTextField: UITextField!
    
    /// The label for the neighborhood text entry
    @IBOutlet weak var neighborhoodLabel: UILabel!
    /// The neighborhood text entry
    @IBOutlet weak var neighborhoodTextField: UITextField!
    
    /// The label for the borough text entry
    @IBOutlet weak var boroughLabel: UILabel!
    /// The borough text entry
    @IBOutlet weak var boroughTextField: UITextField!
    
    /// The label for the town text entry
    @IBOutlet weak var townLabel: UILabel!
    /// The town text entry
    @IBOutlet weak var townTextField: UITextField!
    
    /// The label for the county text entry
    @IBOutlet weak var countyLabel: UILabel!
    /// The county text entry
    @IBOutlet weak var countyTextField: UITextField!
    
    /// The label for the state text entry
    @IBOutlet weak var stateLabel: UILabel!
    /// The state text entry
    @IBOutlet weak var stateTextField: UITextField!
    /// The label that asks to use abbreviations
    @IBOutlet weak var stateNagLabel: UILabel!
    
    /// The label for the zip code
    @IBOutlet weak var zipLabel: UILabel!
    /// The text field to enter the zip code
    @IBOutlet weak var zipTextField: UITextField!
    
    /// The label for the nation text field
    @IBOutlet weak var nationLabel: UILabel!
    /// The nation text field
    @IBOutlet weak var nationTextField: UITextField!
    
    /// The label for the additional address info text field
    @IBOutlet weak var extraInfoLabel: UILabel!
    /// The text entry for the additional location information
    @IBOutlet weak var extraInfoTextField: UITextField!
    
    /// The label for the virtual URL text field
    @IBOutlet weak var virtualMeetingLabel: UILabel!
    /// The text entry for the virtual meeting URL
    @IBOutlet weak var virtualMeetingTextField: UITextField!
    
    /// The label for the meeting phone number text field
    @IBOutlet weak var meetingPhoneNumberLabel: UILabel!
    /// The text entry for the meeting phone number
    @IBOutlet weak var meetingPhoneNumberTextField: UITextField!

    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func locationNameTextChanged(_ sender: UITextField) {
        self.meetingObject.locationName = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func streetAddressTextChanged(_ sender: UITextField) {
        self.meetingObject.locationStreetAddress = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func neighborhoodTextChanged(_ sender: UITextField) {
        self.meetingObject.locationNeighborhood = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func boroughTextChanged(_ sender: UITextField) {
        self.meetingObject.locationBorough = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func townTextChanged(_ sender: UITextField) {
        self.meetingObject.locationTown = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func countyTextChanged(_ sender: UITextField) {
        self.meetingObject.locationCounty = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func stateTextChanged(_ sender: UITextField) {
        self.meetingObject.locationState = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func zipTextChanged(_ sender: UITextField) {
        self.meetingObject.locationZip = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func nationTextChanged(_ sender: UITextField) {
        self.meetingObject.locationNation = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func extraInfoTextChanged(_ sender: UITextField) {
        self.meetingObject.locationInfo = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func virtualURITextChanged(_ sender: UITextField) {
        self.meetingObject.virtualMeetingURI = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func meetingPhoneNumberTextChanged(_ sender: UITextField) {
        self.meetingObject.meetingPhoneNumber = sender.text!
        self.owner.updateEditorDisplay(self)
    }

    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.venueNameLabel.text = NSLocalizedString(self.venueNameLabel.text!, comment: "")
        self.venueNameTextField.placeholder = NSLocalizedString(self.venueNameTextField.placeholder!, comment: "")
        self.venueNameTextField.text = self.meetingObject.locationName
        
        self.streetAddressLabel.text = NSLocalizedString(self.streetAddressLabel.text!, comment: "")
        self.streetAddressTextField.placeholder = NSLocalizedString(self.streetAddressTextField.placeholder!, comment: "")
        self.streetAddressTextField.text = self.meetingObject.locationStreetAddress
        
        self.neighborhoodLabel.text = NSLocalizedString(self.neighborhoodLabel.text!, comment: "")
        self.neighborhoodTextField.placeholder = NSLocalizedString(self.neighborhoodTextField.placeholder!, comment: "")
        self.neighborhoodTextField.text = self.meetingObject.locationNeighborhood
        
        self.boroughLabel.text = NSLocalizedString(self.boroughLabel.text!, comment: "")
        self.boroughTextField.placeholder = NSLocalizedString(self.boroughTextField.placeholder!, comment: "")
        self.boroughTextField.text = self.meetingObject.locationBorough
        
        self.townLabel.text = NSLocalizedString(self.townLabel.text!, comment: "")
        self.townTextField.placeholder = NSLocalizedString(self.townTextField.placeholder!, comment: "")
        self.townTextField.text = self.meetingObject.locationTown
        
        self.countyLabel.text = NSLocalizedString(self.countyLabel.text!, comment: "")
        self.countyTextField.placeholder = NSLocalizedString(self.countyTextField.placeholder!, comment: "")
        self.countyTextField.text = self.meetingObject.locationCounty
        
        self.stateLabel.text = NSLocalizedString(self.stateLabel.text!, comment: "")
        self.stateNagLabel.text = NSLocalizedString(self.stateNagLabel.text!, comment: "")
        self.stateTextField.text = self.meetingObject.locationState
        
        self.zipLabel.text = NSLocalizedString(self.zipLabel.text!, comment: "")
        self.zipTextField.text = self.meetingObject.locationZip
        
        self.nationLabel.text = NSLocalizedString(self.nationLabel.text!, comment: "")
        self.nationTextField.placeholder = NSLocalizedString(self.nationTextField.placeholder!, comment: "")
        self.nationTextField.text = self.meetingObject.locationNation
        
        self.extraInfoLabel.text = NSLocalizedString(self.extraInfoLabel.text!, comment: "")
        self.extraInfoTextField.placeholder = NSLocalizedString(self.extraInfoTextField.placeholder!, comment: "")
        self.extraInfoTextField.text = self.meetingObject.locationInfo
        
        self.virtualMeetingLabel.text = NSLocalizedString(self.virtualMeetingLabel.text!, comment: "")
        self.virtualMeetingTextField.placeholder = NSLocalizedString(self.virtualMeetingTextField.placeholder!, comment: "")
        self.virtualMeetingTextField.text = self.meetingObject.virtualMeetingURI
        
        self.meetingPhoneNumberLabel.text = NSLocalizedString(self.meetingPhoneNumberLabel.text!, comment: "")
        self.meetingPhoneNumberTextField.placeholder = NSLocalizedString(self.meetingPhoneNumberTextField.placeholder!, comment: "")
        self.meetingPhoneNumberTextField.text = self.meetingObject.meetingPhoneNumber
    }
}

/* ###################################################################################################################################### */
// MARK: - Map Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the map editor prototype.
 */
class MapTableViewCell: MeetingEditorViewCell, MKMapViewDelegate {
    /// These are the three types of map:
    enum MapTypeValues: Int {
        /// Normal street map
        case Normal = 0
        /// Annotated satellite view
        case Hybrid
        /// Pure satellite view
        case Satellite
    }
    
    /// Initial map size
    private let _mapSizeInDegrees = 0.125
    
    /// The map view instance
    @IBOutlet weak var mapView: MKMapView!
    /// The segmented switch for selecting the map type
    @IBOutlet weak var mapTypeSegmentedView: UISegmentedControl!
    /// The marker for the meeting
    private var _meetingMarker: MapAnnotation! = nil
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        for index in 0..<self.mapTypeSegmentedView.numberOfSegments {
            self.mapTypeSegmentedView.setTitle(NSLocalizedString(self.mapTypeSegmentedView.titleForSegment(at: index)!, comment: ""), forSegmentAt: index)
        }

        self.addMeetingMarker(true)
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the user changes the map type.
     
     - parameter sender: The segmented control.
     */
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case type(of: self).MapTypeValues.Satellite.rawValue:
            self.mapView.mapType = MKMapType.satellite
        case type(of: self).MapTypeValues.Hybrid.rawValue:
            self.mapView.mapType = MKMapType.hybridFlyover
        default:
            self.mapView.mapType = MKMapType.standard
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Tells the object to add its meeting marker to the map.
     This also sets the map to be right at the meeting location.
     
     - parameter inSetZoom: If true, the map will force a zoom. Otherwise, the zoom will be unchanged.
     */
    func addMeetingMarker(_ inSetZoom: Bool) {
        if nil != self._meetingMarker {
            self.mapView.removeAnnotation(self._meetingMarker)
        }
        
        self._meetingMarker = MapAnnotation(coordinate: self.meetingObject.locationCoords, locations: [self.meetingObject])
        
        // Set the marker up.
        self.mapView.addAnnotation(self._meetingMarker)
        
        var span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: self._mapSizeInDegrees, longitudeDelta: 0)
        
        if !inSetZoom {
            // Now, zoom the map to just around the marker.
            span = self.mapView.region.span
        }
        
        let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: self.meetingObject.locationCoords, span: span)
        self.mapView.setRegion(newRegion, animated: false)
    }
    
    /* ################################################################## */
    /**
     - parameter coordinate: New coordinate
     - parameter inSetZoom: If true, the map will force a zoom. Otherwise, the zoom will be unchanged.
     */
    func moveMeetingMarkerToLocation(_ coordinate: CLLocationCoordinate2D, inSetZoom: Bool) {
        self.meetingObject.locationCoords = coordinate
        self.addMeetingMarker(inSetZoom)
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    // MARK: MKMapViewDelegate Methods
    /* ################################################################## */
    /**
     Creates a new marker annotiation for the map.
     
     - parameter mapView: The MKMapView object that is having the marker added.
     - parameter viewFor: The annotation that we need to generate a view for.
     
     - returns: A new annotation view, with our marker.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MapAnnotation.self) {
            let reuseID = String(self.meetingObject.id)
            var myAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
            
            if nil == myAnnotationView {
                myAnnotationView = MapMarker(annotation: annotation as? MapAnnotation, draggable: true, reuseID: reuseID)
            }
            
            return myAnnotationView
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This responds to a marker being moved.
     
     - parameter mapView: The MKMapView object that contains the marker being moved.
     - parameter annotationView: The annotation that was changed.
     - parameter didChange: The new state of the marker.
     - parameter fromOldState: The previous state of the marker.
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch newState {
        case .none:
            if .dragging == oldState {  // If this is a drag ending, we extract the new coordinates, and change the meeting object.
                self.meetingObject.locationCoords = view.annotation?.coordinate
                self.mapView.setCenter(self.meetingObject.locationCoords, animated: true)
                self.owner.updateCoordinates(self.meetingObject.locationCoords)
            }
            
        default:
            break
        }
    }
    
    /* ################################################################## */
    /**
     This responds to the map's region being changed.
     We simply use this to "preselect" the marker, so there's no need for two taps.
     
     - parameter mapView: The MKMapView object that contains the marker being moved.
     - parameter animated: True, if the change was animated.
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.mapView.selectAnnotation(self._meetingMarker, animated: false)
    }
    
    /* ################################################################## */
    /**
     This responds to the marker's selection turning off.
     We simply use this to "preselect" the marker, so there's no need for two taps.
     
     - parameter mapView: The MKMapView object that contains the marker being moved.
     - parameter didDeselect: The annotation view (it's ignored. We always select our marker, no matter what).
     */
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.mapView.selectAnnotation(self._meetingMarker, animated: false)
    }
}

/* ###################################################################################################################################### */
// MARK: - Long/Lat Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the logitude and Latitude editor prototype.
 */
class LongLatTableViewCell: MeetingEditorViewCell {
    /// The label for the longitude text entry
    @IBOutlet weak var longitudeLabel: UILabel!
    /// The longitude text entry
    @IBOutlet weak var longitudeTextField: UITextField!
    /// The label for the latitude text entry
    @IBOutlet weak var latitudeLabel: UILabel!
    /// The latitude text entry
    @IBOutlet weak var latitudeTextField: UITextField!
    /// The button to set the map from the address location
    @IBOutlet weak var setFromAddressButton: UIButton!
    /// The button to set the address from the map
    @IBOutlet weak var setFromMapButton: UIButton!
    /// The mask for the busy animation
    @IBOutlet weak var animationMaskView: UIView!
    
    /* ################################################################## */
    // MARK: Instance Calculated Properties
    /* ################################################################## */
    /**
     Gets and sets the long/lat from the location manager type.
     */
    var coordinate: CLLocationCoordinate2D {
        get {
            var ret: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            if let long = Double(self.longitudeTextField.text!) {
                if let lat = Double(self.latitudeTextField.text!) {
                    ret = CLLocationCoordinate2D(latitude: lat, longitude: long)
                }
            }
            
            return ret
        }
        
        set {
            self.animationMaskView.isHidden = true
            self.longitudeTextField.text = String(newValue.longitude)
            self.latitudeTextField.text = String(newValue.latitude)
            self.owner.updateEditorDisplay(self)
        }
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func longitudeOrLatitudeTextChanged(_ sender: UITextField) {
        if sender == self.longitudeTextField {
            self.meetingObject.locationCoords.longitude = Double ( sender.text! )!
        } else {
            self.meetingObject.locationCoords.latitude = Double ( sender.text! )!
        }
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func setFromAddressButtonHit(_ sender: UIButton) {
        self.animationMaskView.isHidden = false
        self.owner.lookUpAddressForMe()
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func setAddressFromMapButtonHit(_ sender: UIButton) {
        self.animationMaskView.isHidden = false
        self.owner.lookUpCoordinatesForMe()
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.longitudeLabel.text = NSLocalizedString(self.longitudeLabel.text!, comment: "")
        self.longitudeTextField.placeholder = NSLocalizedString(self.longitudeTextField.placeholder!, comment: "")
        self.longitudeTextField.text = String(self.meetingObject.locationCoords.longitude)
        self.latitudeLabel.text = NSLocalizedString(self.latitudeLabel.text!, comment: "")
        self.latitudeTextField.placeholder = NSLocalizedString(self.latitudeTextField.placeholder!, comment: "")
        self.latitudeTextField.text = String(self.meetingObject.locationCoords.latitude)
        self.setFromAddressButton.setTitle(NSLocalizedString(self.setFromAddressButton.title(for: UIControl.State.normal)!, comment: ""), for: UIControl.State.normal)
        self.setFromMapButton.setTitle(NSLocalizedString(self.setFromMapButton.title(for: UIControl.State.normal)!, comment: ""), for: UIControl.State.normal)
        self.animationMaskView.isHidden = true
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Comments Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class MeetingCommentsEditorTableViewCell: MeetingEditorViewCell, UITextViewDelegate {
    /** This is the comments label. */
    @IBOutlet weak var commentsNameLabel: UILabel!
    /** This is the comments text view. */
    @IBOutlet weak var commentsTextView: UITextView!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label and initial text.
     */
    override func meetingObjectUpdated() {
        self.commentsNameLabel.text = NSLocalizedString(self.commentsNameLabel.text!, comment: "")
        self.commentsTextView.text = self.meetingObject.comments
        self.commentsTextView.backgroundColor = UIColor.white
    }
    
    /* ################################################################## */
    // MARK: UITextViewDelegate Protocol Methods
    /* ################################################################## */
    /**
     This updates the comments value.
     
     - parameter textView: The text view that experienced the text change.
     */
    func textViewDidChange(_ textView: UITextView) {
        switch textView {
        case self.commentsTextView:
            self.meetingObject.comments = textView.text
            self.owner.updateEditorDisplay(self)
        default:
            print("Unknown Text View: \(textView)")
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Format Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class FormatsEditorTableViewCell: MeetingEditorViewCell, UITableViewDataSource, UITableViewDelegate {
    /// The height of a format label
    static let sLabelHeight: CGFloat                    = 44
    /// The indent for a checkbox from the checkbox
    static let sFormatCheckboxIndent: CGFloat           = 2
    /// The height of a single format container
    static let sFormatCheckboxContainerHeight: CGFloat  = 44
    /// The width of a format container
    static let sFormatCheckboxContainerWidth: CGFloat   = 80

    /// The format name label
    @IBOutlet weak var formatNameLabel: UILabel!
    /// The table view that shows the formats.
    @IBOutlet weak var formatDisplayTableView: UITableView!
    
    /* ################################################################## */
    /**
     Return the height of the table
     */
    var tableHeight: CGFloat {
        let numRows = CGFloat(tableView(self.formatDisplayTableView, numberOfRowsInSection: 0))
        let tableHeight = numRows * type(of: self).sFormatCheckboxContainerHeight

        return tableHeight
    }
    
    /* ################################################################## */
    /**
     Retun the height of the entire cell
     */
    var cellHeight: CGFloat {
        return self.tableHeight + type(of: self).sLabelHeight
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label and initial text.
     */
    override func meetingObjectUpdated() {
        self.formatNameLabel.text = NSLocalizedString(self.formatNameLabel.text!, comment: "")
        self.formatDisplayTableView.rowHeight = UITableView.automaticDimension
        self.formatDisplayTableView.reloadData()
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This is the callback for one of the format checkboxes being hit.
     
     The format is either added or removed, depending on its selection state.
     
     - parameter inCheckbox: The checkbox that was hit.
     */
    @objc func formatCheckboxActuated(_ inCheckbox: ThreeStateCheckbox) {
        if let formatObject = inCheckbox.extraData as? BMLTiOSLibFormatNode {
            if inCheckbox.selectionState == .Selected {
                self.meetingObject.addFormat(formatObject)
            } else {
                self.meetingObject.removeFormat(formatObject)
            }
        }
        self.owner.updateEditorDisplay(self)
        self.owner.closeKeyboard()
    }
    
    /* ################################################################## */
    /**
     Forces the table to reload
     */
    func reloadTableData() {
        self.formatDisplayTableView.reloadData()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDataSource Methods
    /* ################################################################## */
    /**
     Returns the number of rows to display.
     
     - parameter tableView: The UITableView asking for rows.
     - paramater numberOfRowsInSection: The section index (0-based).
     
     - returns: the number of rows to display
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numFormats = MainAppDelegate.connectionObject.allPossibleFormats.count
        let formatsPerRow = Int(tableView.bounds.size.width / type(of: self).sFormatCheckboxContainerWidth)
        let numRows = Int((numFormats + (formatsPerRow - 1)) / formatsPerRow) + 1
        return numRows
    }
    
    /* ################################################################## */
    /**
     Returns a cell for one row.
     
     - parameter tableView: The UITableView asking for a cell.
     - paramater cellForRowAt: The index path of the cell we want.
     
     - returns: a table cell, containing the row
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numFormats = MainAppDelegate.connectionObject.allPossibleFormats.count
        let formatsPerRow = Int(tableView.bounds.size.width / type(of: self).sFormatCheckboxContainerWidth)
        
        let startingIndex = (indexPath.row * formatsPerRow)
        let endingIndex = min(startingIndex + formatsPerRow, startingIndex + (numFormats - startingIndex))
        
        let ret: UITableViewCell = UITableViewCell()
        ret.backgroundColor = UIColor.clear

        if startingIndex < endingIndex {
            ret.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: type(of: self).sFormatCheckboxContainerHeight)
            
            var indent: CGFloat = 0
            
            for i in startingIndex..<endingIndex {
                let formatObject = MainAppDelegate.connectionObject.allPossibleFormats[i]
                let frame = CGRect(x: indent, y: 0, width: type(of: self).sFormatCheckboxContainerWidth, height: type(of: self).sFormatCheckboxContainerHeight)
                let formatSubCell = UIView(frame: frame)
                formatSubCell.backgroundColor = UIColor.clear
                var checkBoxFrame = CGRect(x: type(of: self).sFormatCheckboxIndent, y: type(of: self).sFormatCheckboxIndent, width: type(of: self).sFormatCheckboxContainerHeight - (type(of: self).sFormatCheckboxIndent * 2), height: type(of: self).sFormatCheckboxContainerHeight - (type(of: self).sFormatCheckboxIndent * 2))
                // Just to make sure we're square.
                checkBoxFrame.size.width = min(checkBoxFrame.size.width, checkBoxFrame.size.height)
                checkBoxFrame.size.height = min(checkBoxFrame.size.width, checkBoxFrame.size.height)
                let checkBoxObject = ThreeStateCheckbox(frame: checkBoxFrame)
                checkBoxObject.binaryState = true
                checkBoxObject.extraData = formatObject
                checkBoxObject.selectionState = self.meetingObject.formats.contains(formatObject) ? .Selected : .Clear
                checkBoxObject.addTarget(self, action: #selector(FormatsEditorTableViewCell.formatCheckboxActuated), for: UIControl.Event.valueChanged)
                formatSubCell.addSubview(checkBoxObject)
                let labelFrame = CGRect(x: checkBoxFrame.origin.x + checkBoxFrame.size.width + type(of: self).sFormatCheckboxIndent, y: 0, width: frame.size.width - checkBoxFrame.origin.x + checkBoxFrame.size.width + type(of: self).sFormatCheckboxIndent, height: type(of: self).sFormatCheckboxContainerHeight)
                let labelObject = UILabel(frame: labelFrame)
                labelObject.backgroundColor = UIColor.clear
                labelObject.textColor = tableView.tintColor
                labelObject.text = formatObject.key
                formatSubCell.addSubview(labelObject)
                indent += type(of: self).sFormatCheckboxContainerWidth
                ret.addSubview(formatSubCell)
            }
        }
        
        return ret
    }
}
