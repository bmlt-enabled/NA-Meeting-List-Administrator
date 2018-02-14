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
 
 Its job is to handle all of the connection and login stuff. Nothing else in the app can be done until it has passed this stage.
 
 Once the user has successfully logged in, the Navigation Controller will bring in the main tabbed interface.
 
 This View Controller starts off with a URL text entry, and a simple connect button.
 
 Once the user has sucessfully connected, they are presented with a login screen that may include a TouchID button.
 */
class InitialViewController: EditorViewControllerBaseClass, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    /* ################################################################## */
    // MARK: Private Instance Constant Properties
    /* ################################################################## */
    /** This is the ID for the segue we use to bring in the editor. */
    private let _showEditorSegueID = "bring-in-editor"
    /** This is the ID for the Service body selector segue */
    private let _showServiceBodySelectorSegueID = "select-service-bodies"
    /** This is the segue that brings in the Settings screen. */
    private let _showSettingsSegueID = "show-settings-screen"
    /** This is the height of the UIPickerView. */
    private let _pickerViewRowHeight: CGFloat = 30
    
    /* ################################################################## */
    // MARK: Private Instance Properties
    /* ################################################################## */
    /** This is set to true while we are in the process of logging in. */
    private var _loggingIn: Bool = false
    /** This is set to true while we are in the process of connecting. */
    private var _connecting: Bool = false
    /** This is the last login user ID */
    private var _userID: String = ""
    /** This is the last login password */
    private var _password: String = ""
    /** This is the Tab Bar Controller for the editors (it will be nil if we are not in the editor). */
    private var _editorTabBarController: EditorTabBarController! = nil
    /** This is the URL we will be accessing. */
    private var _url: String = ""
    /** This will be the string we use to describe the biometric type. */
    private var _bioType = "TOUCH-ID-STRING".localizedVariant
    
    /* ################################################################## */
    // MARK: Instance IB Properties
    /* ################################################################## */
    /** The mask view with the spinning throbber. */
    @IBOutlet weak var animationMask: UIView!
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
    /** This is the bar button that brings in the Service Body Selector screen. */
    @IBOutlet weak var serviceBodyBarButton: UIBarButtonItem!
    /** This is the bar button item that brings in the main Editor screen. */
    @IBOutlet weak var editorBarButton: UIBarButtonItem!
    /** This is the Picker View that is displayed if we have preset logins available. */
    @IBOutlet weak var presetLoginsPickerView: UIPickerView!
    /** This is the container view for the preset login items. */
    @IBOutlet weak var presetLoginsContainerView: UIView!
    /** This is the internal container view for the preselected logins (Manual Entry). */
    @IBOutlet weak var loginItemsSelectorContainerView: UIView!
    /** This is the ID label for the manual entry. */
    @IBOutlet weak var manualEntryIDLabel: UILabel!
    /** This is the ID Entry Text Field */
    @IBOutlet weak var manualEntryIDTextField: UITextField!
    /** This is the label for the manual entry password. */
    @IBOutlet weak var manualEntryPasswordLabel: UILabel!
    /** This is the text field for the manual entry password. */
    @IBOutlet weak var manualEntryPasswordTextField: UITextField!
    /** This is the button used to initiate a mnaual login. */
    @IBOutlet weak var manualEntryLoginButton: UIButton!
    
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
        self.logoutButton.setTitle(NSLocalizedString(self.logoutButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.adminUnavailableLabel.text = self.adminUnavailableLabel.text!.localizedVariant
        self.enterURLItemsLabel.text = self.enterURLItemsLabel.text!.localizedVariant
        self.enterURLTextItem.placeholder = self.enterURLTextItem.placeholder!.localizedVariant
        self.connectButton.setTitle(NSLocalizedString(self.connectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.disconnectButton.setTitle(NSLocalizedString(self.disconnectButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        self.serviceBodyBarButton.title = self.serviceBodyBarButton.title!.localizedVariant
        self.editorBarButton.title = self.editorBarButton.title!.localizedVariant
        self.manualEntryIDLabel.text = self.manualEntryIDLabel.text!.localizedVariant
        self.manualEntryIDTextField.placeholder = self.manualEntryIDTextField.placeholder!.localizedVariant
        self.manualEntryPasswordLabel.text = self.manualEntryPasswordLabel.text!.localizedVariant
        self.manualEntryPasswordTextField.placeholder = self.manualEntryPasswordTextField.placeholder!.localizedVariant
        self.manualEntryLoginButton.setTitle(NSLocalizedString(self.manualEntryLoginButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)

        var url = AppStaticPrefs.prefs.rootURI
        
        if !url.isEmpty {
            url = url.cleanURI(sslRequired: true)
        }
        
        self._url = url
        self.enterURLTextItem.text = self._url
        
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
        self.manualEntryPasswordTextField.text = "" // We start off with no password (security).
        self.enableOrDisableTheEditButton()
        self.showOrHideConnectButton()
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
            self._editorTabBarController = segue.destination as? EditorTabBarController
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
        self._url = sender.text!
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
            let row = self.presetLoginsPickerView.selectedRow(inComponent: 0)
            let goBio = (0 < row)
            
            if goBio {
                let authenticationContext = LAContext()
                let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)
                self._userID = storedLogins[row - 1]
                if !self._userID.isEmpty {
                    self._password = ""
                    let reason = String(format: "LOCAL-TOUCHID-REASON-FORMAT".localizedVariant, self._userID)
                    authenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: self.biometricCallback )
                }
            } else {
                self._userID = self.manualEntryIDTextField.text!
                self._password = self.manualEntryPasswordTextField.text!
                if !self._userID.isEmpty && !self._password.isEmpty {
                    if MainAppDelegate.connectionObject.adminLogin(loginID: self._userID, password: self._password) {
                        self.animationMask.isHidden = false
                        self._loggingIn = true
                        self.setLoginStatusUI()
                    }
                }
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
                self.animationMask.isHidden = false
                self._loggingIn = false
                self.setLoginStatusUI()
            }
        }
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
        self.performSegue(withIdentifier: self._showServiceBodySelectorSegueID, sender: nil)
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
        self.manualEntryIDTextField.resignFirstResponder()
        self.manualEntryPasswordTextField.resignFirstResponder()
        self.enterURLTextItem.resignFirstResponder()
    }
    
    /* ################################################################## */
    /**
     This is the callback from the TouchID/FaceID login attempt.
     
     - parameter inSuccess: If true, then the ID attempt was successful.
     - parameter inError: Any error that may have occurred.
     */
    func biometricCallback(_ inSuccess: Bool, inError: Error?) {
        if !inSuccess {
            let userCancelRaw = LAError.Code.userCancel.rawValue
            let systemCancelRaw = LAError.Code.systemCancel.rawValue
            let userPasswordRaw = LAError.Code.userFallback.rawValue
            print(userPasswordRaw)
            var errorCode = userCancelRaw   // We always err on the side of caution.
            if let errorAsNSError = inError as NSError? {
                #if DEBUG
                    print(errorAsNSError)
                #endif
                
                errorCode = errorAsNSError.code
            }
            
            if (userCancelRaw != errorCode) && (systemCancelRaw != errorCode) {   // We ignore user/system canceled error.
                if LAError.Code.userFallback.rawValue == (inError! as NSError).code {   // Fallback means that we will use the password, so we nuke the stored password.
                    // Wow. This is one hell of a kludge, but it works.
                    // There's a "feature" in iOS, where the TouchID callback is triggered out of sync with the main queue (slightly before the next run cycle, I guess).
                    // If we immediately set the field as first responder in this callback, then it gets selected, but the keyboard doesn't come up.
                    // This 'orrible, 'orrible hack tells iOS to select the field after the handler for this TouchID has had time to wrap up.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(10)) {
                        var login_text = ""
                        let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)
                        let row = self.presetLoginsPickerView.selectedRow(inComponent: 0)
                        if 0 < row {
                            login_text = storedLogins[row - 1]
                        }
                        _ = AppStaticPrefs.prefs.updateUserForRootURI(self.enterURLTextItem.text!, inUser: login_text)
                        self.presetLoginsPickerView.selectRow(0, inComponent: 0, animated: true)
                        self.manualEntryIDTextField.text = login_text
                        self.manualEntryPasswordTextField.text = ""
                        self.manualEntryLoginButton.isEnabled = false
                        self.loginItemsSelectorContainerView.isHidden = false
                        self.manualEntryPasswordTextField.becomeFirstResponder()
                    }
                } else {
                    var header: String = "UNABLE-TO-LOGIN-ERROR-TITLE-FORMAT".localizedVariant
                    var description: String! = nil
                    
                    if let temp = inError?.localizedDescription {
                        description = temp
                    }
                    
                    if (nil == description) || (description?.isEmpty)! {
                        description = "UNABLE-TO-LOGIN-ERROR-FORMAT".localizedVariant
                    }
                    
                    header = String(format: header, self._bioType)
                    description = String(format: description, self._bioType)

                    MainAppDelegate.displayAlert(header, inMessage: description!)
                }
            }
        } else {
            DispatchQueue.main.async {
                let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)
                let row = self.presetLoginsPickerView.selectedRow(inComponent: 0)
                var loginID = ""
                var password = ""
                loginID = storedLogins[row - 1]
                password = AppStaticPrefs.prefs.getStoredPasswordForUser(self.enterURLTextItem.text!, inUser: loginID)

                if !loginID.isEmpty && !password.isEmpty {
                    if MainAppDelegate.connectionObject.adminLogin(loginID: loginID, password: password) {
                        self.animationMask.isHidden = false
                        self._loggingIn = true
                        self.setLoginStatusUI()
                    }
                } else {
                    var header: String = "UNABLE-TO-LOGIN-ERROR-TITLE-FORMAT".localizedVariant
                    var description = "UNABLE-TO-LOGIN-ERROR-FORMAT".localizedVariant
                    
                    header = String(format: header, self._bioType)
                    description = String(format: description, self._bioType)

                    MainAppDelegate.displayAlert(header, inMessage: description)
                }
            }
        }
    }

    /* ################################################################## */
    /**
     Starts the connecting animation
     */
    func startConnection() {
        self.closeKeyboard()
        self.manualEntryIDTextField.text = ""
        self.manualEntryPasswordTextField.text = ""
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
        self.manualEntryIDTextField.text = ""
        self.manualEntryPasswordTextField.text = ""

        if self._connecting && (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus {
            let lastLogin = AppStaticPrefs.prefs.lastLogin
            
            if !lastLogin.url.isEmpty && !lastLogin.loginID.isEmpty && (lastLogin.url == self.enterURLTextItem.text) {
                self.manualEntryIDTextField.text = lastLogin.loginID
            }
        }

        self._loggingIn = false
        self._connecting = false
        self.setLoginStatusUI()
    }
    
    /* ################################################################## */
    /**
     Stops the connecting animation and sends you to the correct destination.
     */
    func finishedLoggingIn() {
        var firstTime = true
        
        // If we are successfully logged in, then we save the login and (maybe) the password.
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionStatus && MainAppDelegate.connectionObject.isAdminLoggedIn {
            firstTime = AppStaticPrefs.prefs.updateUserForRootURI(self.enterURLTextItem.text!, inUser: self._userID, inPassword: self._password)
            AppStaticPrefs.prefs.lastLogin = (url: self.enterURLTextItem.text!, loginID: self.manualEntryIDTextField.text!)
            
            if firstTime {  // If this was the first time we logged in, then we set all our Service bodies to selected.
                AppStaticPrefs.prefs.setServiceBodySelection(serviceBodyObject: nil, selected: true)
            }
            AppStaticPrefs.prefs.savePrefs()
        }
        
        self.manualEntryPasswordTextField.text = ""
        self.animationMask.isHidden = true
        self._loggingIn = false
        self._connecting = false
        self.setLoginStatusUI()
        
        // The first time we log in with a user, and we have multiple Service bodies, we allow them to choose their Service bodies first.
        if firstTime && MainAppDelegate.connectionObject.isAdminLoggedIn && (1 < AppStaticPrefs.prefs.allEditableServiceBodies.count) {
            self.selectYourClowns(self.serviceBodyBarButton)
        } else {    // Otherwise, we just go straight to the editor; whether or not we are at the first go.
            if MainAppDelegate.connectionObject.isAdminLoggedIn {
                self.sendInTheClowns(self.editorBarButton)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This function will either show (enable) or hide (disable) the login button (and maybe the TouchID button).
     */
    func showOrHideLoginButton() {
        let row = self.presetLoginsPickerView.selectedRow(inComponent: 0)
        let loginFieldEmpty = self.manualEntryIDTextField.text?.isEmpty
        let passwordFieldEmpty = self.manualEntryPasswordTextField.text?.isEmpty

        let hideLoginButton = loginFieldEmpty! || passwordFieldEmpty!
        
        self.manualEntryLoginButton.isEnabled = !hideLoginButton || (0 < row)
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
            self.presetLoginsContainerView.isHidden = false
            // We load up any previously stored logins (Touch/Face ID).
            if MainAppDelegate.connectionObject.isAdminLoggedIn {   // If we are logged in as an admin.
                self.presetLoginsContainerView.isHidden = true
                self.logoutButton.isHidden = false
                self.adminUnavailableLabel.isHidden = true
                if let navController = self.navigationController {
                    navController.isNavigationBarHidden = false
                }
                
                self.serviceBodyBarButton.isEnabled = (1 < MainAppDelegate.connectionObject.serviceBodiesICanEdit.count)
            } else {
                self.logoutButton.isHidden = true
                let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)
                self.presetLoginsPickerView.reloadAllComponents()   // This displays them all.

                if MainAppDelegate.connectionObject.isAdminAvailable {
                    self.adminUnavailableLabel.isHidden = true

                    // If we have Touch/Face ID available, AND we have previously stored logins, then we present those as alternatives in the picker.
                    if AppStaticPrefs.supportsTouchID && !storedLogins.isEmpty {
                        self.presetLoginsContainerView.isHidden = false
                        let lastLogin = AppStaticPrefs.prefs.lastLogin
                        
                        // Here, we scroll to the last one selected.
                        if !lastLogin.url.isEmpty && !lastLogin.loginID.isEmpty && (lastLogin.url == self.enterURLTextItem.text) {
                            var index = 1
                            
                            for login in storedLogins {
                                if lastLogin.loginID == login {
                                    self.presetLoginsPickerView.selectRow(index, inComponent: 0, animated: true)
                                    self.pickerView(self.presetLoginsPickerView, didSelectRow: index, inComponent: 0)
                                    break
                                }
                                
                                index += 1
                            }
                        }
                    } else {
                        self.presetLoginsPickerView.selectRow(0, inComponent: 0, animated: true)
                        self.pickerView(self.presetLoginsPickerView, didSelectRow: 0, inComponent: 0)
                    }
                } else {
                    self.adminUnavailableLabel.isHidden = false
                }
            }
        } else {
            self.urlEntryItemsContainerView.isHidden = false
            self.adminUnavailableLabel.isHidden = true
            self.presetLoginsContainerView.isHidden = true
        }
        
        self.showOrHideConnectButton()
        self.showOrHideLoginButton()
        self.enableOrDisableTheEditButton()
    }
    
    /* ################################################################## */
    /**
     This is called when the search updates.
     
     - parameter inMeetingObjects: An array of meeting objects.
     */
    func updateSearch(inMeetingObjects: [BMLTiOSLibMeetingNode]) {
        self._editorTabBarController.updateSearch(inMeetingObjects: inMeetingObjects)   // We pass this on to our Tab controller, who will take it from there.
    }

    /* ################################################################## */
    /**
     This is called when a new meeting has been added.
     
     - parameter inMeetingObject: The new meeting object.
     */
    func updateNewMeeting(inMeetingObject: BMLTiOSLibEditableMeetingNode) {
        self._editorTabBarController.updateNewMeetingAdded(inMeetingObject)   // We pass this on to our Tab controller, who will take it from there.
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
    /**
     This is called when a meeting rollback is complete.
     
     - parameter inMeeting: The meeting that was updated.
     */
    func updateRollback(_ inMeeting: BMLTiOSLibMeetingNode) {
        self._editorTabBarController.updateRollback(inMeeting)
    }
    
    /* ################################################################## */
    /**
     This is called when a meeting edit or add is complete.
     
     - parameter inMeeting: The meeting that was edited or added. nil, if we want a general update.
     */
    func updateEdit(_ inMeeting: BMLTiOSLibMeetingNode!) {
        self._editorTabBarController.updateEdit(inMeeting)
    }

    /* ################################################################## */
    /**
     This is called when a change fetch is complete.
     */
    func updateChangeFetch() {
        self._editorTabBarController.updateChangeFetch()
    }
    
    /* ################################################################## */
    /**
     This is called after we successfully delete a meeting.
     We use this as a trigger to tell the deleted meetings tab it needs a reload.
     */
    func updateDeletedMeeting() {
        self._editorTabBarController.updateDeletedMeeting()
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
        if (self.enterURLTextItem == textField) && !(textField.text?.isEmpty)! {
            self.connectButtonHit(self.connectButton)   // Simple connect for this one.
        } else {
            // We have to have both fields filled before we can log in, so if they aren't both filled, we go to the empty one next.
            if self.manualEntryIDTextField == textField {
                // If the password field has a value, and we have a value, then let's try logging in.
                if !(textField.text?.isEmpty)! && !(self.manualEntryPasswordTextField.text?.isEmpty)! {
                    self.loginButtonHit(self.manualEntryLoginButton)
                } else {
                    self.manualEntryPasswordTextField.becomeFirstResponder()
                }
            } else {
                if self.manualEntryPasswordTextField == textField {
                    // If the ID field has a value, and we have a value, then let's try logging in.
                    if !(textField.text?.isEmpty)! && !(self.manualEntryIDTextField.text?.isEmpty)! {
                        self.loginButtonHit(self.manualEntryLoginButton)
                    } else {
                        self.manualEntryIDTextField.becomeFirstResponder()
                    }
                }
            }
        }
        return true
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDelegate Methods
    /* ################################################################## */
    /**
     Get the number of components in the picker (always 1).
     
     - parameter in: The UIPickerView object.
     
     - returns: The number of comonents (always 1).
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     Get the height of the rows in the picker.
     
     - parameter _: The UIPickerView object.
     - parameter rowHeightForComponent: The 0-based index of the component.
     
     - returns: The height of the rows for the given component.
     */
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return self._pickerViewRowHeight
    }
    
    /* ################################################################## */
    /**
     Get a new view object for the given row.
     
     - parameter _: The UIPickerView object.
     - parameter viewForRow: The 0-based row index.
     - parameter component: The 0-based index of the component.
     - parameter reusing: If there is a view to be reused, it is provided here.
     
     - returns: A new view object for the given row.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var viewBounds = pickerView.bounds
        viewBounds.size.height = self.pickerView(pickerView, rowHeightForComponent: component)
        let label = UILabel(frame: viewBounds)
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = self.enterURLItemsLabel.textColor
        let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)

        if 0 == row {
            label.text = "MANUAL-LOGIN".localizedVariant
        } else {
            label.text = storedLogins[row - 1]
        }
        return label
    }
    
    /* ################################################################## */
    /**
     Called when a row is selected.
     
     - parameter _: The UIPickerView object.
     - parameter didSelectRow: The 0-based row index.
     - parameter inComponent: The 0-based index of the component.
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.closeKeyboard()
        if 0 == row {
            self.manualEntryIDTextField.text! = ""
            self.manualEntryPasswordTextField.text! = ""
            self.loginItemsSelectorContainerView.isHidden = false
            self.manualEntryIDTextField.becomeFirstResponder()
        } else {
            self.loginItemsSelectorContainerView.isHidden = true
        }
        
        self.showOrHideLoginButton()
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDataSource Methods
    /* ################################################################## */
    /**
     Get how many rows the picker will display.
     
     - parameter _: The UIPickerView object.
     - parameter numberOfRowsInComponent: The 0-based index of the component.
     
     - returns: The number of rows to be displayed.
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var ret: Int = 1
        
        if nil != MainAppDelegate.connectionObject {
            let storedLogins = AppStaticPrefs.prefs.getStoredLogins(for: self.enterURLTextItem.text!)
            ret += storedLogins.count
        }
        
        return ret
    }
    
}
