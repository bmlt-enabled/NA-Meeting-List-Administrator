//  MainAppDelegate.swift
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

@UIApplicationMain
/* ###################################################################################################################################### */
// MARK: - Main App Delegate Class -
/* ###################################################################################################################################### */
class MainAppDelegate: UIResponder, UIApplicationDelegate, BMLTiOSLibDelegate {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /**
     This will contain our connected (or connectING) BMLTiOSLib instance. It will be nil if there is no connection.
     */
    private static var _libraryObject: BMLTiOSLib! = nil
    
    /* ################################################################## */
    // MARK: Static Calculated Properties
    /* ################################################################## */
    /**
     This is a quick way to get this object instance (it's a SINGLETON), cast as the correct class.
     */
    static var appDelegateObject: MainAppDelegate {
        get { return UIApplication.shared.delegate as! MainAppDelegate }
    }
    
    /* ################################################################## */
    /**
     This will return nil, unless we have a completed connecteion, in which case it will return the valid connected library.
     */
    static var connectionObject: BMLTiOSLib! {
        get { return self.appDelegateObject.validConnection ? self._libraryObject : nil }
    }
    
    /* ################################################################## */
    /**
     This will initiate a new connection if set to true. If set to false, it will terminate the session.
     Setting this value will always terminate any current sessions.
     
     If this value is true, it does not necessarily mean that we have a valid session; only that we have an object.
     
     You should check the instance value validConnection for that.
     */
    static var connectionStatus: Bool {
        get {
            return nil != self._libraryObject
        }
        
        set {
            if !newValue && (nil != self._libraryObject) {
                self._libraryObject = nil
                self.appDelegateObject.validConnection = false
                self.appDelegateObject.initialViewController.finishedConnecting()
            } else {
                if newValue {
                    self.appDelegateObject.initialViewController.startConnection()
                    if let url = self.appDelegateObject.initialViewController.enterURLTextItem.text {
                        self._libraryObject = BMLTiOSLib(inRootServerURI: url, inDelegate: self.appDelegateObject)
                    }
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     - parameter presentedBy: An optional UIViewController object that is acting as the presenter context for the alert. If nil, we use the top controller of the Navigation stack.
     */
    class func displayAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController! = nil ) {
        var presentedBy = inPresentingViewController
        
        if nil == presentedBy {
            presentedBy = (self.appDelegateObject.window?.rootViewController as! UINavigationController).topViewController
        }
        
        if nil != presentedBy {
            let alertController = UIAlertController(title: NSLocalizedString(inTitle, comment: ""), message: NSLocalizedString(inMessage, comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("NAMeetingListAdministrator-OKButtonText", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            DispatchQueue.main.async {
                presentedBy?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Private Instance Stored Properties
    /* ################################################################## */
    /**
     This is the container for our full meeting search.
     */
    private var _fullArrayOfMeetingObjects: [BMLTiOSLibMeetingNode] = []
    /**
     This is used to determine whether or not we force a disconnect.
     */
    private var _lastTimeIWasAlive: TimeInterval = 0
    
    /* ################################################################## */
    // MARK: Internal Instance Stored Properties
    /* ################################################################## */
    /**
     This is the app main window object.
     */
    var window: UIWindow?
    
    /** This is set to true if we have a valid connection (the connection process has completed). */
    var validConnection: Bool = false
    
    /** This stores the main connection view controller reference. */
    var initialViewController: InitialViewController! = nil
    
    /* ################################################################## */
    // MARK: Instance Calculated Properties
    /* ################################################################## */
    /**
     Accessor for the stored meeting objects.
     */
    var meetingObjects: [BMLTiOSLibMeetingNode] {
        get {
            return self._fullArrayOfMeetingObjects
        }
        
        set {
            self._fullArrayOfMeetingObjects = newValue
        }
    }
    
    /* ################################################################## */
    // MARK: UIApplicationDelegate Methods
    /* ################################################################## */
    /**
     Called when the app is about to start. It politely asks for permission.
     
     - parameter application: The application object.
     - parameter didFinishLaunchingWithOptions: The various launch options
     
     - returns true (all the time). This tells the app to go ahead and launch.
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to come into its own.
     
     - parameter application: The application object.
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let navController = self.initialViewController.navigationController {
            let elapsedTime = Date().timeIntervalSinceReferenceDate - self._lastTimeIWasAlive
            
            if elapsedTime > AppStaticPrefs.prefs.timeoutInterval {
                type(of: self).connectionStatus = false // Force a disconnect for waiting too long.
                _ = navController.popToRootViewController(animated: false)
            }
            
            // Oh, God (facepalm). We need to do this vicious hack because the damn disconnection can cause the navbar to be hidden.
            if let topView = navController.topViewController as? SettingsViewController {
                topView.view.setNeedsLayout()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to resign the active state.
     
     - parameter application: The application object.
     */
    func applicationWillResignActive(_ application: UIApplication) {
        AppStaticPrefs.prefs.savePrefs()
        self._lastTimeIWasAlive = Date.timeIntervalSinceReferenceDate
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to run down the curtain and shuffle off this mortal coil.
     
     - parameter application: The application object.
     */
    func applicationWillTerminate(_ application: UIApplication) {
        AppStaticPrefs.prefs.savePrefs()
        type(of: self).connectionStatus = false // Force an immediate disconnect when terminating.
    }
    
    /* ################################################################## */
    /**
     Called when the app is about to go into background mode.
     
     - parameter application: The application object.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        AppStaticPrefs.prefs.savePrefs()
        self._lastTimeIWasAlive = Date.timeIntervalSinceReferenceDate
    }
    
    /* ################################################################## */
    // MARK: BMLTiOSLibDelegate Methods
    /* ################################################################## */
    /**
     This is a required delegate callback. It is called when the server connection is completed (or disconnected).
     
     - parameter inLibInstance: The library object (in our case, it should always be the same as type(of: self)._libraryObject).
     - parameter serverIsValid: If this is true, then the connection is valid (and complete). If false, the library object is about to become invalid.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        self.validConnection = serverIsValid
        
        if !self.validConnection {
            type(of: self)._libraryObject = nil
        }
        
        self.initialViewController.finishedConnecting()
    }
    
    /* ################################################################## */
    /**
     This is a required callback that is executed if the connection suffers an error.

     - parameter inLibInstance: The library object (in our case, it should always be the same as type(of: self)._libraryObject).
     - parameter errorOccurred: This is the error object that was sent.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error) {
        // If we had an error while trying to connect, then this is a bad server.
        if !self.validConnection {  // We quietly take an asp to our bosom.
            type(of: self)._libraryObject = nil
            self.initialViewController.finishedConnecting() // Kill any connection in progress.
            type(of: self).displayAlert("NAMeetingListAdministrator-ErrorAlertTitle", inMessage: "BAD-URI-ERROR-TEXT")
        } else {
            // Otherwise, we raise a ruckus.
            let description = error.localizedDescription
            type(of: self).displayAlert("NAMeetingListAdministrator-ErrorAlertTitle", inMessage: description)
        }
    }
    
    /* ################################################################## */
    /**
     Indicates whether or not a Semantic Admin log in or out occurred.
     
     This actually is called when the login state changes (or doesn't change when change is expected).
     This is called in response to a login or logout. It is always called, even if
     the login state did not change.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter loginChangedTo: A Bool, true, if the session is currently connected.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, loginChangedTo: Bool) {
        if loginChangedTo && (1 > type(of: self)._libraryObject.serviceBodiesICanEdit.count) {  // We have to be able to edit at least one Service body for this to work.
            let _ = type(of: self)._libraryObject.adminLogout()
        }
        
        self.initialViewController.finishedLoggingIn()
    }
    
    /* ################################################################## */
    /**
     Response to a meeting search.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of meeting objects.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode]) {
        self._fullArrayOfMeetingObjects = meetingSearchResults
        self.initialViewController.updateSearch(inMeetingObjects: self.meetingObjects)
    }
    
    /* ################################################################## */
    /**
     Called when a new meeting has been deleted.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter deleteMeetingSuccessful: true, if the operation was successful.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, deleteMeetingSuccessful: Bool) {
        if deleteMeetingSuccessful {
            self.initialViewController.updateDeletedMeeting()
        }
    }
    
    /* ################################################################## */
    /**
     Called when a new meeting has been added, or a deleted meeting has been restored.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter newMeetingAdded: Meeting object.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, newMeetingAdded: BMLTiOSLibEditableMeetingNode) {
        self.initialViewController.updateEdit(newMeetingAdded)
    }
    
    /* ################################################################## */
    /**
     Called when a meeting has been edited.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter adminMeetingChangeComplete: If successful, this will be the changes made to the meeting. nil, if failed.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, adminMeetingChangeComplete: BMLTiOSLibChangedMeeting!) {
        if nil != adminMeetingChangeComplete {
            self.initialViewController.updateEdit(nil)
        }
    }

    /* ################################################################## */
    /**
     Called when a meeting has been rolled back to a previous version.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingRolledback: Meeting object.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingRolledback: BMLTiOSLibEditableMeetingNode) {
        self.initialViewController.updateRollback(meetingRolledback)
    }
    
    /* ################################################################## */
    /**
     Returns the result of a change list request.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter changeListResults: An array of change objects.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, changeListResults: [BMLTiOSLibChangeNode]) {
        self.initialViewController.updateChangeFetch()
    }
    
    /* ################################################################## */
    /**
     Returns the result of a change list request for deleted meetings.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter deletedChangeListResults: An array of change objects.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, deletedChangeListResults: [BMLTiOSLibChangeNode]) {
        self.initialViewController.updateDeletedResponse(changeListResults: deletedChangeListResults)
    }
}

