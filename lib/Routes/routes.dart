import 'package:flutter/material.dart';

import '../ui/Dashbord/Dashbord_view.dart';
import '../ui/Gym/Gym_view.dart';
import '../ui/Money/Money_view.dart';
import '../ui/profile/profile_view.dart';
import '../ui/style/Style_view.dart';
import '../ui/navigation/navigationBar.dart';
import '../ui/daily/daily.dart';
import '../ui/calender/calender_view.dart';
import '../ui/deadline/deadline_view.dart';

final Map<String, WidgetBuilder> routes = {
  DashbordView.routeName: (context) => const DashbordView(),
  Moneyview.routeName: (context) => const Moneyview(),
  GymView.routeName: (context) => const GymView(),
  StyleView.routeName: (context) => const StyleView(),
  ProfileView.routeName: (context) => const ProfileView(),
  Navigationbarview.routeName: (context) => const Navigationbarview(),
  DailyView.routeName: (context) => const DailyView(),
  CalendarView.routeName: (context) => const CalendarView(),
  DeadlineView.routeName: (context) => const DeadlineView(),
};

const List<String> navigationRoutes = [
  '/Dashbord',
  '/Money',
  '/Gym',
  '/Style',
  '/profile',
];
