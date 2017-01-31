//  InitialViewController.swift
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

/* ###################################################################################################################################### */
// MARK: - Initial View Controller Class -
/* ###################################################################################################################################### */
class InitialViewController: UIViewController {
    /* ################################################################## */
    // MARK: Instance Properties
    /* ################################################################## */
    /** The mask view with the spinning throbber. */
    @IBOutlet weak var animationMask: UIView!
    /** This contains the various login items. */
    @IBOutlet weak var loginItemsContainer: UIView!
    /** This is the overall label. */
    @IBOutlet weak var loginItemsLabel: UILabel!
    /** This is the label for the login ID text entry. */
    @IBOutlet weak var loginIDLabel: UILabel!
    /** This is the text field where the user enters their login ID. */
    @IBOutlet weak var loginIDTextField: UITextField!
    /** This is the label for the password text field. */
    @IBOutlet weak var passwordLabel: UILabel!
    /** This is the text field where users enter the password. */
    @IBOutlet weak var passwordTextField: UITextField!
    /** This is the login button. */
    @IBOutlet weak var loginButton: UIButton!
    /** This is the logout button. */
    @IBOutlet weak var logoutButton: UIButton!
    /** This is displayed if administration is not available. */
    @IBOutlet weak var adminUnavailableLabel: UILabel!
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        MainAppDelegate.appDelegateObject.initialViewController = self
        MainAppDelegate.connectionStatus = true
        self.loginItemsLabel.text = NSLocalizedString(self.loginItemsLabel.text!, comment: "")
        self.loginIDLabel.text = NSLocalizedString(self.loginIDLabel.text!, comment: "")
        self.loginIDTextField.placeholder = NSLocalizedString(self.loginIDTextField.placeholder!, comment: "")
        self.passwordLabel.text = NSLocalizedString(self.passwordLabel.text!, comment: "")
        self.passwordTextField.placeholder = NSLocalizedString(self.passwordTextField.placeholder!, comment: "")
        self.loginButton.setTitle(NSLocalizedString(self.loginButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.logoutButton.setTitle(NSLocalizedString(self.logoutButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.adminUnavailableLabel.text = NSLocalizedString(self.adminUnavailableLabel.text!, comment: "")
    }
    
    /* ################################################################## */
    /**
     We simply use this to make sure our NavBar is hidden.
     
     Simplify, simplify, simplify.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true;
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     We use this opportunity to make sure our various login items are set up.
     */
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLoginStatusUI()
    }
    
    /* ################################################################## */
    // MARK: IBAction Methods
    /* ################################################################## */
    /**
     */
    @IBAction func loginTextChanged(_ sender: UITextField) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func passwordTextChanged(_ sender: UITextField) {
    }
    
    /* ################################################################## */
    /**
     */
    @IBAction func loginButtonHit(_ sender: UIButton) {
    }

    /* ################################################################## */
    /**
     */
    @IBAction func logoutButtonHit(_ sender: UIButton) {
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Starts the connecting animation
     */
    func startConnection() {
        self.animationMask.isHidden = false
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation.
     */
    func endConnection() {
        self.animationMask.isHidden = true
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     This shows or hides items, depending on the login status.
     */
    func setLoginStatusUI() {
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus {
            if MainAppDelegate.connectionObject.isAdminLoggedIn {
                self.logoutButton.isHidden = false
                self.adminUnavailableLabel.isHidden = true
                self.loginItemsContainer.isHidden = true
            } else {
                self.logoutButton.isHidden = true
                
                if MainAppDelegate.connectionObject.isAdminAvailable {
                    self.adminUnavailableLabel.isHidden = true
                    self.loginItemsContainer.isHidden = false
                } else {
                    self.loginItemsContainer.isHidden = true
                    self.adminUnavailableLabel.isHidden = false
                }
            }
        } else {
            self.adminUnavailableLabel.isHidden = true
        }
    }
}

