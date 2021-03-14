//  EditorTabBarController.swift
//  NA Meeting List Administrator
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

/* ###################################################################################################################################### */
// MARK: - Protocol for Tabs -
/* ###################################################################################################################################### */
/// This protocol defines some methods to show and hide animation.
protocol EditorTabBarControllerProtocol: class {
    /// This is used to prevent reloads
    var searchDone: Bool { get set }
    
    /* ################################################################## */
    /**
     Displays the busy animation when updating.
     */
    func showBusyAnimation()

    /* ################################################################## */
    /**
     Displays the busy animation when updating.
     */
    func hideBusyAnimation()
}

/* ###################################################################################################################################### */
// MARK: - This is the main tab controller for the various editor pages -
/* ###################################################################################################################################### */
/**
 */
class EditorTabBarController: UITabBarController, UITabBarControllerDelegate {
    /// The indexes for our two tabs.
    enum TabIndexes: Int {
        /// The list view tab
        case ListTab = 0
        /// The deleted meetings tab
        case DeletedTab
    }

    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called when the view has finished loading.
     */
    override func viewDidLoad() {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.tabBarItem.title = NSLocalizedString(listViewController.tabBarItem.title!, comment: "")
        }
        
        if let deletedViewController = self.viewControllers?[TabIndexes.DeletedTab.rawValue] as? DeletedMeetingsViewController {
            deletedViewController.tabBarItem.title = NSLocalizedString(deletedViewController.tabBarItem.title!, comment: "")
        }
        
        self.tabBar.unselectedItemTintColor = self.tabBar.tintColor
        self.tabBar.tintColor = .label

        self.delegate = self
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Called to select a specific meeting for editing.
     */
    func select(thisMeetingID inID: Int) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.searchDone = false
            listViewController.showMeTheMoneyID = inID
            self.selectedIndex = TabIndexes.ListTab.rawValue
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects: [BMLTiOSLibMeetingNode]) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.updateSearch(inMeetingObjects: inMeetingObjects)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the library returns change updates.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateChangeResponse(changeListResults: [BMLTiOSLibChangeNode]) {
    }
    
    /* ################################################################## */
    /**
     This is called when a meeting rollback is complete.
     
     - parameter inMeeting: The meeting that was updated.
     */
    func updateRollback(_ inMeeting: BMLTiOSLibMeetingNode) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.updateRollback(inMeeting)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a change fetch is complete.
     */
    func updateChangeFetch() {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.updateChangeFetch()
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a meeting edit or add is complete.
     
     - parameter inMeeting: The meeting that was edited or added. nil, if we want a general update.
     */
    func updateEdit(_ inMeeting: BMLTiOSLibMeetingNode!) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            listViewController.doSearch()
        }
    }

    /* ################################################################## */
    /**
     This is called after we successfully delete a meeting.
     We use this as a trigger to tell the deleted meetings tab it needs a reload.
     */
    func updateDeletedMeeting() {
        if let deletedViewController = self.viewControllers?[TabIndexes.DeletedTab.rawValue] as? DeletedMeetingsViewController {
            deletedViewController.searchDone = false
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the library gets a new meeting added.
     
     - parameter inNewMeeting: The new meeting object.
     */
    func updateNewMeetingAdded(_ inNewMeeting: BMLTiOSLibMeetingNode) {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? ListEditableMeetingsViewController {
            if let newMeeting = inNewMeeting as? BMLTiOSLibEditableMeetingNode {
                listViewController.updateNewMeeting(inMeetingObject: newMeeting)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called when the library returns change updates for deleted meetings.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateDeletedResponse(changeListResults: [BMLTiOSLibChangeNode]) {
        if let deletedViewController = self.viewControllers?[TabIndexes.DeletedTab.rawValue] as? DeletedMeetingsViewController {
            deletedViewController.updateDeletedResponse(changeListResults: changeListResults)
        }
    }
    
    /* ################################################################## */
    // MARK: UITabBarControllerDelegate Methods
    /* ################################################################## */
    /**
     - parameter tabBarController: An array of meeting objects.
     */
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let listViewController = self.viewControllers?[TabIndexes.ListTab.rawValue] as? EditorTabBarControllerProtocol {
            listViewController.searchDone = true    // We do this to prevent a new load being done just for a context switch.
            listViewController.showBusyAnimation()
        }
        
        return true
    }
}

/* ###################################################################################################################################### */
// MARK: - This is a base class for the various editor view controllers. -
/* ###################################################################################################################################### */
/**
 This simply sets the tab and nav bars to the proper colors for the screen.
 */
class EditorViewControllerBaseClass: UIViewController {
    /* ################################################################## */
    /**
     This is called just before we appear. We use it to set up the gradients and the bar color.
     
     - parameter animated: True, if the appearance is to be animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let topColor = (self.view as? EditorViewBaseClass)?.topColor,
           let bottomColor = (self.view as? EditorViewBaseClass)?.bottomColor {
            self.navigationController?.navigationBar.barTintColor = topColor
            self.tabBarController?.tabBar.barTintColor = bottomColor
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - This is a base class for the various editor pages. -
/* ###################################################################################################################################### */
/**
 I cribbed the basics of this from here: https://www.hackingwithswift.com/read/37/4/adding-a-cagradientlayer-with-ibdesignable-and-ibinspectable
 */
class EditorViewBaseClass: UIView {
    /// The top color of our background gradient.
    @IBInspectable var topColor: UIColor?
    /// The bottom color of our background gradient.
    @IBInspectable var bottomColor: UIColor?
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     This casts our layer to a gradient layer.
     */
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    /* ################################################################## */
    /**
     Called when the class is to lay out its subviews.
     */
    override func layoutSubviews() {
        if let topColor = topColor,
           let bottomColor = bottomColor {
            (layer as? CAGradientLayer)?.colors = [topColor.cgColor, bottomColor.cgColor]
        }
        super.layoutSubviews()
    }
}
