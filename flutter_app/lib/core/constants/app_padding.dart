import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_spacing.dart';

abstract final class AppPadding {
  static EdgeInsets get screen =>
      EdgeInsets.symmetric(horizontal: AppSpacing.md.w);

  static EdgeInsets get card => EdgeInsets.all(AppSpacing.md.r);

  static EdgeInsets get vertical =>
      EdgeInsets.symmetric(vertical: AppSpacing.md.h);

  static EdgeInsets get horizontal =>
      EdgeInsets.symmetric(horizontal: AppSpacing.md.w);
}
