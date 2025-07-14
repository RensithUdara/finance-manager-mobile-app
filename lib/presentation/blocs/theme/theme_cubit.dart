import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State
class ThemeState extends Equatable {
  final bool isDarkMode;

  const ThemeState({required this.isDarkMode});

  @override
  List<Object> get props => [isDarkMode];
}

// Cubit
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeCubit(this.sharedPreferences)
      : super(const ThemeState(isDarkMode: false));

  static const String _themeKey = 'isDarkMode';

  void loadTheme() {
    final isDarkMode = sharedPreferences.getBool(_themeKey) ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  void toggleTheme() {
    final newTheme = !state.isDarkMode;
    sharedPreferences.setBool(_themeKey, newTheme);
    emit(ThemeState(isDarkMode: newTheme));
  }
}
