//  SettingsViewController.swift
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
// MARK: - Settings View Controller Class -
/* ###################################################################################################################################### */
/**
 */
class SettingsViewController: UIViewController {
    /* ################################################################## */
    // MARK: IB Properties
    /* ################################################################## */
    @IBOutlet weak var clearAllLoginsButton: UIButton!
    @IBOutlet weak var blurbHeaderLabel: UILabel!
    @IBOutlet weak var appNameLabel: UILabel!
    /** This displays the version. */
    @IBOutlet weak var versionLabel: UILabel!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** This is the URI that is executed when someone hits the "Beanie Button." */
    var buttonURI: String = ""

    /* ################################################################## */
    /**
     Called when the view has been initially loaded.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appName = ""
        var appVersion = ""
        
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let appNameTemp = plistDictionary["CFBundleName"] as? NSString {
                    appName = appNameTemp as String
                }
                
                if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                    appVersion = versionTemp as String
                }
                
                if let version2Temp = plistDictionary["CFBundleVersion"] as? NSString {
                    appVersion += "." + (version2Temp as String)
                }
                
                if let buttonURI = plistDictionary["BMLTButtonURL"] as? NSString {
                    self.buttonURI = buttonURI as String
                }
            }
        }
        
        self.appNameLabel.text = appName
        
        self.versionLabel.text = String(format: NSLocalizedString("VERSION-LABEL-FORMAT", comment: ""), appVersion)
        
        self.blurbHeaderLabel.text = NSLocalizedString(self.blurbHeaderLabel.text!, comment: "")
        
        self.clearAllLoginsButton.setTitle(NSLocalizedString(self.clearAllLoginsButton.title(for: UIControlState.normal)!, comment: ""), for: UIControlState.normal)
        
        self.clearAllLoginsButton.isEnabled = AppStaticPrefs.prefs.hasStoredLogins
    }
    
    /* ################################################################## */
    /**
     We use this to make sure our navbar is displayed. This can be called before we are logged in.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let navController = self.navigationController {
            navController.isNavigationBarHidden = false
        }
    }
    
    /* ################################################################## */
    /**
     Called when the Beanie is banged.
     
     - parameter sender: The button that called this.
     */
    @IBAction func beanieButtonHit(_ sender: Any) {
        if !self.buttonURI.isEmpty {
            let openLink = NSURL(string: self.buttonURI)
            UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
            self.view.setNeedsLayout()
        }
    }
  
    /* ################################################################## */
    /**
     Called to clear all the stored logins and URLs.
     
     - parameter sender: The button that called this.
     */
    @IBAction func clearAllLogins(_ sender: UIButton) {
        var message = NSLocalizedString("FORGET-STORED-LOGINS-MESSAGE", comment: "")
        
        if nil != MainAppDelegate.connectionObject {
            message += NSLocalizedString("FORGET-STORED-LOGINS-MESSAGE-SUFFIX", comment: "")
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("FORGET-STORED-LOGINS-HEADER", comment: ""), message: message, preferredStyle: .alert)
        
        let saveCopyAction = UIAlertAction(title: NSLocalizedString("FORGET-STORED-LOGINS-OK-BUTTON", comment: ""), style: UIAlertActionStyle.destructive, handler: self.terminateWithExtremePrejudice)
        
        alertController.addAction(saveCopyAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("FORGET-STORED-LOGINS-CANCEL-BUTTON", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Called if the user wants to delete the saved logins and URLs.
     
     - parameter inAction: The alert action object (ignored)
     */
    func terminateWithExtremePrejudice(_ inAction: UIAlertAction) {
        MainAppDelegate.connectionStatus = false
        MainAppDelegate.appDelegateObject.initialViewController.enterURLTextItem.text = ""
        AppStaticPrefs.prefs.deleteSavedLoginsAndURLs()
        self.clearAllLoginsButton.isEnabled = false
        // We need to do this, because the initial view controller may close its navigation bar, which is also ours.
        self.view.setNeedsLayout()
    }
}
