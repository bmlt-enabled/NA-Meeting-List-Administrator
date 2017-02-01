//
//  AppStaticPrefs.swift
//  BMLT NA Meeting Search
//
//  Created by MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BMLT is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import LocalAuthentication
import Security

/* ###################################################################################################################################### */
// MARK: - Prefs Class -
/* ###################################################################################################################################### */
/**
 This is a very simple "persistent user prefs" class. It is instantiated as a SINGLETON, and provides a simple, property-oriented gateway
 to the simple persistent user prefs in iOS. It shouldn't be used for really big, important prefs, but is ideal for the basic "settings"
 type of prefs most users set in their "gear" screen.
 */
class AppStaticPrefs {
    /** This is a simple typealias for a login pair. */
    typealias LoginPairTuple = (url: String, loginID: String)
    
    /* ################################################################## */
    // MARK: Private Static Properties
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "NAMeetingListAdministratorAppStaticPrefs"
    
    /* ################################################################## */
    // MARK: Private Variable Properties
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: AppStaticPrefs! = nil
    
    /* ################################################################## */
    // MARK: Private Enums
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This is the Root Server URI */
        case RootServerURI = "BMLTRootServerURI"
        /** This is the plist key for the default (initial) URI. */
        case DefaultRootServerURIPlistKey = "BMLTDefaultRootServerURI"
        /** This is the key for the stored URI/login sets. */
        case RootServerLoginDictionaryKey = "BMLTStoredLoginIDs"
        /** This is the key for the last login value pair. */
        case LastLoginPair = "BMLTLastLoginPair"
    }
    
    /* ################################################################## */
    // MARK: Private Initializer
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init(){/* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */}

    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
            self._loadedPrefs = NSMutableDictionary(dictionary: temp)
        } else {
            self._loadedPrefs = NSMutableDictionary()
        }
        
        return nil != self._loadedPrefs
    }
    
    /* ################################################################## */
    // MARK: Class Static Properties
    /* ################################################################## */
    /**
     This is how the singleton instance is instantiated and accessed. Always use this variable to capture the prefs object.
     
     The syntax is:
     
         let myPrefs = AppStaticPrefs.prefs
     */
    static var prefs: AppStaticPrefs {
        get {
            if nil == self._sSingletonPrefs {
                self._sSingletonPrefs = AppStaticPrefs()
            }
            
            return self._sSingletonPrefs
        }
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     */
    static var using12hClockFormat: Bool {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let dateString = formatter.string(from: Date())
            let amRange = dateString.range(of: formatter.amSymbol)
            let pmRange = dateString.range(of: formatter.pmSymbol)
            
            return !(pmRange == nil && amRange == nil)
        }
    }
    
    /* ################################################################## */
    /**
     This is a simple test to see if the device supports TouchID.
     
     - returns: true, if the device supports TouchID.
     */
    static var supportsTouchID: Bool {
        get {
            var ret: Bool = false
            var error: NSError? = nil
            
            let authenticationContext = LAContext()
            
            ret = authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
            
            if(nil != error) {  // Very basic. Any problems, no can do.
                ret = false
            }
            
            return ret
        }
    }

    /* ################################################################## */
    // MARK: Instance Static Methods
    /* ################################################################## */
    /**
     Gets a localized version of the weekday name from an index.
     
     Cribbed from Here: http://stackoverflow.com/questions/7330420/how-do-i-get-the-name-of-a-day-of-the-week-in-the-users-locale#answer-34289913
     
     - parameter weekdayNumber: 1-based index (1 - 7)
     
     - returns: The localized, full-length weekday name.
     */
    class func weekdayNameFromWeekdayNumber(_ weekdayNumber: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        let weekdayIndex = weekdayNumber - 1
        let index = weekdayIndex + firstWeekday
        return weekdaySymbols[index]
    }
    
    /* ################################################################## */
    // MARK: Instance Properties
    /* ################################################################## */
    /** This is a keychain simplifier. */
    private let _keychainWrapper:FXKeychain! = FXKeychain.default()

    /* ################################################################## */
    // MARK: Instance Calculated Properties
    /* ################################################################## */
    /**
     This is the current Root Server URI. If there is no previous URI, then the default URI is read from the plist file.
     - returns: the selected Root Server URI, as a String.
     */
    var rootURI: String {
        get {
            var ret: String = ""
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerURI.rawValue) as? String {
                    ret = temp
                }
            }
            
            if ret.isEmpty {
                // Get the default URI, if all else fails.
                if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
                    if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                        if let uri = plistDictionary[type(of: self).PrefsKeys.DefaultRootServerURIPlistKey.rawValue] as? NSString {
                            ret = uri as String
                        }
                    }
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                if newValue.isEmpty {
                    self._loadedPrefs.removeObject(forKey: PrefsKeys.RootServerURI.rawValue)
                } else {
                    self._loadedPrefs.setObject(newValue, forKey: PrefsKeys.RootServerURI.rawValue as NSString)
                }
                self._savePrefs()
            }
        }
    }
    
    var lastLogin: LoginPairTuple {
        get {
            var ret: LoginPairTuple = (url: "", loginID: "")
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.LastLoginPair.rawValue) as? [String] {
                    if 2 == temp.count {
                        ret = (url: temp[0], loginID: temp[1])
                    }
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                if newValue.url.isEmpty {
                    self._loadedPrefs.removeObject(forKey: PrefsKeys.LastLoginPair.rawValue)
                } else {
                    let ret: [String] = [newValue.url, newValue.loginID]
                    self._loadedPrefs.setObject(ret, forKey: PrefsKeys.LastLoginPair.rawValue as NSString)
                }
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     */
    func getUsersForRootURI(_ inRooutURI: String) -> [String]! {
        var ret: [String]! = nil
        
        if self._loadPrefs() {
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                ret = temp[inRooutURI]
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This method allows us to add a login ID and password to be saved.
     The login ID is keyed to the URL, so you could have the same login for different servers.
     The password is only saved if we support TouchID.
     If the password is nil or blank, then the login is stored, but the password is removed from the keychain.
     
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: The User login ID, as a String
     - parameter inPassword: An optional string for the password. If nil or empty, then the password is removed. Default is nil.
     */
    func updateUserForRootURI(_ inRooutURI: String, inUser: String, inPassword: String! = nil) {
        if self._loadPrefs() {
            // In this first step, we add the user to our list for that URI, if necessary.
            var loginDictionary: [String:[String]] = [:]
            var needToUpdate: Bool = true
            var urlUsers: [String] = []
            
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                loginDictionary = temp
            }
            
            // We may not need to add the user (Maybe we're just changing the stored password).
            if var users = loginDictionary[inRooutURI] {
                urlUsers = users
                for i in 0..<users.count {
                    if users[i] == inUser {
                        needToUpdate = false    // If we already know about this login, we don't need to update.
                        break
                    }
                }
            }
            
            if needToUpdate {
                urlUsers.append(inUser)
                loginDictionary[inRooutURI] = urlUsers
                
                self._loadedPrefs.setObject(loginDictionary, forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue as NSString)
                
                self._savePrefs()
            }
            
            // At this point, we have the login ID saved in the dictionary.
            // Now, if we support TouchID, we will also save the password in the keychain.
            
            let key = inRooutURI + "-" + inUser   // This will be our unique key for the password.

            self._keychainWrapper.removeObject(forKey: key)  // We start by clearing the deck, then re-add, if necessary.

            // We only store the password if we support TouchID, and we aren't deleting it.
            if type(of: self).supportsTouchID && (nil != inPassword) && !inPassword.isEmpty {
                self._keychainWrapper.setObject(inPassword, forKey: key) // Store the password in our keychain.
            }
        }
    }
    
    /* ################################################################## */
    /**
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: An optional string for the login ID. If nil or empty, then all users for the URI are removed. Default is nil.
     */
    func removeUserForRootURI(_ inRooutURI: String, inUser: String! = nil) {
        if self._loadPrefs() {
            var loginDictionary: [String:[String]] = [:]
            var urlUsers: [String] = []
            
            if (nil != inUser) && !inUser.isEmpty {
                self.updateUserForRootURI(inRooutURI, inUser: inUser)   // Clear any stored password, first.
                
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                    loginDictionary = temp
                }
                
                // We remove the user if we find them.
                if var users = loginDictionary[inRooutURI] {
                    for i in 0..<users.count {
                        if users[i] == inUser {
                            users.remove(at: i)
                            break
                        }
                    }
                    urlUsers = users
                }
            } else {
                // If there was no user specified, then we are to remove all users from this URI.
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                    loginDictionary = temp
                    // If we have a dictionary, then we'll be removing all stored passwords for that URI.
                    if var users = loginDictionary[inRooutURI] {
                        for i in 0..<users.count {
                            self.updateUserForRootURI(inRooutURI, inUser: users[i])
                        }
                    }
                }
            }
            
            // If this was the last user, we delete the whole URI.
            if urlUsers.isEmpty {
                loginDictionary.removeValue(forKey: inRooutURI)
            } else {
                loginDictionary[inRooutURI] = urlUsers
            }
            
            self._loadedPrefs.setObject(loginDictionary, forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue as NSString)
            
            self._savePrefs()
        }
    }
    
    /* ################################################################## */
    /**
     Quick test to see if this user is stored for the given URL.
     
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: A String for the login ID.
     
     - returns: true, if the user exists for this URI.
     */
    func userExistsForRootURI(_ inRooutURI: String, inUser: String) -> Bool {
        var ret: Bool = false
        
        if self._loadPrefs() {
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                if var users = temp[inRooutURI] {
                    for i in 0..<users.count {
                        if users[i] == inUser {
                            ret = true
                            break
                        }
                    }
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Quick test to see if this user has a stored password for the given URL.
     
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: A String for the login ID.
     
     - returns: true, if the user exists for this URI, and has a password stored.
     */
    func userHasStoredPasswordRootURI(_ inRooutURI: String, inUser: String) -> Bool {
        var ret: Bool = false
        
        if self._loadPrefs() {
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                if var users = temp[inRooutURI] {
                    for i in 0..<users.count {
                        if users[i] == inUser {
                            let key = inRooutURI + "-" + inUser   // This will be our unique key for the password.
                            
                            ret = nil != self._keychainWrapper.object(forKey: key)
                            break
                        }
                    }
                }
            }
        }
        
        return ret
    }
}
