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
    // MARK: Normal Stored Properties
    /* ################################################################## */
    /**
     This is the app main window object.
     */
    var window: UIWindow?
    
    /** This is set to true if we have a valid connection (the connection process has completed). */
    var validConnection: Bool = false
    
    /* ################################################################## */
    /**
     */
    static func toggleConnectStatus() {
        if nil != self._libraryObject {
            self._libraryObject = nil
        } else {
            self._libraryObject = BMLTiOSLib(inRootServerURI: AppStaticPrefs.prefs.rootURI, inDelegate: self.appDelegateObject)
        }
    }
    
    /* ################################################################## */
    // MARK: UIApplicationDelegate Methods
    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    /* ################################################################## */
    // MARK: BMLTiOSLibDelegate Methods
    /* ################################################################## */
    /**
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        self.validConnection = serverIsValid
        
        if !self.validConnection {
            type(of: self)._libraryObject = nil
        }
    }
    
    /* ################################################################## */
    /**
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error) {
        // If we had an error while trying to connect, then this is a bad server.
        if !self.validConnection {  // We quietly take an asp to our bosom.
            type(of: self)._libraryObject = nil
        } else {
            // Otherwise, we raise a ruckus.
        }
    }
}

