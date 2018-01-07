//  AppStaticPrefs.swift
//  BMLT NA Meeting Search
//
//  Created by MAGSHARE
//
//  Copyright 2017 MAGSHARE
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
import BMLTiOSLib
import FXKeychain

/* ###################################################################################################################################### */
// MARK: - Class Extensions -
/* ###################################################################################################################################### */
/**
 This adds various functionality to the String class.
 */
extension String {
    /* ################################################################## */
    /**
     This makes it easy to use localized strings.
     */
    var localizedVariant: String {
        return NSLocalizedString(self, comment: "")
    }

    /* ################################################################## */
    /**
     This tests a string to see if a given substring is present at the start.
     
     - parameter inSubstring: The substring to test.
     
     - returns: true, if the string begins with the given substring.
     */
    func beginsWith (_ inSubstring: String) -> Bool {
        var ret: Bool = false
        if let range = self.range(of: inSubstring) {
            ret = (range.lowerBound == self.startIndex)
        }
        return ret
    }
    
    /* ################################################################## */
    /**
     The following function comes from this: http://stackoverflow.com/a/27736118/879365
     
     This extension function cleans up a URI string.
     
     - returns: a string, cleaned for URI.
     */
    func URLEncodedString() -> String? {
        let customAllowedSet =  CharacterSet.urlQueryAllowed
        if let ret = self.addingPercentEncoding(withAllowedCharacters: customAllowedSet) {
            return ret
        } else {
            return ""
        }
    }
    
    /* ################################################################## */
    /**
     The following function comes from this: http://stackoverflow.com/a/27736118/879365
     
     This extension function creates a URI query string from given parameters.
     
     - parameter parameters: a dictionary containing query parameters and their values.
     
     - returns: a String, with the parameter list.
     */
    static func queryStringFromParameters(_ parameters: [String: String]) -> String? {
        if parameters.isEmpty {
            return nil
        }
        
        var queryString: String? = nil
        for (key, value) in parameters {
            if let encodedKey = key.URLEncodedString() {
                if let encodedValue = value.URLEncodedString() {
                    if queryString == nil {
                        queryString = "?"
                    } else {
                        queryString! += "&"
                    }
                    
                    queryString! += encodedKey + "=" + encodedValue
                }
            }
        }
        
        return queryString
    }
    
    /* ################################################################## */
    /**
     "Cleans" a URI
     
     - returns: an implicitly unwrapped optional String. This is the given URI, "cleaned up."
     "http[s]://" may be prefixed.
     */
    func cleanURI() -> String! {
        return self.cleanURI(sslRequired: true)
    }
    
    /* ################################################################## */
    /**
     "Cleans" a URI, allowing SSL requirement to be specified.
     
     - parameter sslRequired: If true, then we insist on SSL.
     
     - returns: an implicitly unwrapped optional String. This is the given URI, "cleaned up."
     "http[s]://" may be prefixed.
     */
    func cleanURI(sslRequired: Bool) -> String! {
        var ret: String! = self.URLEncodedString()
        
        // Very kludgy way of checking for an HTTPS URI.
        let wasHTTP: Bool = ret.lowercased().beginsWith("http://")
        let wasHTTPS: Bool = ret.lowercased().beginsWith("https://")
        
        // Yeah, this is pathetic, but it's quick, simple, and works a charm.
        ret = ret.replacingOccurrences(of: "^http[s]{0,1}://", with: "", options: NSString.CompareOptions.regularExpression)
        
        if wasHTTPS || (sslRequired && !wasHTTP && !wasHTTPS) {
            ret = "https://" + ret
        } else {
            ret = "http://" + ret
        }
        
        return ret
    }
}

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
    /** This is used to track whether or not we have a selected Service body. */
    typealias SelectableServiceBodyTuple = (serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode?, selected: Bool)
    
    /* ################################################################## */
    // MARK: Private Static Properties
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "NAMeetingListAdministratorAppStaticPrefs"
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: AppStaticPrefs! = nil
    
    /* ################################################################## */
    // MARK: Private Constant Properties
    /* ################################################################## */
    /** This is the default "slop" around a meeting for the "Where AmI?" search. This will be subtracted from the start time, and added to the end time. */
    private let _defaultGracePeriodInMinutes: Int = 15
    
    /* ################################################################## */
    // MARK: Private Variable Properties
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    /** This tracks our selected Service bodies. */
    private var _selectedServiceBodies: [SelectableServiceBodyTuple] = []
    
    /* ################################################################## */
    // MARK: Private Enums
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This is the plist key for the default (initial) URI. */
        case DefaultRootServerURIPlistKey = "BMLTDefaultRootServerURI"
        /** This is the key for the stored URI/login sets. */
        case RootServerLoginDictionaryKey = "BMLTStoredLoginIDs"
        /** This is the key for the last login value pair. */
        case LastLoginPair = "BMLTLastLoginPair"
        /** This will refer to an array of Int that will indicate selected Service body IDs. */
        case SelectedServiceBodies = "BMLTSelectedServiceBodies"
        /** This represents how long we allow a meeting to be in progress before we remove it from our list of candidates. */
        case GracePeriod = "gracePeriod"
    }
    
    /* ################################################################## */
    // MARK: Private Initializer
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init() {/* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */}

    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if nil == self._loadedPrefs {
            if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
                self._loadedPrefs = NSMutableDictionary(dictionary: temp)
            } else {
                self._loadedPrefs = NSMutableDictionary()
            }
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
     
     - returns the current prefs object.
     */
    static var prefs: AppStaticPrefs {
        if nil == self._sSingletonPrefs {
            self._sSingletonPrefs = AppStaticPrefs()
        }
        
        return self._sSingletonPrefs
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     
     - returns: True, if the device is set for Ante Meridian (AM/PM) time.
     */
    static var using12hClockFormat: Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        
        return !(pmRange == nil && amRange == nil)
    }
    
    /* ################################################################## */
    /**
     - returns: An integer, with the 1-based index of the first day of the week.
     */
    static var firstWeekdayIndex: Int {
        return Calendar.current.firstWeekday
    }
    
    /* ################################################################## */
    /**
     This is a simple test to see if the device supports TouchID.
     
     - returns: true, if the device supports TouchID.
     */
    static var supportsTouchID: Bool {
        var ret: Bool = false
        var error: NSError? = nil
        
        let authenticationContext = LAContext()

        ret = authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if nil != error {  // Very basic. Any problems, no can do.
            ret = false
        }
        
        return ret
    }

    /* ################################################################## */
    // MARK: Instance Static Methods
    /* ################################################################## */
    /**
     Gets a localized version of the weekday name from an index.
     
     Cribbed from Here: http://stackoverflow.com/questions/7330420/how-do-i-get-the-name-of-a-day-of-the-week-in-the-users-locale#answer-34289913
     
     - parameter weekdayNumber: 1-based index (1 - 7)
     - parameter isShort: Optional. If true, then the shortened version of the name will be returned. Default is false.
     
     - returns: The localized, full-length weekday name.
     */
    class func weekdayNameFromWeekdayNumber(_ weekdayNumber: Int, isShort: Bool = false) -> String {
        if (0 < weekdayNumber) && (8 > weekdayNumber) {
            let calendar = Calendar.current
            let weekdaySymbols = isShort ? calendar.shortWeekdaySymbols : calendar.weekdaySymbols
            let firstWeekday = self.firstWeekdayIndex - 1
            let weekdayIndex = weekdayNumber - 1
            var index = weekdayIndex + firstWeekday
            if 6 < index {
                index -= 7
            }
            return weekdaySymbols[index]
        } else {
            return NSLocalizedString("ERR-STRING-SHORT", comment: "")
        }
    }
    
    /* ################################################################## */
    // MARK: Instance Properties
    /* ################################################################## */
    /** This is a keychain simplifier. */
    private let _keychainWrapper: FXKeychain! = FXKeychain.default()

    /* ################################################################## */
    // MARK: Instance Calculated Properties
    /* ################################################################## */
    /**
     This is the current Root Server URI. If there is no previous URI, then the default URI is read from the plist file.
     - returns: the selected Root Server URI, as a String.
     */
    var rootURI: String {
        var ret: String = ""
        
        if self._loadPrefs() {
            ret = self.lastLogin.url    // First thing we try is the URL used the last time.
        }
        
        if ret.isEmpty {
            // Get the default URI, if all else fails.
            if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
                if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                    if let uri = plistDictionary[type(of: self).PrefsKeys.DefaultRootServerURIPlistKey.rawValue] as? NSString {
                        ret = !(uri as String).isEmpty ? (uri as String).cleanURI() : ""
                    }
                }
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Currently hardcoded at ten seconds.
     
     - returns the number of seconds we wait before forcefully logging out.
     */
    var timeoutInterval: TimeInterval {
        return 10.0
    }
    
    /* ################################################################## */
    /**
     Saves or returns the last successful login.
     
     - returns the last successful login, for quick restoration later.
     */
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
                    let ret: [String] = [newValue.url.cleanURI(), newValue.loginID]
                    self._loadedPrefs.setObject(ret, forKey: PrefsKeys.LastLoginPair.rawValue as NSString)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns all the Service bodies available.
     */
    var allEditableServiceBodies: [BMLTiOSLibHierarchicalServiceBodyNode] {
        var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        
        if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionObject.isConnected && MainAppDelegate.connectionObject.isAdminLoggedIn {
            ret = MainAppDelegate.connectionObject.serviceBodiesICanEdit
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - returns an array of Service body objects, corresponding to the ones selected by the user.
     
     We associate the selections with a URL/login pair (the last successful one), so this can change from login to login.
     */
    var selectedServiceBodies: [BMLTiOSLibHierarchicalServiceBodyNode] {
        var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
        let loginSet = self.lastLogin
        let key = loginSet.url.cleanURI() + "-" + loginSet.loginID
        
        if self._loadPrefs() {
            if 1 == self.allEditableServiceBodies.count {   // If we only have one body, then it is always selected, and can't be deselected.
                ret = [self.allEditableServiceBodies[0]]
            } else {
                var newDictionary: [String: [Int]] = [:]
                
                if self._loadPrefs() {
                    if let temp = self._loadedPrefs.object(forKey: PrefsKeys.SelectedServiceBodies.rawValue) as? [String: [Int]] {
                        newDictionary = temp
                    }
                    
                    let oldArray: [Int] = (nil != newDictionary[key]) ? newDictionary[key]! as [Int] : []
                    
                    if 0 < oldArray.count {
                        for sb in self.allEditableServiceBodies {
                            if oldArray.contains(sb.id) {
                                ret.append(sb)
                            }
                        }
                    }
                }
            }
        }

        return ret
    }
    
    /* ################################################################## */
    /**
     - returns: the "grace period" we give meetings ("slop" for the "Where Am I?" search).
     */
    var gracePeriodInMinutes: Int {
        return self._defaultGracePeriodInMinutes
    }
    
    /* ################################################################## */
    /**
     - returns true, if we currently have stored logins.
     */
    var hasStoredLogins: Bool {
        if self._loadPrefs() {
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                return !temp.isEmpty
            }
        }
        
        return false
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Returns a list of login IDs for the given Root Server URI.
     
     - parameter inRootURI: The URL (as a String) for the Root Server
     
     - returns an Array of String, with each element being a login stored for that Root Server URI.
     */
    func getUsersForRootURI(_ inRooutURI: String) -> [String]! {
        var ret: [String]! = nil
        
        if self._loadPrefs() {
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                ret = temp[inRooutURI.cleanURI()]
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    func savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    /* ################################################################## */
    /**
     This method is called to delete the saved URLs and logins (but not other saved prefs).
     */
    func deleteSavedLoginsAndURLs() {
        if self._loadPrefs() {
            if type(of: self).supportsTouchID {
                // All of this crap is to remove the keys we have stored in the keychain.
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                    let keys = temp.keys
                    for key in keys {
                        if let users = temp[key] {
                            for user in users {
                                let keychainKey = key.cleanURI() + "-" + user
                                self._keychainWrapper.removeObject(forKey: keychainKey)
                            }
                        }
                    }
                }
            }
            
            // Finally, we remove the list of URLs and logins.
            self._loadedPrefs.removeObject(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue as NSString)

            self.lastLogin = (url: "", loginID: "")
            
            self.savePrefs()
            
            self._loadedPrefs = nil // Force a reload of the prefs.
        }
    }
    
    /* ################################################################## */
    /**
     This updates our stored selection state for the given Service body.
     
     - parameter serviceBodyObject: The Service body object that is being selected or deselected. If nil, then the selection is applied to all available Service bodies.
     - parameter selected: True, if the Service body object is being selected.
     */
    func setServiceBodySelection(serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode!, selected: Bool) {
        if self._loadPrefs() {
            let loginSet = self.lastLogin
            let key = loginSet.url.cleanURI() + "-" + loginSet.loginID
            
            var newDictionary: [String: [Int]] = [:]
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.SelectedServiceBodies.rawValue) as? [String: [Int]] {
                    newDictionary = temp
                }

                let oldArray: [Int] = (nil != newDictionary[key]) ? newDictionary[key]! as [Int] : []
                var newArray: [Int] = []
                
                let inputID = (nil != serviceBodyObject) ? serviceBodyObject!.id : 0
                
                if (1 == self.allEditableServiceBodies.count) && (0 < inputID) { // If we only have one available Service body, then we ignore the selected flag, and force a selection.
                    newArray = [inputID]
                } else {    // If we have more than one, then we can choose to select or deselect bodies.
                    if selected && (0 < inputID) {
                        newArray.append(inputID)
                    }
                    
                    if nil == serviceBodyObject {   // If we had nil passed in, then we are either setting or clearing all IDs.
                        if selected {   // If setting, we set every ID. If clearing, we simply fall through.
                            for sb in self.allEditableServiceBodies {
                                let sbID = sb.id
                                newArray.append(sbID)
                            }
                        }
                    } else {
                        // We simply copy over the state of all the other
                        for sbID in oldArray where sbID != inputID {
                            newArray.append(sbID)
                        }
                    }
                }
                
                // Now, save the new values out to the prefs.
                if newArray.isEmpty {
                    newDictionary.removeValue(forKey: key)
                } else {
                    newDictionary.updateValue(newArray, forKey: key)
                }
                
                if newDictionary.isEmpty {
                    self._loadedPrefs.removeObject(forKey: PrefsKeys.SelectedServiceBodies.rawValue)
                } else {
                    self._loadedPrefs.setObject(newDictionary, forKey: PrefsKeys.SelectedServiceBodies.rawValue as NSString)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This returns the selection state for the given Service body.
     
     - parameter serviceBodyObject: The Service body object that is being selected or deselected.
     - returns: True, if the Service body object is currently selected. If we only have one editable Service body, then it is always selected.
     */
    func serviceBodyIsSelected(_ serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode) -> Bool {
        for sb in self.selectedServiceBodies where sb.id == serviceBodyObject.id {
            return true
        }
        return false
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
     
     - returns: True, if this was the first login for this user.
     */
    func updateUserForRootURI(_ inRooutURI: String, inUser: String, inPassword: String! = nil) -> Bool {
        var ret: Bool = false
        
        if self._loadPrefs() {
            // In this first step, we add the user to our list for that URI, if necessary.
            var loginDictionary: [String: [String]] = [:]
            var needToUpdate: Bool = true
            var urlUsers: [String] = []
            
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                loginDictionary = temp
            }
            
            // We may not need to add the user (Maybe we're just changing the stored password).
            if var users = loginDictionary[inRooutURI] {
                urlUsers = users
                for i in 0..<users.count where users[i] == inUser {
                    needToUpdate = false    // If we already know about this login, we don't need to update.
                    break
                }
            }
            
            if needToUpdate {
                urlUsers.append(inUser)
                loginDictionary[inRooutURI] = urlUsers
                ret = true  // If we need to update, then this was the first login.
                
                self._loadedPrefs.setObject(loginDictionary, forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue as NSString)
                self.setServiceBodySelection(serviceBodyObject: nil, selected: true)    // First time through, the user always has everything turned on.
            }
            
            // At this point, we have the login ID saved in the dictionary.
            // Now, if we support TouchID, we will also save the password in the keychain.
            
            let key = inRooutURI.cleanURI() + "-" + inUser   // This will be our unique key for the password.

            self._keychainWrapper.removeObject(forKey: key)  // We start by clearing the deck, then re-add, if necessary.

            // We only store the password if we support TouchID, and we aren't deleting it.
            if type(of: self).supportsTouchID && (nil != inPassword) && !inPassword.isEmpty {
                self._keychainWrapper.setObject(inPassword, forKey: key) // Store the password in our keychain.
            }
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Removes the stored user and login from this URL.
     
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: An optional string for the login ID. If nil or empty, then all users for the URI are removed. Default is nil.
     */
    func removeUserForRootURI(_ inRooutURI: String, inUser: String! = nil) {
        if self._loadPrefs() {
            var loginDictionary: [String: [String]] = [:]
            var urlUsers: [String] = []
            
            if (nil != inUser) && !inUser.isEmpty {
                _ = self.updateUserForRootURI(inRooutURI, inUser: inUser)   // Clear any stored password, first.
                
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                    loginDictionary = temp
                }
                
                // We remove the user if we find them.
                if var users = loginDictionary[inRooutURI] {
                    for i in 0..<users.count where users[i] == inUser {
                        users.remove(at: i)
                        break
                    }
                    urlUsers = users
                }
            } else {
                // If there was no user specified, then we are to remove all users from this URI.
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                    loginDictionary = temp
                    // If we have a dictionary, then we'll be removing all stored passwords for that URI.
                    if var users = loginDictionary[inRooutURI] {
                        for i in 0..<users.count {
                            _ = self.updateUserForRootURI(inRooutURI, inUser: users[i])
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
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                if var users = temp[inRooutURI] {
                    for i in 0..<users.count where users[i] == inUser {
                        ret = true
                        break
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
        
        let key = inRooutURI.cleanURI() + "-" + inUser   // This will be our unique key for the password.
        
        if type(of: self).supportsTouchID && (nil != self._keychainWrapper) { // No TouchID, no stored password.
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String: [String]] {
                    if var users = temp[inRooutURI] {
                        for i in 0..<users.count where users[i] == inUser {
                            ret = (nil != self._keychainWrapper.object(forKey: key))
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
     Fetch the user's stored password after thumbprint ID.
     
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: A String for the login ID.
     
     - returns: The stored password, fetched from the keychain.
     */
    func getStoredPasswordForUser(_ inRooutURI: String, inUser: String) -> String {
        var ret: String = ""
        
        if type(of: self).supportsTouchID { // No TouchID, no stored password.
            if nil != self._keychainWrapper {
                if let passwordFetched = (self._keychainWrapper.object(forKey: inRooutURI.cleanURI() + "-" + inUser)) as? String {
                    ret = passwordFetched
                }
            }
        }
        
        return ret
    }
}
