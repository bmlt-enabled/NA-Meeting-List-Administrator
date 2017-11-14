DESCRIPTION
===========

NA Meeting List Administrator is an iOS app for [the BMLT](https://bmlt.magshare.net) that is an administrative expression of [the BMLTiOSLib Communication Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

It is very similar to [the BMLTAdmin iOS app](https://bmlt.magshare.net/satellites/ios-app/the-bmltadmin-app/). It has a few different behaviors (mostly as a nod to usability), but "under the hood," it is very different from the BMLTAdmin app.

This app has been designed to eventually supercede the BMLTAdmin app. Since it requires HTTPS and Root Server 2.8.12 or above, it is being delivered as a separate app, and not as a new version of BMLTAdmin.

This app is designed for BMLT Meeting List Administrators to execute routine meeting list administrative tasks on their iPhone or iPad.

REQUIREMENTS
============
The app requires that the iPhone or iPad have an active, persistent Internet connection.
In order to use the "What Meeting Am I At?" functionality, the app will require a GPS signal, and permission to determine your location.
The app itself requires iOS 10.0 or above, and administrative access to at leat one [BMLT Root Server](https://bmlt.magshare.net/installing-a-new-root-server/) Version 2.8.12 or above.
It also requires the Root Server to be running SSL (HTTPS).
The user must have at least one login to the Root Server that can administer meetings (Service Body Administrator level). Observers and Server Administrators cannot log in. Observers do not have sufficient privileges to use the app, and we exclude the Server Administrator for security reasons (also, it is improper to use the Server Administrator account for routine meeting list administration).

LICENSE
=======
The NA Meeting List Administrator app is [GPL V3](https://opensource.org/licenses/GPL-3.0); However, the [BMLTiOSLib](https://bmlt.magshare.net/specific-topics/bmltioslib/) uses [the MIT License](https://opensource.org/licenses/MIT).

CHANGELIST
----------
***Version 1.2.0.2000* ** *- TBD*

- Refactored the project to use the new CocoaPods-structured BMLTiOSLib. This is a big change, so I'm bumping the version, and restarting the beta-testing.
- Added the "Extra Info" field to the address section. The fact it was missing was a bug on my part.
- The comments field in the editor now has a white background. The clear background caused user confusion.

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
