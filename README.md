# LearnApp

An app and share extension for organizing your reading list into topics and subtopics. Integrates with Pocket to allow you to import your existing Pocket list and keep Learn App articles in your Pocket feed offline.

#### Notes:
- This app uses Carthage (https://github.com/Carthage/Carthage) for dependency management, and dependencies are not checked in, so you will need to `carthage update --platform ios --no-use-binaries` before running the app.
- The app expects the LearnKit bundle to contain a Keys.plist file containing developer keys for the Pocket API (https://getpocket.com/developer/). The plist should contain keys `PocketAppId` and `PocketConsumerKey`. Without this file, no Pocket integration functionality will work.
