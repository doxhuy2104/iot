import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:flutter/material.dart';

class ZoneDetailPage extends StatefulWidget {
  const ZoneDetailPage({super.key});

  @override
  State<StatefulWidget> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.localization.zone),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Button(
            borderRadius: BorderRadius.circular(44),
            onPress: () {},
            child: const Icon(Icons.add),
          ).paddingOnly(right: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          ),
        ),
      ),
    );
  }
}
