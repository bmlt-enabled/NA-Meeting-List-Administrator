![icon](icon.png)

NA MEETING LIST ADMINISTRATOR
=

NA Meeting List Administrator is an iOS app for [the BMLT](https://bmlt.magshare.net) that is an administrative expression of [the BMLTiOSLib Communication Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

This app is designed to allow [BMLT Meeting List Administrators](https://bmlt.magshare.net/specific-topics/bmlt-roles/) to perform routine meeting list administrative tasks on their iPhone or iPad.

[Complete instructions are available on this Web page.](https://bmlt.magshare.net/satellites/bmlt-ios-apps/nameetinglistadministrator/)

REQUIREMENTS
=
The app requires that the iPhone or iPad have an active, persistent Internet connection.

In order to use the "What Meeting Am I At?" functionality, the app will require a GPS signal, and permission to determine your location.

The app itself requires iOS 10.0 or above, and administrative access to at leat one [BMLT Root Server](https://bmlt.magshare.net/installing-a-new-root-server/) Version 2.8.12 or above.

It also requires the Root Server to be running SSL (HTTPS), and that the Root Server have [Semantic Administration](https://bmlt.magshare.net/semantic/semantic-administration/) enabled.

If any of the above conditions are not met, the Root Server URL will be declared "invalid," and the app will refuse to connect to the Server.

Once connected, the user must have a valid login to that Server. If using a modern iPhone or iPad (with Touch ID or Face ID), then biometric login will be available.

The user must have at least one Service Body Administrator login to the Root Server with rights to edit meetings. Even a Service Body Admin will not be allowed to log in, if they are not authorized to edit meetings.

Observers and Server Administrators cannot log in. Observers do not have sufficient privileges to use the app, and we exclude the Server Administrator for security reasons (also, it is improper to use the Server Administrator account for routine meeting list administration).

Each login is limited to only those meetings/Service bodies for which they have editor rights. Meetings for which they don't have edit rights will not be accessible to, or displayed in, the app.

LICENSE
=
The NA Meeting List Administrator app uses [the MIT License](https://opensource.org/licenses/MIT).

TODO
=
The editor/new meeting screen needs to be refactored. Currently, they are indicated in the IB file as huge, unwieldy views. They need to be broken into multiple individual IB files, and stitched together at runtime.

CHANGELIST
=
***Version 1.5.0.3000* ** *- March 20, 2021*

- Switched to use SPM for dependencies.
- Added a "long press" to the formats list, so the user can see more info about formats.
- The connection is now done automatically upon startup. This reduces the number of taps to log in.
- Updated the BMLTiOSLib and KeyChainSwift dependencies.
- Changed graphic assets.

***Version 1.4.4.3000* ** *- April 19, 2020*

- No change. App Store release.

***Version 1.4.4.2005* ** *- April 14, 2020*

- Added Russian localization.

***Version 1.4.4.2004* ** *- April 2, 2020*

- Added Danish translations for the new Virtual Meeting URL text entry.
- Added support for the phone meeting number text entry.

***Version 1.4.4.2002* ** *- April 1, 2020*

- Added support for the new Virtual Meeting URL field.
- Fixed a bug, where the formats could be "cut off."

***Version 1.4.4.2000* ** *- February 9, 2020*

- Fixes a small bug, where invalid servers might not be reported as such.

***Version 1.4.3.3000* ** *- February 4, 2020*

- No change. App store release.

***Version 1.4.3.2000* ** *- February 3, 2020*

- Limit the deleted meetings to just the last 90 days (prevents server overflow).

***Version 1.4.2.3001* ** *- December 28, 2019*

- Bumped the version number.
- Minor URI fix in the localization file to point to the new URI.

***Version 1.4.2.3000* ** *- December 28, 2019*

- No changes. App Store release.

***Version 1.4.2.2002* ** *- December 24, 2019*

- More localization fixes.

***Version 1.4.2.2001* ** *- December 19, 2019*

- Danish translation issues fixed.

***Version 1.4.2.2000* ** *- December 13, 2019*

- Fixed a bug, in which the app could crash after committing a meeting change.

***Version 1.4.1.3000* ** *- September 24, 2019*

- Cosmetic/Usability fix for dark mode, in iOS13.

***Version 1.4.0.3001* ** *- September 16, 2019*

- No changes. Apple wanted me to re-release, using the latest RC of Xcode.

***Version 1.4.0.3000* ** *- September 15, 2019*

- App Store release.

***Version 1.4.0.2000* ** *- August 24, 2019*

- Switched the BMLTiOSLib to use Carthage.
- Updated to latest Swift and Xcode versions.
- The project now requires iOS 11.
- Updated to the latest version of Swift.
- Improved the appearance of the launch screen.
- Improved the behavior of the layout on X-phones.
- Improved documentation for 100% Jazzy docs.
- Switched to MIT License.

***Version 1.3.2.3000* ** *- January 10, 2019*

- No changes. App Store release.

***Version 1.3.2.2004* ** *- December 28, 2018*

- Added new BMLTiOSLib, with date fix.

***Version 1.3.2.2002* ** *- December 27, 2018*

- Simplified the Info string localization.
- Added the Italian localization for Face ID.
- Added a fixed version of BMLTiOSLib that addresses a bug in setting duration.

***Version 1.3.2.2001* ** *- December 27, 2018*

- Added Danish traslation
- Converted to newest Xcode and Swift 4.2
- Added support for the new Face ID description string.

***Version 1.3.1.3000* ** *- April 3, 2018*

- No changes. Release to App Store.

***Version 1.3.1.2006* ** *- April 2, 2018*

- Added an "invisible" parameter to the server calls, so that TOMATO will know that its being called by BMLTiOSLib apps.
- Updated to Xcode 9.3/Swift 4.1
- Bumped the version to 2006 to maintain with the other two apps.

***Version 1.3.1.2003* ** *- February 21, 2018*

- I switched off the animation for the "keyboard nudge." It caused an annoying little "hiccup."
- The "Where Am I" button should be hidden if there are no location manager services enabled.

***Version 1.3.1.2002* ** *- February 21, 2018*

- The keyboard size calculation wasn't quite right. This has been fixed.

***Version 1.3.1.2001* ** *- February 20, 2018*

- There was a coding error in the new code (the offset was being set when it shouldn't). That should be fixed now.

***Version 1.3.1.2000* ** *- February 20, 2018*

- Added code to make sure that the edit item is always available when the keyboard pops up.

***Version 1.3.0.3000* ** *- February 18, 2018*

- No changes -released to App Store.

***Version 1.3.0.2007* ** *- February 18, 2018*

- Added a "Logged In As" message for users that have multiple stored logins.

***Version 1.3.0.2006* ** *- February 17, 2018*

- I fixed an issue where the keyboard would appear inappropriately when disconnecting.
- Tweaked .swiftlint.yml slightly.
- Fixed a bug, where the last login was not being saved correctly. This manifested in the Service body selection not being separated, and the last login not being properly selected in the picker.
- Made the stored login picker larger for better usability.
- Made the service body search specification a bit more efficient (under the hood).
 
***Version 1.3.0.2005* ** *- February 16, 2018*

- Tweaked the README a bit.
- It was possible for stored logins to be displayed if there was no Touch/Face ID. This has been fixed.
- Fixed a couple of rather nasty bugs, where the two buttons at the top of the connected screen crashed. This was caused by my "code cleanup."
- Added a filter to make sure that only editable meetings are listed.

***Version 1.3.0.2004* ** *- February 16, 2018*

- Fixed an issue where, sometimes, the manual login items were not being properly displayed when returning to the login screen, and it was set to "MANUAL LOGIN".
- Fixed an issue where the MANUAL LOGIN was selected upon startup, when it should have been a stored login.

***Version 1.3.0.2003* ** *- February 16, 2018*

- Addressed an issue, where the keyboard would pop up when returning to the "LOG OUT" screen after a manual login.
- Stop the "flash" of the picker reverting to an old value, just before login.
- Made the "MANUAL LOG IN" string simply "LOG IN" when Touch ID/Face ID isn't supported, or we don't have stored logins for the server.
- Now store logins, even if Touch/Face ID isn't available, as it helps when phones are upgraded, or the user decides to enable Face ID after the fact.

***Version 1.3.0.2002* ** *- February 15, 2018*

- I changed the keychain access library, as FXKeychain is no longer supported.
- I fixed a bug, where stored IDs were being nuked.

***Version 1.3.0.2001* ** *- February 14, 2018*

- Fixed a couple of bugs in the new saved login system.

***Version 1.3.0.2000* ** *- February 14, 2018*

- Apple suddenly changed course on displaying Touch ID/Face ID icons. I now have to remove them, so that means that we now immediately go into Touch/Face ID.

***Version 1.2.4.3000* ** *- February 12, 2018*

- Added Italian location files for testing.

***Version 1.2.4.2006* ** *- January 7, 2018*

- This fixes the final issue with weeks that start on non-Sunday.

***Version 1.2.4.2005* ** *- January 7, 2018*

- There were several issues that the non-Sunday day of week caused. These have been addressed, with the exception of one: The sort still keys on Sunday. That will be fixed in the next release.

***Version 1.2.4.2004* ** *- January 7, 2018*

- Added the basic Swedish localization.

***Version 1.2.4.2003* ** *- January 7, 2018*

- Fixed an issue, exposed by the Italian translation, where weeks not beginning on Sunday caused a crash.

***Version 1.2.4.2002* ** *- January 5, 2018*

- Added the Reveal framework Cocoapod.
- Added Italian localization.

***Version 1.2.4.2001* ** *- December 13, 2017*

- Simply updated to the latest BMLTiOSLib.

***Version 1.2.4.2000* ** *- December 12, 2017*

- Moved FXKeychain to a Cocoapod.
- Added the SwiftLint Cocoapod.
- Updated the BMLTiOSLib to use the new SwiftLint-approved version.
- Many fixes to satisfy SwiftLint.
- Updated the LICENSE.txt file to reflect the new pods reality.

***Version 1.2.3.3000* ** *- December 9, 2017*

- Work to make the editor a bit more efficient.
- Spruced up this README.
- First submit for review.

***Version 1.2.3.2002* ** *- December 8, 2017*

- It looks like I may have figured out what was causing the occasional hangs after editing. We'll see...

***Version 1.2.3.2001* ** *- December 7, 2017*

- Apple's site wasn't updated to accept the new binaries, which forced me to wait a couple of days, and try again. This release has no change from .2000.

***Version 1.2.3.2000* ** *- December 5, 2017*

- I decided to go "full pod" on this, and installed the CocoaPod completely (as opposed to simply including the submodule and building the files directly).

***Version 1.2.2.3002* ** *- December 5, 2017*

- Tweaked for Xcode 3.2.
- Added some code to try making the app a bit more robust. Hopefully, it was totally unnecessary...

***Version 1.2.2.3001* ** *- December 2, 2017*

- This has minor format changes to fix a slight misalignment of the State and Nation text fields in the editor and new meeting screens.

***Version 1.2.2.3000* ** *- November 30, 2017*

- The map was still resetting its span when the user finishes dragging the marker. That should no longer happen.

***Version 1.2.1.3000* ** *- November 23, 2017*

- Fixed a crash when a bad URI is provided. This is going straight to the App Store. It was a VERY safe fix.

***Version 1.2.0.3000* ** *- November 18, 2017*

 - App Store Release.
 
***Version 1.2.0.2001* ** *- November 16, 2017*

- Fixed a crash when a meeting is found for "What Meeting am I at?"

***Version 1.2.0.2000* ** *- November 15, 2017*

- Refactored the project to use the new CocoaPods-structured BMLTiOSLib. This is a big change, so I'm bumping the version, and restarting the beta-testing.
- Added the "Extra Info" field to the address section. The fact it was missing was a bug on my part.
- The comments field in the editor now has a white background. The clear background caused user confusion.
- Fixed an issue where the background color for unpublished meetings was not alwas being set properly.

***Version 1.1.1.2002* ** *- October 27, 2017*

- Tweaked the colors on the TouchID and FaceID buttons.
- Tweaked the display text on the error messages for biometric fail.

***Version 1.1.1.2001* ** *- October 26, 2017*

- Added support for detecting FaceID in iPhone X.

***Version 1.1.1.2000* ** *- October 18, 2017*

- Added code to the meeting editor to avoid it resetting the map every time you move the marker.

***Version 1.1.0.3000* ** *- September 19, 2017*

- Release of 1.1.0

***Version 1.1.0.2000* ** *- September 13, 2017*

- The location lookup is more accurate.
- Added some basic fixes to make the app more responsive.
- Compiled for iOS 11.
- Fixed an issue where TouchID failures can crash the app ("Bad Touch").
- Slight update for latest Xcode.
- Added a pointer to the documentation page on the BMLT site.
- First beta test.

***Version 1.0.0.3000* ** *- March 14, 2017*

- First App Store release.

***Version 1.0.0.2007* ** *- March 9, 2017*

- Fixed a crash when restoring deleted meetings.

***Version 1.0.0.2006* ** *- March 9, 2017*

- Fixed a crash that could happen if a meeting had an empty history.

***Version 1.0.0.2005* ** *- March 8, 2017*

- Fixed a bug, where it was possible to cause the app to lock up if you quickly switch to Deleted while current is loading.
- I now make sure we disconnect after ten seconds away from the foreground.

***Version 1.0.0.2004* ** *- March 8, 2017*

- Tweaked the parameters for the URI text entry, so the proper keyboard shows up, and no correction is performed.
- Make sure the header of an edited meeting (NavBar) is the correct color to match the published status.
- Ensure that deleted meetings with bad weekday indexes (bad data) don't get displayed.
- Now hide the Deleted NavBar as well while fetching deleted meetings.

***Version 1.0.0.2003* ** *- March 8, 2017*

- Fixed a crash in the history view.

***Version 1.0.0.2002* ** *- March 8, 2017*

- Fixed a possible crash that could be caused by bad history.
- Fixed a sorting issue with the list view.
- Fixed some issues with the last item in the list and deleted tables being hidden behind the tab bar.

***Version 1.0.0.2001* ** *- March 7, 2017*

- Fixed a case-sensitivity issue with the asset catalog. This resulted in the checkmarks not displaying correctly.
- Made sure that the various checkboxes are perfectly round.
- Simplified the way the initial URI is stored. This will help prevent "crosstalk."
- Widened the Weekday section of the list a bit.
- Added a couple of separator lines in the list and meeting editor views to make it clear where the scrollable region begins.
- The History list needed alternating background colors.
- Added a callout for getting more details on history events.

***Version 1.0.0.2000* ** *- March 6, 2017*

- First beta tester release.
