import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:junto/modules/home/services/home_service.dart';
import 'package:junto/di/locator.dart';

class HomeController extends GetxController {
  final HomeService homeService = getIt<HomeService>();

  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final RxString searchQuery = ''.obs; // raw (immediate) input
  final RxString debouncedQuery = ''.obs; // what the UI filters by
  final RxBool isSearchOpen = false.obs;
  final RxInt selectedTabIndex = 0.obs; // 0 = All, 1 = Unread
  Worker? _debouncer;

  @override
  void onInit() {
    super.onInit();
    _debouncer = debounce<String>(
      searchQuery,
      (value) => debouncedQuery.value = value,
      time: const Duration(milliseconds: 200),
    );
  }

  @override
  void onClose() {
    _debouncer?.dispose();
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
    debouncedQuery.value = '';
  }

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (isSearchOpen.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isSearchOpen.value) {
          searchFocusNode.requestFocus();
        }
      });
    } else {
      searchFocusNode.unfocus();
      clearSearch();
    }
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }
}
