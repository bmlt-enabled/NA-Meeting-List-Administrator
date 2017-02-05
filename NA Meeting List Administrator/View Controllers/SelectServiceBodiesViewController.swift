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
    private typealias CheckBoxServiceBodyTuple = (checkBoxObject: SimpleCheckbox?, serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode?, selected: Bool)
    
    private var _collectedCheckboxes: [CheckBoxServiceBodyTuple] = []
    
    @IBOutlet weak var serviceBodyTableView: UITableView!
    
    /* ################################################################## */
    /**
     */
    override func viewDidLoad() {
        if nil != MainAppDelegate.connectionObject {
            self._collectedCheckboxes = []
            
            for sbObject in MainAppDelegate.connectionObject.serviceBodiesICanEdit {
                self._collectedCheckboxes.append((checkBoxObject: nil, serviceBodyObject: sbObject, selected: true))
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func checkboxChanged(_ sender: SimpleCheckbox) {
        for cb in self._collectedCheckboxes {
            if cb.checkBoxObject == sender {
                self.changeSBSelection(inServiceBodyObject: cb.serviceBodyObject!, inSelection: sender.checked)
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func changeSBSelection(inServiceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode, inSelection: Bool) {
        for i in 0..<self._collectedCheckboxes.count {
            if self._collectedCheckboxes[i].serviceBodyObject == inServiceBodyObject {
                self._collectedCheckboxes[i].selected = inSelection
                for sbChild in inServiceBodyObject.children {
                    self.changeSBSelection(inServiceBodyObject: sbChild, inSelection: inSelection)
                }
                
                if nil != self._collectedCheckboxes[i].checkBoxObject {
                    self._collectedCheckboxes[i].checkBoxObject!.checked = inSelection
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._collectedCheckboxes.count
    }
    
    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ServiceBodyTableCellView.selectorCellReuseID) as? ServiceBodyTableCellView {
            if let serviceBodyObject = self._collectedCheckboxes[indexPath.row].serviceBodyObject {
                cell.serviceBodyNameLabel.text = serviceBodyObject.name
                cell.backgroundColor = UIColor.clear
                let indent = CGFloat(serviceBodyObject.howDeepInTheRabbitHoleAmI) + 1
                let multiplier = CGFloat(ServiceBodyTableCellView.indentSizeInDisplayUnits)
                cell.checkboxIndentConstraint.constant = multiplier * indent
                for i in 0..<self._collectedCheckboxes.count {
                    if self._collectedCheckboxes[i].serviceBodyObject == serviceBodyObject {
                        self._collectedCheckboxes[i].checkBoxObject = cell.serviceBodyCheckbox
                        cell.serviceBodyCheckbox.checked = self._collectedCheckboxes[i].selected
                        cell.serviceBodyCheckbox.addTarget(self, action: #selector(SelectServiceBodiesViewController.checkboxChanged(_:)), for: UIControlEvents.valueChanged)
                    }
                }
                return cell
            }
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
    static let selectorCellReuseID = "serviceBodySelectorCell"
    static let indentSizeInDisplayUnits: Int = 16
    
    @IBOutlet weak var serviceBodyCheckbox: SimpleCheckbox!
    @IBOutlet weak var serviceBodyNameLabel: UILabel!
    @IBOutlet weak var checkboxIndentConstraint: NSLayoutConstraint!
    
    /* ################################################################## */
    /**
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
