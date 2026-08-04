import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/data/models/rider_profile.dart';
import 'package:jimamuapp/modules/rider/rider_profile_controller.dart';
import 'package:jimamuapp/utils/app_colors.dart';
import 'package:jimamuapp/utils/app_typography.dart';

class RiderProfileView extends GetView<RiderProfileController> {
  final RiderDocument riderDocument;
  const RiderProfileView(this.riderDocument, {super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'Rider Profile',
          style: AppTypography.sub1Medium.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description,
                      size: 24.r,
                      color: AppColors.primaryColor,
                    ),
                    8.horizontalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Document Type", style: AppTypography.sub1Medium),
                        8.verticalSpace,
                        Text(
                          controller
                              .authController
                              .riderProfile
                              .value!
                              .riderDocument!
                              .first
                              .documentType!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              15.verticalSpace,

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.key, size: 24.r, color: AppColors.primaryColor),
                    8.horizontalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Document Number",
                          style: AppTypography.sub1Medium,
                        ),
                        8.verticalSpace,
                        Text(
                          controller
                              .authController
                              .riderProfile
                              .value!
                              .riderDocument!
                              .first
                              .documentNumber!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              24.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: 10.h,
                  right: 10.h,
                  left: 10.h,
                  bottom: 20.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Submitted Document Image",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    8.verticalSpace,
                    (riderDocument.document == null ||
                            riderDocument.document!.isEmpty)
                        ? Center(child: Text("No document submitted"))
                        : riderDocument.documentType?.toLowerCase() !=
                              "passport"
                        ? Column(
                            children: riderDocument.document!.map((imgUrl) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    imgUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return SizedBox(
                                            height: 200,
                                            width: double.infinity,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: AppColors.primaryColor,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              riderDocument.document!.first,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      return child; // image is fully loaded
                                    }
                                    return SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
