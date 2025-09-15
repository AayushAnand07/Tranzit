import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context,
      {required String title,
        required String message,
        required IconData icon,
        required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 0.9,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Colors.white,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: Colors.transparent,
                    width: 200.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black),
                        ),
                        Text(
                          message,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    icon,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void showLoadingSnackbar(BuildContext context, String Message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(days: 1),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.black.withOpacity(0.2),
            width: 0.9,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Colors.white,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200.w,
                    child: Text(
                      Message,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.teal,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
