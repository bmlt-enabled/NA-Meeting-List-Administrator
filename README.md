DESCRIPTION
===========

NA Meeting List Administrator is an iOS app for [the BMLT](https://bmlt.magshare.net) that is an administrative expression of [the BMLTiOSLib Communication Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

This app is designed for BMLT Meeting List Administrators to execute routine meeting list administrative tasks on their iPhone or iPad.

[Complete instructions are available on this Web page.](https://bmlt.magshare.net/satellites/bmlt-ios-apps/nameetinglistadministrator/)

REQUIREMENTS
============
The app requires that the iPhone or iPad have an active, persistent Internet connection.

In order to use the "What Meeting Am I At?" functionality, the app will require a GPS signal, and permission to determine your location.

The app itself requires iOS 10.0 or above, and administrative access to at leat one [BMLT Root Server](https://bmlt.magshare.net/installing-a-new-root-server/) Version 2.8.12 or above.

It also requires the Root Server to be running SSL (HTTPS), and that the Root Server have [Semantic Administration](https://bmlt.magshare.net/semantic/semantic-administration/) enabled.

If any of the above conditions are not met, the Root Server URL will be declared "invalid," and the app will refuse to connect to the Server.

Once connected, the user must have a valid login to that Server. If using a modern iPhone or iPad (with Touch ID or Face ID), then biometric login will be available.

The user must have at least one Service Body Administrator login to the Root Server with rights to edit meetings.

Observers and Server Administrators cannot log in. Observers do not have sufficient privileges to use the app, and we exclude the Server Administrator for security reasons (also, it is improper to use the Server Administrator account for routine meeting list administration).

Each login is limited to only those meetings/Service bodies for which they have editor rights. Meetings for which they don't have edit rights will not be accessible to, or displayed in, the app.

LICENSE
=======
The NA Meeting List Administrator app is [GPL V3](https://opensource.org/licenses/GPL-3.0); However, the [BMLTiOSLib](https://bmlt.magshare.net/specific-topics/bmltioslib/) uses [the MIT License](https://opensource.org/licenses/MIT).

CHANGELIST
----------
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
