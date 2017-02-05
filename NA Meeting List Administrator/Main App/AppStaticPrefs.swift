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
import BMLTiOSLib

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
        /** This is the Root Server URI */
        case RootServerURI = "BMLTRootServerURI"
        /** This is the plist key for the default (initial) URI. */
        case DefaultRootServerURIPlistKey = "BMLTDefaultRootServerURI"
        /** This is the key for the stored URI/login sets. */
        case RootServerLoginDictionaryKey = "BMLTStoredLoginIDs"
        /** This is the key for the last login value pair. */
        case LastLoginPair = "BMLTLastLoginPair"
        /** This will refer to an array of Int that will indicate selected Service body IDs. */
        case SelectedServiceBodies = "BMLTSelectedServiceBodies"
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
            }
        }
    }
    
    /* ################################################################## */
    /**
     This saves and returns the last successful login, for quick restoration later.
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
                    let ret: [String] = [newValue.url, newValue.loginID]
                    self._loadedPrefs.setObject(ret, forKey: PrefsKeys.LastLoginPair.rawValue as NSString)
                }
            }
        }
    }
    
    /* ################################################################## */
    /**
     This returns all the Service bodies available.
     */
    var allEditableServiceBodies: [BMLTiOSLibHierarchicalServiceBodyNode] {
        get {
            var ret: [BMLTiOSLibHierarchicalServiceBodyNode] = []
            
            if (nil != MainAppDelegate.connectionObject) && MainAppDelegate.connectionObject.isConnected && MainAppDelegate.connectionObject.isAdminLoggedIn {
                ret = MainAppDelegate.connectionObject.serviceBodiesICanEdit
            }
            
            return ret
        }
    }
    
    /* ################################################################## */
    /**
     This returns a selectable array of objects, with indications as to whether or not they have been selected.
     
     We associate the selections with a URL/login pair (the last successful one), so this can change from login to login.
     */
    var selectableServiceBodies: [SelectableServiceBodyTuple] {
        get {
            var ret: [SelectableServiceBodyTuple] = []
            let loginSet = self.lastLogin
            let key = loginSet.url + "-" + loginSet.loginID
            
            if self._loadPrefs() {
                if 1 == self.allEditableServiceBodies.count {   // If we only have one body, then it is always selected, and can't be deselected.
                    ret = [(serviceBodyObject: self.allEditableServiceBodies[0], selected: true)]
                } else {
                    for sb in self.allEditableServiceBodies {
                        let sbID = sb.id
                        var tempTuple: SelectableServiceBodyTuple = (serviceBodyObject: sb, selected: false)
                        if let temp = self._loadedPrefs.object(forKey: PrefsKeys.SelectedServiceBodies.rawValue) as? [String:[Int]] {
                            if let mySBSelectionArray = temp[key] {
                                for selectedSBID in mySBSelectionArray {
                                    if selectedSBID == sbID {
                                        tempTuple.selected = true
                                    }
                                }
                            }
                        }
                        
                        ret.append(tempTuple)
                    }
                }
            }

            return ret
        }
        
        set {
            var newDictionary: [String:[Int]] = [:]
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.SelectedServiceBodies.rawValue) as? [String:[Int]] {
                    newDictionary = temp
                }
            }
            
            var newArray: [Int] = []
            
            for sbTuple in newValue {
                if sbTuple.selected {
                    newArray.append((sbTuple.serviceBodyObject?.id)!)
                }
            }
            
            let loginSet = self.lastLogin
            let key = loginSet.url + "-" + loginSet.loginID

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
            if let temp = self._loadedPrefs.object(forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue) as? [String:[String]] {
                ret = temp[inRooutURI]
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
     This updates our stored selection state for the given Service body.
     
     - parameter serviceBodyObject: The Service body object that is being selected or deselected. If nil, then the selection is applied to all available Service bodies.
     - parameter selected: True, if the Service body object is being selected.
     */
    func setServiceBodySelection(serviceBodyObject: BMLTiOSLibHierarchicalServiceBodyNode!, selected: Bool) {
        for i in 0..<self.selectableServiceBodies.count {
            if (1 == self.selectableServiceBodies.count) || (nil == serviceBodyObject) || (self.selectableServiceBodies[i].serviceBodyObject?.id == serviceBodyObject.id) {
                self.selectableServiceBodies[i].selected = selected
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
        for i in 0..<self.selectableServiceBodies.count {
            if self.selectableServiceBodies[i].serviceBodyObject?.id == serviceBodyObject.id {
                return self.selectableServiceBodies[i].selected || (1 == self.selectableServiceBodies.count)
            }
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
                ret = true  // If we need to update, then this was the first login.
                
                self._loadedPrefs.setObject(loginDictionary, forKey: PrefsKeys.RootServerLoginDictionaryKey.rawValue as NSString)
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
        
        return ret
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
                let _ = self.updateUserForRootURI(inRooutURI, inUser: inUser)   // Clear any stored password, first.
                
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
                            let _ = self.updateUserForRootURI(inRooutURI, inUser: users[i])
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
        
        if type(of: self).supportsTouchID { // No TouchID, no stored password.
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
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     - parameter inRooutURI: The URI of the Root Server, as a String
     - parameter inUser: A String for the login ID.
     */
    func getStoredPasswordForUser(_ inRooutURI: String, inUser: String) -> String {
        var ret: String = ""
        
        if type(of: self).supportsTouchID { // No TouchID, no stored password.
            if nil != self._keychainWrapper {
                if let passwordFetched = self._keychainWrapper.object(forKey: inRooutURI + "-" + inUser) {
                    ret = (passwordFetched as! String)
                }
            }
        }
        
        return ret
    }
}
