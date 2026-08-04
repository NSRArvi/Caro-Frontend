import 'dart:io';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class UploadBox extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const UploadBox({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.black100,
            style: BorderStyle.solid,
          ),
        ),
        child: image != null
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.black100,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image!, fit: BoxFit.fill),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.file_upload_outlined,
                    color: Colors.red,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Drag your file here",
                    style: TextStyle(
                      color: AppColors.black500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
