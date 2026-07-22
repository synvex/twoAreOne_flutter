# ViewModels

This folder is reserved for the ViewModel layer of the MVVM pattern.

This structural reorg kept all existing screen logic exactly as it was
(inside the widgets in `lib/ui/views/`) to avoid introducing behavioral
changes without a way to compile/test the app. To complete a full MVVM
conversion, extract the state/business logic currently living in each
StatefulWidget's `setState` calls into a `ChangeNotifier` (or Riverpod/Bloc)
class here, one per screen, e.g.:

- `login_viewmodel.dart` for `ui/views/auth/login.dart`
- `home_viewmodel.dart` for `ui/views/bottom_nav/home_screen.dart`
- `main_screen_viewmodel.dart` for `ui/views/main/main_screen.dart`

Do this incrementally, one screen at a time, running the app after each
change, since it touches real business logic rather than just file paths.
