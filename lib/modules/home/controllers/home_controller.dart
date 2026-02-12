import 'package:get/get.dart';
import 'package:junto/modules/home/services/home_service.dart';
import 'package:junto/di/locator.dart';

class HomeController extends GetxController {
  final HomeService homeService = getIt<HomeService>();
}



