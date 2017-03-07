DESCRIPTION
===========

NA Meeting List Administrator is an iOS app for [the BMLT](https://bmlt.magshare.net) that is an administrative expression of [the BMLTiOSLib Communication Framework](https://bmlt.magshare.net/specific-topics/bmltioslib/).

It is very similar to [the BMLTAdmin iOS app](https://bmlt.magshare.net/satellites/ios-app/the-bmltadmin-app/). It has a few different bhaviors (mostly as a nod to usability), but "under the hood," it is a very different application from the BMLTAdmin app.

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
