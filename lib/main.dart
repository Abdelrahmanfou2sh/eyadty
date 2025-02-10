import 'package:eyadty/core/theme/app_theme.dart';
import 'package:eyadty/core/theme/theme_cubit.dart';
import 'package:eyadty/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_profile_cubit.dart';
import 'package:eyadty/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const MyApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(),
        ),
        BlocProvider(
          create: (context) => AppointmentCubit()..fetchAppointments(),
        ),
        BlocProvider(
          create: (context) => PatientProfileCubit()..loadPatients(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(prefs),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'عيادتي',
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
