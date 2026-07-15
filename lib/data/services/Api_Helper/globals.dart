// FIX: This file used to declare its own `navigatorKey`, which was a exact
// duplicate of the one in `api_manager.dart`. Two separate GlobalKey
// instances meant that whichever one MaterialApp was NOT using would never
// have a valid `currentContext`, and importing both files together in the
// same file would have caused a "navigatorKey is already defined" compile
// error. We now simply re-export the single, real key so old imports of
// `globals.dart` keep working without creating a second key.
export 'api_manager.dart' show navigatorKey;
