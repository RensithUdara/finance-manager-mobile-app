import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/app_theme.dart';
import 'data/local/database_helper.dart';
import 'presentation/blocs/expense/expense_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/pages/home_screen.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/add_expense_screen.dart';
import 'presentation/pages/analytics_screen.dart';
import 'presentation/pages/expenses_screen.dart';
import 'presentation/pages/categories_screen.dart';
import 'presentation/pages/settings_screen.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Database - Initialize it properly
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database; // This initializes the database
  sl.registerLazySingleton(() => databaseHelper);

  // Blocs
  sl.registerFactory(() => ExpenseBloc(sl<DatabaseHelper>()));
  sl.registerFactory(() => ThemeCubit(sl()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()..loadTheme()),
        BlocProvider<ExpenseBloc>(create: (_) => sl<ExpenseBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Personal Finance Manager',
            theme: themeState.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/add-expense': (context) => const AddExpenseScreen(),
              '/analytics': (context) => const AnalyticsScreen(),
              '/expenses': (context) => const ExpensesScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
