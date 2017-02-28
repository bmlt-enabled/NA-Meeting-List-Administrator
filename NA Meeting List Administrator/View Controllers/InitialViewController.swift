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
import BMLTiOSLib

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
class InitialViewController: EditorViewControllerBaseClass, UITextFieldDelegate {
    /* ################################################################## */
    // MARK: Private Instance Constant Properties
    /* ################################################################## */
    /** This is the ID for the segue we use to bring in the editor. */
    private let _showEditorSegueID = "bring-in-editor"
    /** This is the ID for the Service body selector segue */
    private let _showServiceBodyESelectorSeueID = "select-service-bodies"
    /** This is the segue that brings in the Settings screen. */
    private let _showSettingsSegueID = "show-settings-screen"
    
    /* ################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################## */
    /** This is set to true while we are in the process of logging in. */
    private var _loggingIn: Bool = false
    /** This is set to true while we are in the process of connecting. */
    private var _connecting: Bool = false
    /** This is the Tab Bar Controller for the editors (it will be nil if we are not in the editor). */
    private var _editorTabBarController: EditorTabBarController! = nil
    
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
    /** This is the bar button that brings in the Service Body Selector screen. */
    @IBOutlet weak var serviceBodyBarButton: UIBarButtonItem!
    /** This is the bar button item that brings in the main Editor screen. */
    @IBOutlet weak var editorBarButton: UIBarButtonItem!
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        MainAppDelegate.appDelegateObject.initialViewController = self  // This allows the app delegate to easily find us.
        // Set all of the various localized text items.
        // Each item has the key set as its text, so we replace with the localized version.
        self.navigationItem.backBarButtonItem?.title = NSLocalizedString((self.navigationItem.backBarButtonItem?.title!)!, comment: "")
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
        self.serviceBodyBarButton.title = NSLocalizedString(self.serviceBodyBarButton.title!, comment: "")
        self.editorBarButton.title = NSLocalizedString(self.editorBarButton.title!, comment: "")

        let lastLogin = AppStaticPrefs.prefs.lastLogin
        
        // If there is no saved login from the last connection, we use the somewhat more static one (or the default from the plist).
        if !lastLogin.url.isEmpty && !lastLogin.loginID.isEmpty {
            self.enterURLTextItem.text = lastLogin.url.cleanURI(sslRequired: true)
        } else {
            self.enterURLTextItem.text = AppStaticPrefs.prefs.rootURI
        }
        
        self._loggingIn = false
        self.setLoginStatusUI()
    }
    
    /* ################################################################## */
    /**
     We simply use this to make sure our NavBar is hidden if necessary.
     
     Simplify, simplify, simplify.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.closeKeyboard()
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = !((nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionObject.isAdminLoggedIn)
        }
        self._editorTabBarController = nil // We will always be setting this to nil when we first appear. Makes it easier to track.
        self._loggingIn = false
        self.passwordTextField.text = "" // We start off with no password (security).
        self.enableOrDisableTheEditButton()
        
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     This allows us to track the editor tab controller object.
     
     - parameter for: The segue object being called.
     - parameter sender: Any data we crammed into the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if type(of: segue.destination) == EditorTabBarController.self {
            self._editorTabBarController = segue.destination as! EditorTabBarController
        }
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
                self.setLoginStatusUI()
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
                self.setLoginStatusUI()
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
        let userName = self.loginIDTextField.text!
        let reason = String(format: NSLocalizedString("LOCAL-TOUCHID-REASON-FORMAT", comment: ""), userName)
        authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: self.touchIDCallback )
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
    /**
     Brings in the editor.
     
     By the time the editor is called, we are logged in, and have at least one Service body selected.
     
     - parameter sender: The IB item that called this. This is ignored.
     */
    @IBAction func sendInTheClowns(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self._showEditorSegueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Brings in the Service body selector.
     
     - parameter sender: The IB item that called this. This is ignored.
     */
    @IBAction func selectYourClowns(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self._showServiceBodyESelectorSeueID, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Brings in the Settings screen.
     
     - parameter sender: The IB item that called this. This is ignored.
     */
    @IBAction func showSettings(_ sender: UIButton) {
        self.performSegue(withIdentifier: self._showSettingsSegueID, sender: nil)
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
                if LAError.Code.userCancel.rawValue != (inError as! NSError).code {   // We ignore user canceled error.
                    if LAError.Code.userFallback.rawValue == (inError as! NSError).code {   // Fallback means that we will use the password, so we nuke the stored password.
                        let _ = AppStaticPrefs.prefs.updateUserForRootURI(self.enterURLTextItem.text!, inUser: self.loginIDTextField.text!)
                        self.touchIDButton.isHidden = true
                        // Wow. This is one hell of a kludge, but it works.
                        // There's a "feature" in iOS, where the TouchID callback is triggered out of sync with the main queue (slightly before the next run cycle, I guess).
                        // If we immediately set the field as first responder in this callback, then it gets selected, but the keyboard doesn't come up.
                        // This 'orrible, 'orrible hack tells iOS to select the field after the handler for this TouchID has had time to wrap up.
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(10)) { self.passwordTextField.becomeFirstResponder() }
                    } else {
                        var description: String! = nil
                        if let temp = inError?.localizedDescription {
                            description = temp
                        }
                        
                        if (nil == description) || (description?.isEmpty)! {
                            description = "UNABLE-TO-LOGIN-ERROR"
                        }
                        
                        MainAppDelegate.displayAlert("UNABLE-TO-LOGIN-ERROR-TITLE", inMessage: description!)
                    }
                }
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
        self.setLoginStatusUI()
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
        self.setLoginStatusUI()
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation.
     */
    func finishedLoggingIn() {
        var firstTime = false
        
        // If we are successfully logged in, then we save the login and (maybe) the password.
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminLoggedIn {
            firstTime = AppStaticPrefs.prefs.updateUserForRootURI(self.enterURLTextItem.text!, inUser: self.loginIDTextField.text!, inPassword: self.passwordTextField.text)
            AppStaticPrefs.prefs.lastLogin = (url: self.enterURLTextItem.text!, loginID: self.loginIDTextField.text!)
            
            if firstTime {  // If this was the first time we logged in, then we set all our Service bodies to selected.
                AppStaticPrefs.prefs.setServiceBodySelection(serviceBodyObject: nil, selected: true)
            }
            AppStaticPrefs.prefs.savePrefs()
        }
        
        self.passwordTextField.text = ""
        self.animationMask.isHidden = true
        self._loggingIn = false
        self._connecting = false
        self.setLoginStatusUI()
        
        // The first time we log in with a user, and we have multiple Service bodies, we allow them to choose their Service bodies first.
        if firstTime && (1 < AppStaticPrefs.prefs.allEditableServiceBodies.count){
            self.selectYourClowns(self.serviceBodyBarButton)
        } else {    // Otherwise, we just go straight to the editor; whether or not we are at the first go.
            self.sendInTheClowns(self.editorBarButton)
        }
    }
    
    /* ################################################################## */
    /**
     This function will either show (enable) or hide (disable) the login button (and maybe the TouchID button).
     */
    func showOrHideLoginButton() {
        let loginIDFieldIsEmpty = self.loginIDTextField.text?.isEmpty
        let passwordFieldIsEmpty = self.passwordTextField.text?.isEmpty
        let hideLoginButton = loginIDFieldIsEmpty! || passwordFieldIsEmpty!
        
        self.loginButton.isEnabled = !hideLoginButton
    }
    
    /* ################################################################## */
    /**
     This function will enable or disable the Navbar Edit button, depending on whether or not we have any selected Service bodies.
     */
    func enableOrDisableTheEditButton() {
        self.editorBarButton.isEnabled = 0 < AppStaticPrefs.prefs.selectedServiceBodies.count
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
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = true
        }
        
        // If we are not currently attempting a connection, and are currently connected.
        if !self._connecting && (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus {
            self.urlEntryItemsContainerView.isHidden = true
            if MainAppDelegate.connectionObject.isAdminLoggedIn {   // If we are logged in as an admin.
                self.logoutButton.isHidden = false
                self.adminUnavailableLabel.isHidden = true
                self.loginItemsContainer.isHidden = true
                if let navController = self.navigationController {
                    navController.isNavigationBarHidden = false
                }
                
                self.serviceBodyBarButton.isEnabled = (1 < MainAppDelegate.connectionObject.serviceBodiesICanEdit.count)
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
        self.enableOrDisableTheEditButton()
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects:[BMLTiOSLibMeetingNode]) {
        self._editorTabBarController.updateSearch(inMeetingObjects: inMeetingObjects)   // We pass this on to our Tab controller, who will take it from there.
    }
    
    /* ################################################################## */
    /**
     This is called when the library returns change updates.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateChangeResponse(changeListResults: [BMLTiOSLibChangeNode]) {
        self._editorTabBarController.updateChangeResponse(changeListResults: changeListResults)   // We pass this on to our Tab controller, who will take it from there.
    }
    
    /* ################################################################## */
    /**
     This is called when the library returns change updates for deleted meetings.
     
     - parameter changeListResults: An array of change objects.
     */
    func updateDeletedResponse(changeListResults: [BMLTiOSLibChangeNode]) {
        self._editorTabBarController.updateDeletedResponse(changeListResults: changeListResults)   // We pass this on to our Tab controller, who will take it from there.
    }
    
    /* ################################################################## */
    // MARK: UITextFieldDelegate Methods
    /* ################################################################## */
    /**
     This function responds to the return button being hit.
     Each text field has a different response.
     
     - parameter textField: The text field being edited.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.enterURLTextItem == textField {
            self.connectButtonHit(self.connectButton)   // Simple connect for this one.
        } else {
            // We have to have both fields filled before we can log in, so if they aren't both filled, we go to the empty one next.
            if self.loginIDTextField == textField {
                if !(self.passwordTextField.text?.isEmpty)! {   // If the password field is empty, we go to that.
                    self.loginButtonHit(self.loginButton)
                } else {    // If not, we try the login.
                    self.passwordTextField.becomeFirstResponder()
                }
            } else {
                if self.passwordTextField == textField {
                    if !(self.loginIDTextField.text?.isEmpty)! {    // If the login field is empty, we go to that.
                        self.loginButtonHit(self.loginButton)
                    } else {    // Otherwise, let's try logging in.
                        self.loginIDTextField.becomeFirstResponder()
                    }
                }
            }
        }
        return true
    }
}

