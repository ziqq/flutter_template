// autor - <a.a.ustinoff@gmail.com> Anton Ustinoff

import 'dart:async';

import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/util/error_util.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An interface for in-app review service,
/// providing methods to check if the review dialog can be shown
/// and to open the store listing or show the rating dialog.
abstract interface class IInAppReviewService {
  /// Checks when was open rating dialog.
  Future<bool> isSecondTimeOpen();

  /// Opens the `Play Store` on `Android`,
  /// the `App Store` with a review screen on `iOS` & `MacOS`
  /// and the `Microsoft Store` on `Windows`.
  Future<bool> openStoreListing();

  /// Shows rating dialog if is possible.
  Future<bool> showRating();
}

/// {@template in_app_review_service}
/// Implementation of [IInAppReviewService] using the `in_app_review` package.
/// This service manages the logic for showing the in-app review dialog and opening the store listing,
/// as well as tracking when the review dialog was last shown to the user using shared preferences.
/// {@endtemplate}
class InAppReviewService implements IInAppReviewService {
  /// {@macro app_rating_service}
  InAppReviewService({required SharedPreferencesAsync sharedPreferences}) : _sharedPreferences = sharedPreferences;

  /// The instance of [SharedPreferences] used to read and write values.
  final SharedPreferencesAsync _sharedPreferences;

  /// Example: `2023-02-06 14:30`
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd hh:mm');

  /// Last open date key in shared preferences.
  static const String _openDateKey = '${Config.storageNamespace}.review.open_date';

  @override
  Future<bool> isSecondTimeOpen() async {
    try {
      var isBeforeDate = true;

      final openDate = await _sharedPreferences.getString(_openDateKey);
      if (openDate != null && openDate.isNotEmpty) {
        final days = _dateFormat.parse(openDate).difference(_dateFormat.parse(DateTime.now().toString())).inDays;
        isBeforeDate = days.isNegative && days <= -15;
      }

      return Future.value(!isBeforeDate);
    } on Object catch (error, stackTrace) {
      ErrorUtil.logError(error, stackTrace).ignore();
      return Future.value(false);
    }
  }

  @override
  Future<bool> openStoreListing() async {
    try {
      await InAppReview.instance.openStoreListing(appStoreId: /* AppStoreAndGooglePlay.appStoreID */ '');
      return Future.value(true);
    } on Object catch (error, stackTrace) {
      ErrorUtil.logError(error, stackTrace).ignore();
      return Future.value(false);
    }
  }

  @override
  Future<bool> showRating() async {
    try {
      var result = false;

      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview().ignore();
        result = true;
      } else {
        InAppReview.instance.openStoreListing(appStoreId: /* AppStoreAndGooglePlay.appStoreID */ '').ignore();
      }

      await _sharedPreferences.setString(_openDateKey, _dateFormat.format(DateTime.now()));

      return Future.value(result);
    } on Object catch (error, stackTrace) {
      ErrorUtil.logError(error, stackTrace).ignore();
      return Future.value(false);
    }
  }
}
