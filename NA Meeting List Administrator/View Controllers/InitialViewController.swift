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
import LocalAuthentication

/* ###################################################################################################################################### */
// MARK: - Initial View Controller Class -
/* ###################################################################################################################################### */
/**
 This class is the first controller to appear when the app starts.
 
 It's job is to handle all of the connection and login stuff. Nothing else in the app can be done until it has passed this stage.
 
 Once the user has successfully logged in, the Navigation Controller will bring in the main tabbed interface.
 
 This View Controller starts off with a URL text entry, and a simple connect button.
 
 Once the user has sucessfully connected, they are presented with a login screen that may include a TouchID button.
 */
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
    /** This is the TouchID "thumbprint" button. */
    @IBOutlet weak var touchIDButton: UIButton!
    
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
        self.navigationItem.title = NSLocalizedString(self.navigationItem.title!, comment: "")
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
        self.connectButton.setTitle(NSLocalizedString(self.connectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.disconnectButton.setTitle(NSLocalizedString(self.disconnectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        
        let lastLogin = AppStaticPrefs.prefs.lastLogin
        
        if !lastLogin.url.isEmpty && !lastLogin.loginID.isEmpty {
            self.enterURLTextItem.text = lastLogin.url
        } else {
            self.enterURLTextItem.text = AppStaticPrefs.prefs.rootURI
        }
        
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
        self.closeKeyboard()
        self.navigationController?.isNavigationBarHidden = true;
        self._loggingIn = false
        self.passwordTextField.text = "" // We start off with no password (security).
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
        self.showOrHideTouchIDButton()
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
        self.closeKeyboard()
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
        self.closeKeyboard()
        self._connecting = false
        self._loggingIn = false
        MainAppDelegate.connectionStatus = false
    }
    
    /* ################################################################## */
    /**
     Called when the "LOG IN" button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func loginButtonHit(_ sender: UIButton) {
        self.closeKeyboard()
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
        self.closeKeyboard()
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminAvailable {
            if MainAppDelegate.connectionObject.adminLogout() {
                self.animationMask.isHidden = true
                self._loggingIn = false
                self.view.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the TouchID button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func touchIDButtonHit(_ sender: UIButton) {
        self.closeKeyboard()
        let authenticationContext = LAContext()
        authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("LOCAL-TOUCHID-REASON", comment: ""), reply: self.touchIDCallback )
    }
    
    /* ################################################################## */
    /**
     Called when the Settings button is hit.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func settingsButtonHit(_ sender: UIButton) {
        self.closeKeyboard()
    }
    
    /* ################################################################## */
    /**
     Called when the background is tapped. This closes any open text keyboards.
     
     - parameter sender: The IB item that called this. This is ignored.
     */
    @IBAction func tappedInBackground(_ sender: UITapGestureRecognizer) {
        self.closeKeyboard()
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Closes any open keyboard.
     */
    func closeKeyboard() {
        self.loginIDTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.enterURLTextItem.resignFirstResponder()
    }
    
    /* ################################################################## */
    /**
     This is the callback from the TouchID login attempt.
     
     - parameter inSuccess: If true, then the TouchID was successful.
     - parameter inError: Any error that may have occurred.
     */
    func touchIDCallback(_ inSuccess: Bool, inError: Error?) {
        DispatchQueue.main.async(execute: {
            if(!inSuccess) {
                var description: String! = nil
                
                if let temp = inError?.localizedDescription {
                    description = temp
                }
                
                if (nil == description) || (description?.isEmpty)! {
                    description = "UNABLE-TO-LOGIN-ERROR"
                }
                
                MainAppDelegate.displayAlert("UNABLE-TO-LOGIN-ERROR-TITLE", inMessage: description!)
            } else {
                self.passwordTextField.text = AppStaticPrefs.prefs.getStoredPasswordForUser(self.enterURLTextItem.text!, inUser: self.loginIDTextField.text!)
                if !(self.passwordTextField.text?.isEmpty)! {
                    self.loginButtonHit(self.loginButton)
                } else {
                    MainAppDelegate.displayAlert("UNABLE-TO-LOGIN-ERROR-TITLE", inMessage: "UNABLE-TO-LOGIN-ERROR")
                }
            }
        })
    }

    /* ################################################################## */
    /**
     Starts the connecting animation
     */
    func startConnection() {
        self.closeKeyboard()
        self.loginIDTextField.text = ""
        self.passwordTextField.text = ""
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
        
        // Belt and suspenders. Let's be sure.
        self.loginIDTextField.text = ""
        self.passwordTextField.text = ""

        if self._connecting && (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus {
            let lastLogin = AppStaticPrefs.prefs.lastLogin
            
            if !lastLogin.url.isEmpty && !lastLogin.loginID.isEmpty && (lastLogin.url == self.enterURLTextItem.text) {
                self.loginIDTextField.text = lastLogin.loginID
            }
        }

        self._loggingIn = false
        self._connecting = false
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation.
     */
    func finishedLoggingIn() {
        // If we are successfully logged in, then we save the login and (maybe) the password.
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminLoggedIn {
            AppStaticPrefs.prefs.updateUserForRootURI(self.enterURLTextItem.text!, inUser: self.loginIDTextField.text!, inPassword: self.passwordTextField.text)
            AppStaticPrefs.prefs.lastLogin = (url: self.enterURLTextItem.text!, loginID: self.loginIDTextField.text!)
        }
        self.passwordTextField.text = ""
        self.animationMask.isHidden = true
        self._loggingIn = false
        self._connecting = false
        self.view.setNeedsLayout()
    }
    
    /* ################################################################## */
    /**
     This function will either show (enable) or hide (disable) the login button (and maybe the TouchID button).
     */
    func showOrHideLoginButton() {
        let loginIDFieldIsEmpty = self.loginIDTextField.text?.isEmpty
        let passwordFieldIsEmpty = self.passwordTextField.text?.isEmpty
        let hideLoginButton = loginIDFieldIsEmpty! || passwordFieldIsEmpty!
        
        self.touchIDButton.isHidden = hideLoginButton || !AppStaticPrefs.supportsTouchID
        self.loginButton.isEnabled = !hideLoginButton
    }
    
    /* ################################################################## */
    /**
     This function will either show or hide the TouchID button.
     */
    func showOrHideTouchIDButton() {
        let showTouchIDButton = AppStaticPrefs.prefs.userHasStoredPasswordRootURI(self.enterURLTextItem.text!, inUser: self.loginIDTextField.text!)
        
        self.touchIDButton.isHidden = !showTouchIDButton
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
        self.showOrHideTouchIDButton()
    }
}

