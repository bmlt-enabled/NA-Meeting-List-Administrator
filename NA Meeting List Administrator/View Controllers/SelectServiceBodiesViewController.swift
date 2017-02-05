//
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
class SelectServiceBodiesViewController : UIViewController, UITableViewDataSource {
    @IBOutlet weak var serviceBodyTableView: UITableView!
    
    /* ################################################################## */
    /**
     */
    func checkboxChanged(_ sender: SimpleCheckbox) {
        if let serviceBodyObject = sender.extraData as? BMLTiOSLibHierarchicalServiceBodyNode {
            self.changeSBSelection(inServiceBodyObject: serviceBodyObject, inSelection: sender.checked)
            self.serviceBodyTableView.reloadData()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func changeSBSelection(inServiceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode, inSelection: Bool) {
        for sbChild in inServiceBodyObject.children {
            self.changeSBSelection(inServiceBodyObject: sbChild, inSelection: inSelection)
        }
        
        AppStaticPrefs.prefs.setServiceBodySelection(serviceBodyObject: inServiceBodyObject, selected: inSelection)
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppStaticPrefs.prefs.allEditableServiceBodies.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serviceBodyObject = AppStaticPrefs.prefs.allEditableServiceBodies[indexPath.row]
        let reuseID = String(serviceBodyObject.id)
        var cell: ServiceBodyTableCellView! = tableView.dequeueReusableCell(withIdentifier: reuseID) as? ServiceBodyTableCellView
        
        if nil == cell {
            var frame = tableView.bounds
            frame.size.height = tableView.rowHeight
            frame.origin = CGPoint.zero
            let indent = CGFloat(serviceBodyObject.howDeepInTheRabbitHoleAmI) + 1
            
            cell = ServiceBodyTableCellView(style: UITableViewCellStyle.default, reuseIdentifier: reuseID, frame: frame, indent: indent, inTextColor: self.view.tintColor)
            
            if nil != cell {
                cell!.serviceBodyCheckbox.extraData = serviceBodyObject
                cell!.serviceBodyNameLabel.text = serviceBodyObject.name
            }
        }
        
        if nil != cell {
            cell!.serviceBodyCheckbox.removeTarget(self, action: #selector(SelectServiceBodiesViewController.checkboxChanged(_:)), for: UIControlEvents.valueChanged)   // Make sure we don't send out any callbacks when we set the selection.
            cell!.serviceBodyCheckbox.checked = AppStaticPrefs.prefs.serviceBodyIsSelected(serviceBodyObject)
            cell!.serviceBodyCheckbox.addTarget(self, action: #selector(SelectServiceBodiesViewController.checkboxChanged(_:)), for: UIControlEvents.valueChanged)
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
    static let indentSizeInDisplayUnits: CGFloat = 16
    static let checkboxPaddingInDisplayUnits: CGFloat = 4
    
    var serviceBodyCheckbox: SimpleCheckbox!
    var serviceBodyNameLabel: UILabel!
    
    init(style: UITableViewCellStyle, reuseIdentifier: String, frame: CGRect, indent: CGFloat, inTextColor: UIColor) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIView(frame: frame)
        self.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        
        var cbFrame = frame
        cbFrame.origin.x = indent * type(of: self).indentSizeInDisplayUnits
        cbFrame.origin.y = type(of: self).checkboxPaddingInDisplayUnits
        cbFrame.size.height = frame.size.height - (type(of: self).checkboxPaddingInDisplayUnits * 2)
        cbFrame.size.width = cbFrame.size.height
        
        self.serviceBodyCheckbox = SimpleCheckbox(frame: cbFrame)
        view.addSubview(self.serviceBodyCheckbox)
        
        var labelFrame = CGRect.zero
        labelFrame.size.height = frame.size.height
        labelFrame.origin.x = cbFrame.origin.x + cbFrame.size.width + type(of: self).checkboxPaddingInDisplayUnits
        labelFrame.size.width = frame.size.width - labelFrame.origin.x
        self.serviceBodyNameLabel = UILabel(frame: labelFrame)
        self.serviceBodyNameLabel.textColor = inTextColor
        
        view.addSubview(self.serviceBodyNameLabel)
        
        self.addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
