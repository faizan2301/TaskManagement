import 'package:flutter/material.dart';
import 'package:task_management/common/index.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerDropdown() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

Widget buildShimmerListView() {
  return ListView.builder(
    itemCount: 5,
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    },
  );
}

Widget buildErrorState(BuildContext context, VoidCallback onPressed) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red),
        SizedBox(height: 16),
        Text(
          'Oops! Something went wrong.',
          style: AppTextStyle.titleMedium(context),
        ),
        SizedBox(height: 16),
        AppButton(text: 'Try Again', onPressed: onPressed),
      ],
    ),
  );
}

Widget buildEmptyState(String message, BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox, size: 48, color: Colors.grey),
        SizedBox(height: 16),
        Text(message, style: AppTextStyle.titleMedium(context)),
      ],
    ),
  );
}

Widget buildRowItem(String label, String value, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            "$label:",
            style: AppTextStyle.labelLarge(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value, style: AppTextStyle.bodyMedium(context))),
      ],
    ),
  );
}
