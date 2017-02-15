//
//  MeetingEditorBaseViewController.swift
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
// MARK: - Base Single Meeting Editor View Controller Class -
/* ###################################################################################################################################### */
/**
 This class describes the basic functionality for a full meeting editor.
 */
class MeetingEditorBaseViewController : EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    private var _internalRowHeights: [String:CGFloat] = ["editor-row-0":37,
                                                         "editor-row-1":60,
                                                         "editor-row-2":60,
                                                         "editor-row-3":100,
                                                         "editor-row-4":100,
                                                         "editor-row-5":277
    ]
    
    /** We use this as a common prefix for our reuse IDs, and the index as the suffix. */
    let reuseIDBase = "editor-row-"
    
    /** This is the meeting object for this instance. */
    var meetingObject: BMLTiOSLibEditableMeetingNode! = nil
    
    /** This is a list of all the cells (editor sections). */
    var editorSections: [MeetingEditorViewCell] = []
    
    /** These store the original (unpublished) colors for the background gradient. */
    private var _publishedTopColor: UIColor! = nil
    private var _publishedBottomColor: UIColor! = nil
    
    /** This is the structural table view */
    @IBOutlet var tableView: UITableView!
    
    /** THis is the bar button item for saving changes. */
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /** The following are sections in our table. Each is described by a prototype. */
    
    /** These are the three "dynamics" in the editor. */
    /** If true, then we allow the meeting to be deleted. */
    @IBInspectable var showDelete: Bool!
    /** If true, then we allow the meeting to be saved as a duplicate. */
    @IBInspectable var showDuplicate: Bool!
    /** If true, then we allow meeting history to be shown. */
    @IBInspectable var showHistory: Bool!
    /** If true, then we show the cancel button. */
    @IBInspectable var showCancel: Bool!
    /** If the meeting is unpublished, we have a different color background gradient. */
    @IBInspectable var unpublishedTopColor: UIColor!
    @IBInspectable var unpublishedBottomColor: UIColor!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We take this opportunity to save our published colors.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self._publishedTopColor = (self.view as! EditorViewBaseClass).topColor
        self._publishedBottomColor = (self.view as! EditorViewBaseClass).bottomColor
    }
    
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.editorSections = []
        self.tableView.reloadData()
        self.saveButton.title = NSLocalizedString(self.saveButton.title!, comment: "")
        self.updateEditorDisplay()
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the NavBar Save button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
        self.meetingObject.saveChanges()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Called when something changes in the various controls.
     
     - parameter inChangedCell: The table cell object that experienced the change. If nil, then no meeting cell was changed. nil is default.
     */
    func updateEditorDisplay(_ inChangedCell: MeetingEditorViewCell! = nil) {
        if self.meetingObject.published {
            (self.view as! EditorViewBaseClass).topColor = self._publishedTopColor
            (self.view as! EditorViewBaseClass).bottomColor = self._publishedBottomColor
        } else {
            (self.view as! EditorViewBaseClass).topColor = self.unpublishedTopColor
            (self.view as! EditorViewBaseClass).bottomColor = self.unpublishedBottomColor
        }
        
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
        let reuseID = self.reuseIDBase + String(indexPath.row)
        
        if let returnableCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as? MeetingEditorViewCell {
            returnableCell.owner = self
            returnableCell.meetingObject = self.meetingObject
            self.editorSections.append(returnableCell)
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
        let reuseID = self.reuseIDBase + String(indexPath.row)
        
        switch(reuseID) {   // This allows us to set dynamic heights.
        default:
            if let height = self._internalRowHeights[reuseID] { // By default, we use our table, but we may not have something there.
                return height
            }
        }
        
        return tableView.rowHeight  // All else fails, use the default table row height.
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
    func meetingObjectUpdated(){}
}

/* ###################################################################################################################################### */
// MARK: - Meeting Published Status Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class PublishedEditorTableViewCell: MeetingEditorViewCell {
    /** This is the meeting name section. */
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var publishedSwitch: UISwitch!
    
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
    @IBOutlet weak var meetingNameLabel: UILabel!
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
    /** This is the meeting name section. */
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var weekdaySegmentedView: UISegmentedControl!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to weekday selection changing in the segmented control.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func weekdayChanged(_ sender: UISegmentedControl) {
        self.meetingObject.weekdayIndex = sender.selectedSegmentIndex + 1
        self.owner.updateEditorDisplay(self)
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
        self.weekdaySegmentedView.selectedSegmentIndex = self.meetingObject.weekdayIndex - 1
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Start Time Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class StartTimeEditorTableViewCell: MeetingEditorViewCell {
    /** This is the meeting name section. */
    @IBOutlet weak var startTimeLabel: UILabel!
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
    /** This is the meeting name section. */
    @IBOutlet weak var durationLabel: UILabel!
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
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueNameTextField: UITextField!
    
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var streetAddressTextField: UITextField!
    
    @IBOutlet weak var neighborhoodLabel: UILabel!
    @IBOutlet weak var neighborhoodTextField: UITextField!
    
    @IBOutlet weak var boroughLabel: UILabel!
    @IBOutlet weak var boroughTextField: UITextField!
    
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var townTextField: UITextField!
    
    @IBOutlet weak var countyLabel: UILabel!
    @IBOutlet weak var countyTextField: UITextField!
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var zipTextField: UITextField!
    
    @IBOutlet weak var nationLabel: UILabel!
    @IBOutlet weak var nationTextField: UITextField!
    
    @IBOutlet weak var extraInfoLabel: UILabel!
    @IBOutlet weak var extraInfoTextField: UITextField!
    
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
    }
}

