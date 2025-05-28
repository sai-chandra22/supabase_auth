import 'package:get/get.dart';
import 'package:mars_scanner/modules/home_screen/view/app_screens_main_tab.dart';
import 'package:mars_scanner/routes/app_routes.dart';
import 'package:mars_scanner/modules/splash_screen/view/splash_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => const SplashScreen(),
      // page: () => const SearchApi(),
    ),
    GetPage(
      name: AppRoutes.homeScreen,
      page: () => const HomeScreenTabControl(),
    ),
  ];
}
