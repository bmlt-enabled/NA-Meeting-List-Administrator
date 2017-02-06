//
//  EditorTabBarController.swift
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
// MARK: - This is the main tab controller for the various editor pages -
/* ###################################################################################################################################### */
/**
 */
class EditorTabBarController : UITabBarController {
    enum TabIndexes: Int {
        case ListTab = 0
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects:[BMLTiOSLibMeetingNode]) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.updateSearch(inMeetingObjects: inMeetingObjects)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - This is a base class for the various editor pages. -
/* ###################################################################################################################################### */
/**
 */
class EditorViewControllerBaseClass : UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        let topColor = (self.view as! EditorViewBaseClass).topColor
        let bottomColor = (self.view as! EditorViewBaseClass).bottomColor
        
        self.navigationController?.navigationBar.barTintColor = topColor
        self.tabBarController?.tabBar.barTintColor = bottomColor
        
        super.viewWillAppear(animated)
    }
}

/* ###################################################################################################################################### */
// MARK: - This is a base class for the various editor pages. -
/* ###################################################################################################################################### */
/**
 I cribbed the basics of this from here: https://www.hackingwithswift.com/read/37/4/adding-a-cagradientlayer-with-ibdesignable-and-ibinspectable
 */
class EditorViewBaseClass : UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
