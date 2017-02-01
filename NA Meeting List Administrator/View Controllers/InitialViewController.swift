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
    // MARK: Instance IB Properties
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
    /** This is the container for the "Enter Root Server" stuff. */
    @IBOutlet weak var urlEntryItemsContainerView: UIView!
    /** This is the main label for the enter URL view */
    @IBOutlet weak var enterURLItemsLabel: UILabel!
    /** This is the "Connect" button. */
    @IBOutlet weak var connectButton: UIButton!
    /** This is the URL entry text item. */
    @IBOutlet weak var enterURLTextItem: UITextField!
    /** This is the little settings "gear" in the lower right corner. */
    @IBOutlet weak var settingsButton: UIButton!
    /** This is the "DISCONNECT" button that shows up when we are connected. */
    @IBOutlet weak var disconnectButton: UIButton!
    
    /* ################################################################## */
    // MARK: Instance Properties
    /* ################################################################## */
    /** This is set to true while we are in the process of logging in. */
    private var _loggingIn: Bool = false
    /** This is set to true while we are in the process of connecting. */
    private var _connecting: Bool = false
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        MainAppDelegate.appDelegateObject.initialViewController = self
        self.loginItemsLabel.text = NSLocalizedString(self.loginItemsLabel.text!, comment: "")
        self.loginIDLabel.text = NSLocalizedString(self.loginIDLabel.text!, comment: "")
        self.loginIDTextField.placeholder = NSLocalizedString(self.loginIDTextField.placeholder!, comment: "")
        self.passwordLabel.text = NSLocalizedString(self.passwordLabel.text!, comment: "")
        self.passwordTextField.placeholder = NSLocalizedString(self.passwordTextField.placeholder!, comment: "")
        self.loginButton.setTitle(NSLocalizedString(self.loginButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.logoutButton.setTitle(NSLocalizedString(self.logoutButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.adminUnavailableLabel.text = NSLocalizedString(self.adminUnavailableLabel.text!, comment: "")
        self.enterURLItemsLabel.text = NSLocalizedString(self.enterURLItemsLabel.text!, comment: "")
        self.enterURLTextItem.placeholder = NSLocalizedString(self.enterURLTextItem.placeholder!, comment: "")
        self.enterURLTextItem.text = AppStaticPrefs.prefs.rootURI
        self.connectButton.setTitle(NSLocalizedString(self.connectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.disconnectButton.setTitle(NSLocalizedString(self.disconnectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self._loggingIn = false
        self.setLoginStatusUI()
    }
    
    /* ################################################################## */
    /**
     We simply use this to make sure our NavBar is hidden.
     
     Simplify, simplify, simplify.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true;
        self._loggingIn = false
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
     Called when text is added/removed from the login ID text field.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func loginTextChanged(_ sender: UITextField) {
        self.showOrHideLoginButton()
    }
    
    /* ################################################################## */
    /**
     Called when text is added/removed from the password text field.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func passwordTextChanged(_ sender: UITextField) {
        self.showOrHideLoginButton()
    }
    
    /* ################################################################## */
    /**
     Called when text is added/removed from the Root Server URI text field.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func urlTextChanged(_ sender: UITextField) {
        AppStaticPrefs.prefs.rootURI = sender.text!
        self.showOrHideConnectButton()
    }
    
    /* ################################################################## */
    /**
     Called when the "CONNECT" button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func connectButtonHit(_ sender: UIButton) {
        self._connecting = true
        self._loggingIn = false
        MainAppDelegate.connectionStatus = true
    }
    
    /* ################################################################## */
    /**
     Called when the "DISCONNECT" button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func disconnectButtonHit(_ sender: UIButton) {
        self._connecting = false
        self._loggingIn = false
        MainAppDelegate.connectionStatus = false
    }
    
    /* ################################################################## */
    /**
     Called when the Settings button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func settingsButtonHit(_ sender: UIButton) {
    }
    
    /* ################################################################## */
    /**
     Called when the "LOG IN" button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func loginButtonHit(_ sender: UIButton) {
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminAvailable {
            if MainAppDelegate.connectionObject.adminLogin(loginID: self.loginIDTextField.text!, password: self.passwordTextField.text!) {
                self.animationMask.isHidden = false
                self._loggingIn = true
                self.view.setNeedsLayout()
            }
        }
    }

    /* ################################################################## */
    /**
     Called when the "LOGOUT" button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func logoutButtonHit(_ sender: UIButton) {
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminAvailable {
            if MainAppDelegate.connectionObject.adminLogout() {
                self.animationMask.isHidden = true
                self._loggingIn = false
                self.view.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Starts the connecting animation
     */
    func startConnection() {
        self.animationMask.isHidden = false
        self._loggingIn = false
        self._connecting = true
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation.
     */
    func finishedConnecting() {
        self.animationMask.isHidden = true
        self._loggingIn = false
        self._connecting = false
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation.
     */
    func finishedLoggingIn() {
        self.animationMask.isHidden = true
        self._loggingIn = false
        self._connecting = false
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     This function will either show (enable) or hide (disable) the login button.
     */
    func showOrHideLoginButton() {
        let loginIDFieldIsEmpty = self.loginIDTextField.text?.isEmpty
        let passwordFieldIsEmpty = self.passwordTextField.text?.isEmpty
        let hideLoginButton = loginIDFieldIsEmpty! || passwordFieldIsEmpty!
        
        self.loginButton.isEnabled = !hideLoginButton
    }
    
    /* ################################################################## */
    /**
     This function will either show (enable) or hide (disable) the connect button.
     */
    func showOrHideConnectButton() {
        self.connectButton.isEnabled = (nil == MainAppDelegate.connectionObject) && !(self.enterURLTextItem.text?.isEmpty)! && !MainAppDelegate.connectionStatus
        self.disconnectButton.isEnabled = (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus
    }
    
    /* ################################################################## */
    /**
     This shows or hides items, depending on the login status.
     */
    func setLoginStatusUI() {
        if !self._connecting && (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus {
            self.urlEntryItemsContainerView.isHidden = true
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
            self.loginItemsContainer.isHidden = true
            self.urlEntryItemsContainerView.isHidden = false
            self.adminUnavailableLabel.isHidden = true
        }
        
        self.showOrHideConnectButton()
        self.showOrHideLoginButton()
    }
}

