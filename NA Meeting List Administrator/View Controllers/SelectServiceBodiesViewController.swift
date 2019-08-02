//  SelectServiceBodiesViewController.swift
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
// MARK: - Select Service Bodies View Controller Class -
/* ###################################################################################################################################### */
/**
 */
class SelectServiceBodiesViewController: UIViewController, UITableViewDataSource {
    /// The table view that lists the Service bodies.
    @IBOutlet weak var serviceBodyTableView: UITableView!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     This is called just before the view disappears. We take the opportunity to save the prefs.
     
     - parameter animated: If true, then the disappearance is animated.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppStaticPrefs.prefs.savePrefs()
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This is the callback for when the user has Igor throw the switch.
     
     - parameter sender: The AnnotatedSwitch object that Igor used.
     */
    @objc func checkboxChanged(_ sender: AnnotatedSwitch) {
        if let serviceBodyObject = sender.attachedServiceBodyObject {
            self.changeSBSelection(inServiceBodyObject: serviceBodyObject, inSelection: sender.isOn)
        }
        
        self.serviceBodyTableView.reloadData()
    }
    
    /* ################################################################## */
    /**
     This is a recursive funtion that sets any "child" objects to match the state of the parent.
     
     - parameter inServiceBodyObject: The given Service body object
     - parameter inSelection: True, if the body is to be selected.
     */
    func changeSBSelection(inServiceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode, inSelection: Bool) {
        AppStaticPrefs.prefs.setServiceBodySelection(serviceBodyObject: inServiceBodyObject, selected: inSelection)
        for sbChild in inServiceBodyObject.children {
            self.changeSBSelection(inServiceBodyObject: sbChild, inSelection: inSelection)
        }
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
        return AppStaticPrefs.prefs.allEditableServiceBodies.count
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Service body indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serviceBodyObject = AppStaticPrefs.prefs.allEditableServiceBodies[indexPath.row]
        var cell: ServiceBodyTableCellView! = tableView.dequeueReusableCell(withIdentifier: String(serviceBodyObject.id)) as? ServiceBodyTableCellView
        
        if nil == cell {
            var frame = tableView.bounds
            frame.size.height = tableView.rowHeight
            frame.origin = CGPoint.zero
            
            cell = ServiceBodyTableCellView(frame: frame, inTextColor: self.view.tintColor, serviceBodyObject: serviceBodyObject)
        }
        
        if nil != cell {
            cell!.serviceBodyCheckbox.removeTarget(self, action: #selector(SelectServiceBodiesViewController.checkboxChanged(_:)), for: UIControl.Event.valueChanged)   // Make sure we don't send out any callbacks when we set the selection.
            cell!.serviceBodyCheckbox.isOn = AppStaticPrefs.prefs.serviceBodyIsSelected(serviceBodyObject)
            cell!.serviceBodyCheckbox.addTarget(self, action: #selector(SelectServiceBodiesViewController.checkboxChanged(_:)), for: UIControl.Event.valueChanged)
            return cell
        }
        
        return UITableViewCell()
    }
}

/* ###################################################################################################################################### */
// MARK: - This is the prototype class for a Service body table cell -
/* ###################################################################################################################################### */
/**
 */
class ServiceBodyTableCellView: UITableViewCell {
    /// The indent to use for "contained" Service bodies
    static let indentSizeInDisplayUnits: CGFloat = 16
    /// The padding between the checkbow (switch) and the label
    static let checkboxPaddingInDisplayUnits: CGFloat = 4
    
    /// The Service body object associated with this table cell
    var serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode!
    /// The switch that selects/deselects the Service body
    var serviceBodyCheckbox: AnnotatedSwitch!
    /// The label with the Service body name
    var serviceBodyNameLabel: UILabel!
    
    /* ################################################################## */
    // MARK: Initializers
    /* ################################################################## */
    /**
     This is a fairly basic initializer that sets up all of the data for the cell object.
     
     Screw all the MVC nonsense. I'm using this class to set the value for the name, as that is very static. The only dynamic value is set by the above method.
     
     - parameter frame: The frame for the new view
     - parameter inTextColor: The color for the Service body name label text.
     - parameter serviceBodyObject: The Service body object to be associated with this cell view
     */
    init(frame: CGRect, inTextColor: UIColor, serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode!) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: String(serviceBodyObject.id))

        self.serviceBodyObject = serviceBodyObject
        
        let indent = CGFloat(self.serviceBodyObject.howDeepInTheRabbitHoleAmI) + 1

        let view = UIView(frame: frame)
        self.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        
        var cbFrame = frame
        cbFrame.origin.x = indent * type(of: self).indentSizeInDisplayUnits
        cbFrame.origin.y = type(of: self).checkboxPaddingInDisplayUnits
        cbFrame.size.height = frame.size.height - (type(of: self).checkboxPaddingInDisplayUnits * 2)
        cbFrame.size.width = cbFrame.size.height * 1.5
        
        self.serviceBodyCheckbox = AnnotatedSwitch(frame: cbFrame)
        view.addSubview(self.serviceBodyCheckbox)
        
        var labelFrame = CGRect.zero
        labelFrame.size.height = frame.size.height
        labelFrame.origin.x = cbFrame.origin.x + cbFrame.size.width + (type(of: self).checkboxPaddingInDisplayUnits * 2)
        labelFrame.size.width = frame.size.width - labelFrame.origin.x
        self.serviceBodyNameLabel = UILabel(frame: labelFrame)
        self.serviceBodyNameLabel.textColor = inTextColor
        
        view.addSubview(self.serviceBodyNameLabel)
        
        self.serviceBodyCheckbox.attachedServiceBodyObject = self.serviceBodyObject
        self.serviceBodyNameLabel.text = self.serviceBodyObject.name
        
        self.addSubview(view)
    }
    
    /* ################################################################## */
    /**
     This is the rquired coder init. We basically just pass it straight up the food chain.
     
     - parameter aDecoder: The decoder to be parsed for the class data.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/* ###################################################################################################################################### */
// MARK: - Annotated UISwitch Class -
/* ###################################################################################################################################### */
/**
 This is a simple subclass of the standard UISwitch class. It allows us to attach a Service body to the UI element, which makes responding to clicks a lot easier.
 */
class AnnotatedSwitch: UISwitch {
    /** We use this to associate any extra data we want with the instance. */
    var attachedServiceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode?
}
