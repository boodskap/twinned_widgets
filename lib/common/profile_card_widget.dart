import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/profile_card_widget.dart/profile_card_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ProfileCardWidget extends StatefulWidget {
  final ProfileCardWidgetConfig config;
  const ProfileCardWidget({super.key, required this.config});

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends BaseState<ProfileCardWidget> {
  late String patientName;
  late int phoneNumber;
  late int age;
  late String bloodGroup;
  late double height;
  late double weight;
  late Color cardBgColor;
  late String profileIcon;
  late FontConfig nameFont;
  late FontConfig numberFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    patientName = config.patientName;
    phoneNumber = config.phoneNumber;
    age = config.age;
    bloodGroup = config.bloodGroup;
    height = config.height;
    weight = config.weight;
    profileIcon = config.profileIcon;
    cardBgColor = Color(config.cardBgColor);
    nameFont = FontConfig.fromJson(config.nameFont);
    numberFont = FontConfig.fromJson(config.numberFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    isValidConfig = patientName.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Center(
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              // Wrap the column with SingleChildScrollView
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  divider(height: 15),
                  CircleAvatar(
                    radius: 40,
                    child: profileIcon.isNotEmpty
                        ? SizedBox(
                            height: 60,
                            width: 60,
                            child: TwinImageHelper.getDomainImage(profileIcon))
                        : const Icon(Icons.person_2_rounded, size: 60),
                  ),
                  divider(height: 10),
                  Text(
                    patientName,
                    style: TwinUtils.getTextStyle(nameFont),
                  ),
                  divider(height: 5),
                  Text(
                    '$phoneNumber',
                    style: TwinUtils.getTextStyle(numberFont),
                  ),
                  divider(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Details',
                      style: TwinUtils.getTextStyle(labelFont),
                    ),
                  ),
                  const Divider(height: 30),
                  buildDetailRow('Age', '$age Year'),
                  divider(height: 10),
                  buildDetailRow('Blood Group', bloodGroup),
                  divider(height: 10),
                  buildDetailRow('Height (m)', '$height'),
                  divider(height: 10),
                  buildDetailRow('Weight (Kg)', '$weight'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build each detail row
  Row buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label :',
          style: TwinUtils.getTextStyle(labelFont),
        ),
        Text(
          value,
          style: TwinUtils.getTextStyle(valueFont),
        ),
      ],
    );
  }

  @override
  void setup() {}
}

class ProfileCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return ProfileCardWidget(
      config: ProfileCardWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.person_pin_outlined);
  }

  @override
  String getPaletteName() {
    return "Profile Card widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return ProfileCardWidgetConfig.fromJson(config);
    }
    return ProfileCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Profile Card widget';
  }
}
