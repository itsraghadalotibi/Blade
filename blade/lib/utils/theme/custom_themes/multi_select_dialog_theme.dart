
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart'; 

class TMultiSelectDialogTheme {
  TMultiSelectDialogTheme._();

  /// Returns a themed MultiSelectDialogField for Light Mode
  static MultiSelectDialogField<String> lightMultiSelectDialogField({
    required List<MultiSelectItem<String>> items,
    required List<String> selectedItems,
    required Function(List<String>) onConfirm,
    String title = 'Select Items',
    String buttonText = 'Select Items',
  }) {
    return MultiSelectDialogField<String>(
      items: items,
      backgroundColor: TColors.light,
      title: Text(title, style: const TextStyle(color: TColors.black)),
      selectedColor: TColors.primary,
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        border: Border.all(
          color: TColors.borderPrimary,
          width: 1,
        ),
      ),
      buttonIcon: const Icon(
        Icons.arrow_drop_down,
        color: TColors.textSecondary,
      ),
      buttonText: Text(
        buttonText,
        style: const TextStyle(
          color: TColors.black,
          fontSize: TSizes.fontSizeMd,
        ),
      ),
      listType: MultiSelectListType.LIST,
      searchable: true,
      searchHint: 'Search',
      onConfirm: onConfirm,
      chipDisplay: MultiSelectChipDisplay(
        chipColor: TColors.secondary,
        textStyle: const TextStyle(
          color: TColors.textPrimary,
          fontSize: TSizes.fontSizeSm,
          fontWeight: FontWeight.bold,
        ),
      ),
      itemsTextStyle: const TextStyle(
        color: TColors.textPrimary,
        fontSize: TSizes.fontSizeMd,
      ),
      selectedItemsTextStyle: const TextStyle(
        color: TColors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: TSizes.fontSizeMd,
      ),
      searchTextStyle: const TextStyle(
        color: TColors.textPrimary,
        fontSize: TSizes.fontSizeMd,
      ),
    );
  }

  /// Returns a themed MultiSelectDialogField for Dark Mode
  static MultiSelectDialogField<String> darkMultiSelectDialogField({
    required List<MultiSelectItem<String>> items,
    required List<String> selectedItems,
    required Function(List<String>) onConfirm,
    String title = 'Select Items',
    String buttonText = 'Select Items',
  }) {
    return MultiSelectDialogField<String>(
      items: items,
      backgroundColor: TColors.darkerGrey,
      title: Text(title, style: const TextStyle(color: TColors.textWhite)),
      selectedColor: TColors.primary,
      decoration: BoxDecoration(
        color: TColors.dark,
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        border: Border.all(
          color: TColors.borderSecondary,
          width: 1,
        ),
      ),
      buttonIcon: const Icon(
        Icons.arrow_drop_down,
        color: TColors.textSecondary,
      ),
      buttonText: Text(
        buttonText,
        style: const TextStyle(
          color: TColors.textWhite,
          fontSize: TSizes.fontSizeMd,
        ),
      ),
      listType: MultiSelectListType.LIST,
      searchable: true,
      searchHint: 'Search',
      onConfirm: onConfirm,
      chipDisplay: MultiSelectChipDisplay(
        chipColor: TColors.secondary,
        textStyle: const TextStyle(
          color: TColors.black,
          fontSize: TSizes.fontSizeSm,
        ),
      ),
      itemsTextStyle: const TextStyle(
        color: TColors.textWhite,
        fontSize: TSizes.fontSizeMd,
      ),
      selectedItemsTextStyle: const TextStyle(
        color: TColors.white,
        fontWeight: FontWeight.bold,
        fontSize: TSizes.fontSizeMd,
      ),
      searchTextStyle: const TextStyle(
        color: TColors.textWhite,
        fontSize: TSizes.fontSizeMd,
      ),
    );
  }
}
