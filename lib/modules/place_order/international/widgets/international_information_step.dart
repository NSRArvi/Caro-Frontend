import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jimamuapp/utils/app_colors.dart';

import '../../../../utils/app_typography.dart';
import '../international_placing_order_controller.dart';

Widget sectionTitle(String title) {
  return Align(
    alignment: Alignment.topLeft,
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );
}

class InternationalInformationStep extends StatefulWidget {
  final InternationalPlacingOrderController controller;
  InternationalInformationStep({super.key, required this.controller});

  @override
  State<InternationalInformationStep> createState() =>
      _InternationalInformationStepState();
}

class _InternationalInformationStepState
    extends State<InternationalInformationStep> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: widget.controller.infoFormKey,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Sender details"),
              const SizedBox(height: 12),
              _inputCard(
                children: [
                  _inputField(
                    "Enter sender name",
                    widget.controller.senderNameController,
                    false,
                  ),
                  // _inputField(
                  //   "Enter sender phone",
                  //   widget.controller.senderPhoneController,
                  //   true,
                  // ),
                  senderPhoneInputField(
                    controller: widget.controller.senderPhoneController,
                    countryCode: widget.controller.senderCountryCode,
                    countryName: widget.controller.selectedCountryName,
                  ),
                  _inputField(
                    "Enter direction (Road, Landmark, House etc.)",
                    widget.controller.senderRemarksController,
                    false,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [sectionTitle("Receiver details")],
              ),
              const SizedBox(height: 12),
              _inputCard(
                children: [
                  _inputField(
                    "Enter receiver name",
                    widget.controller.receiverController,
                    false,
                  ),
                  // _inputField(
                  //   "Enter receiver phone",
                  //   widget.controller.receiverPhoneController,
                  //   true,
                  // ),
                  receiverPhoneInputField(
                    controller: widget.controller.receiverPhoneController,
                    countryCode: widget.controller.receiverCountryCode,
                    countryName: widget.controller.receiverSelectedCountryName,
                  ),
                  // phoneInputField(
                  //   controller: widget.controller.receiverPhoneController,
                  //   countryCode: widget.controller.receiverCountryCode,
                  // ),
                  _inputField(
                    "Enter direction (Road, Landmark, House etc.)",
                    widget.controller.receiverRemarksController,
                    false,
                    maxLines: 4,
                  ),
                ],
              ),
              35.verticalSpace,
              widget.controller.selectedPackage.value == null
                  ? InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        widget.controller.showPackageListBottomSheet();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.black400,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 3),
                              color: AppColors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "+ Add Package Details",
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle("Package type"),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: widget.controller.showPackageListBottomSheet,
                          child: Container(
                            width: double.infinity,
                            height: 45.h,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.controller.selectedPackage.value!['name'],
                              style: AppTypography.bodyBold.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        /*Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.packageType.map((type) {
                            final isSelected =
                                controller.selectedPackage?['id'] == type['id'];
                            return ChoiceChip(
                              label: Text(type['name']),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.selectPackage(type);
                              },
                              selectedColor: Colors.red.shade100,
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.red.shade700
                                    : Colors.black,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),*/
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Additional Information',
                              style: AppTypography.sub1SemiBold,
                            ),
                            /*GestureDetector(
                              onTap: () =>
                                  controller.showAdditionalInfoSheet(context),
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),*/
                          ],
                        ),
                        20.verticalSpace,
                        Form(
                          key: widget.controller.additionalInfoKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller:
                                    widget.controller.productWeightController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: "Enter product's weight",
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),

                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 0,
                                      ),
                                      // decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius: BorderRadius.circular(12),
                                      //     border: Border.all(color: Colors.black12)
                                      // ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: widget
                                              .controller
                                              .selectedWeightUnit,
                                          dropdownColor: Colors.white,
                                          // borderRadius: BorderRadius.circular(12),
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'kg',
                                              child: Text(
                                                'kg',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'lbs',
                                              child: Text(
                                                'lbs',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              widget
                                                      .controller
                                                      .selectedWeightUnit =
                                                  value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: false,
                                    ),
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                // ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],

                                onChanged: (val) {
                                  if (val.isEmpty) return;

                                  double weight = double.parse(val);

                                  // /// Convert lbs → kg if needed
                                  // if (widget.controller.selectedWeightUnit == 'lbs') {
                                  //   weight = weight * 0.453592;
                                  // }

                                  widget.controller.prodWeight.value = weight;
                                },

                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter the weight!';
                                  }

                                  final weight = double.parse(val);

                                  if (weight == 0) {
                                    return 'Weight cannot be 0.';
                                  }

                                  /// Max validation based on unit
                                  // if (widget.controller.selectedWeightUnit ==
                                  //         'kg' &&
                                  //     weight > 10) {
                                  //   return 'Maximum allowed weight is 10 kg.';
                                  // }

                                  // if (widget.controller.selectedWeightUnit ==
                                  //         'lbs' &&
                                  //     weight > 22) {
                                  //   return 'Maximum allowed weight is 22 lbs.';
                                  // }

                                  return null;
                                },
                              ),
                              // TextFormField(
                              //   controller: widget.controller.productWeightController,
                              //   autovalidateMode:
                              //       AutovalidateMode.onUserInteraction,
                              //   decoration: InputDecoration(
                              //     hintText: "Enter product's weight",
                              //     enabledBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black26,
                              //       ),
                              //     ),
                              //     focusedErrorBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black26,
                              //       ),
                              //     ),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black26,
                              //       ),
                              //     ),
                              //     errorBorder: OutlineInputBorder(
                              //       borderSide: BorderSide(
                              //         color: Colors.black26,
                              //       ),
                              //     ),
                              //     suffix: Text(
                              //       "kg",
                              //       style: TextStyle(
                              //         fontSize: 14.r,
                              //         color: Colors.black45,
                              //       ),
                              //     ),
                              //   ),
                              //   keyboardType: TextInputType.numberWithOptions(
                              //     signed: false,
                              //     decimal: true,
                              //   ),
                              //   inputFormatters: [
                              //     FilteringTextInputFormatter.allow(
                              //       RegExp(r'^\d*\.?\d*'),
                              //     ),
                              //   ],
                              //   onChanged: (val) {
                              //     widget.controller.prodWeight.value = double.parse(
                              //       widget.controller.productWeightController.text
                              //           .trim(),
                              //     );
                              //   },
                              //   validator: (val) {
                              //     if (val == null || val.isEmpty) {
                              //       return 'Please Enter the weight!';
                              //     }
                              //     if (double.parse(val.toString()) == 0.0) {
                              //       return 'Product\'s market value cannot be 0.';
                              //     }
                              //     if (double.parse(val) > 10.0) {
                              //       return "The maximum allowed weight is 10 kg.";
                              //     }
                              //     return null;
                              //   },
                              // ),
                              20.verticalSpace,
                              TextFormField(
                                controller:
                                    widget.controller.productValueController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: "Enter product's market value",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  suffix: Text(
                                    "CAD",
                                    style: TextStyle(
                                      fontSize: 14.r,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ), // allow only numbers & decimal
                                ],
                                onChanged: (val) {
                                  widget.controller.prodMarketValue.value =
                                      double.parse(
                                        widget
                                            .controller
                                            .productValueController
                                            .text
                                            .trim(),
                                      );
                                  log(
                                    "MArket Value ${widget.controller.prodMarketValue.value}",
                                  );
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please Enter Product\'s Market Value!';
                                  }
                                  if (double.parse(val.toString()) == 0.0) {
                                    return 'Product\'s weight cannot be 0.';
                                  }
                                  if (double.parse(val.toString()) > 5000.00) {
                                    return 'Orders above 5000 in market value are not allowed.';
                                  }
                                  return null;
                                },
                              ),
                              30.verticalSpace,
                              Text(
                                'Enter your offer for Rider',
                                style: AppTypography.sub1SemiBold,
                              ),
                              20.verticalSpace,
                              TextFormField(
                                controller: widget
                                    .controller
                                    .willingDeliveryChargeController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: "Enter amount in CAD",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  suffix: Text(
                                    "CAD",
                                    style: TextStyle(
                                      fontSize: 14.r,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ), // allow only numbers & decimal
                                ],
                                onChanged: (val) {
                                  widget
                                      .controller
                                      .willingDeliveryCharge
                                      .value = double.parse(
                                    widget
                                        .controller
                                        .willingDeliveryChargeController
                                        .text
                                        .trim(),
                                  );
                                  log(
                                    "WIlling Delivery Charge ${widget.controller.willingDeliveryCharge.value}",
                                  );
                                },
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please Enter Delivery charge you want to pay!';
                                  }
                                  if (double.parse(val.toString()) == 0.0) {
                                    return 'Offer Delivery Charge cannot be 0.';
                                  }
                                  final weight = double.parse(val);

                                  if (weight < 45) {
                                    return 'Delivery charge cannot be less then 45.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        // controller.prodWeight.value != 0.0
                        //     ? SizedBox(
                        //         width: double.infinity,
                        //         child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text(
                        //               'Product\'s weight',
                        //               style: AppTypography.bodyMedium,
                        //             ),
                        //             Text(
                        //               controller.prodWeight!.value
                        //                   .toStringAsFixed(2),
                        //               style: AppTypography.bodyMedium,
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     : SizedBox.shrink(),
                        // 20.verticalSpace,
                        // controller.prodMarketValue.value != 0.0
                        //     ? SizedBox(
                        //         width: double.infinity,
                        //         child: Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text(
                        //               'Product\'s market value',
                        //               style: AppTypography.bodyMedium,
                        //             ),
                        //             Text(
                        //               controller.prodMarketValue!.value
                        //                   .toStringAsFixed(2),
                        //               style: AppTypography.bodyMedium,
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     : SizedBox.shrink(),
                      ],
                    ),
              25.verticalSpace,

              const SizedBox(height: 45),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            color: AppColors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        children: children
            .map(
              (widget) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: widget,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _inputField(
    String hint,
    TextEditingController? controller,
    isPhone, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (hint == "Enter direction (Road, Landmark, House etc.)" ||
            hint == "Enter direction (Road, Landmark, House etc.)") {
          return null;
        }

        if (value == null || value.isEmpty) {
          return 'Please ${hint[1].toLowerCase() != 'e' ? '' : 'enter '}${hint.toLowerCase()}';
        }
        return null;
      },
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.black400, fontSize: 14.r),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      inputFormatters: isPhone
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))]
          : [],
    );
  }
  Widget senderPhoneInputField({
    required TextEditingController controller,
    required RxString countryCode,
    required RxString countryName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryCodePicker(
          onChanged: (code) {
            if (code != null) {
              countryCode.value = code.dialCode ?? '+1';
              countryName.value = code.code ?? 'Canada';
            }
          },
          initialSelection: countryName.value,
          favorite: const ['+1', '+880', '+91'],
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
          builder: (code) {
            return Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  if (code != null)
                    Image.asset(
                      code.flagUri!,
                      package: 'country_code_picker',
                      width: 32,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    code?.name ?? countryName.value,
                    style: AppTypography.bodyRegular,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ///  Country Code Display
            CountryCodePicker(
              onChanged: (code) {
                if (code != null) {
                  countryCode.value = code.dialCode ?? '+1';
                  countryName.value = code.code ?? 'Canada';
                }
              },
              initialSelection: countryName.value,
              favorite: const ['+1', '+880', '+91'],
              builder: (code) {
                return Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      countryCode.value,
                      style: AppTypography.bodyRegular,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 7) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter sender phone number',
                  hintStyle: TextStyle(
                    color: AppColors.black400,
                    fontSize: 14.r,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget receiverPhoneInputField({
    required TextEditingController controller,
    required RxString countryCode,
    required RxString countryName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryCodePicker(
          onChanged: (code) {
            if (code != null) {
              countryCode.value = code.dialCode ?? '+1';
              countryName.value = code.code ?? 'Canada';
            }
          },
          initialSelection: countryName.value,
          favorite: const ['+1', '+880', '+91'],
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
          builder: (code) {
            return Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  if (code != null)
                    Image.asset(
                      code.flagUri!,
                      package: 'country_code_picker',
                      width: 32,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    code?.name ?? countryName.value,
                    style: AppTypography.bodyRegular,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ///  Country Code Display
            CountryCodePicker(
              onChanged: (code) {
                if (code != null) {
                  countryCode.value = code.dialCode ?? '+1';
                  countryName.value = code.code ?? 'Canada';
                }
              },
              initialSelection: countryName.value,
              favorite: const ['+1', '+880', '+91'],
              builder: (code) {
                return Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Text(
                      countryCode.value,
                      style: AppTypography.bodyRegular,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 8),

            // Phone Number Field
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 7) {
                    return 'Invalid phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Enter receiver phone number',
                  hintStyle: TextStyle(
                    color: AppColors.black400,
                    fontSize: 14.r,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
