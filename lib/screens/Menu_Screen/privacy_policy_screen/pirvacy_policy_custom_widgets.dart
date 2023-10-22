/// This is the custom widgets of the privacy policy  screen///
import 'package:flutter/material.dart';
import 'package:picoplay/screens/Menu_Screen/privacy_policy_screen/privacy_policy_custom_text_widget.dart';

//////////////////////////////////////////////////////////////////////////////////////
// This the list view of the privacy policy screen//
class PrivacyPolicyCustomListView extends StatelessWidget {
  const PrivacyPolicyCustomListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: const [
//////////////////////////////////////////////////////
      // The custom Text widget we had created//
      Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          children: [
            CustomText(
              text: "Privacy Policy for Pico Player",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text: "Last Updated: [12/09/2023]",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text: "Introduction",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text: "Welcome to My application! ",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "This privacy policy explains how we collect, use, and protect your personal information when you use our video player. We are committed to protecting your privacy and ensuring the security of your data",
              size: 18,
            ),
            CustomText(
              text: "Automatically Collected Information",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "When you use our video player, certain information may be collected automatically, such as:Device information (e.g., device type, operating system)Usage information (e.g., videos watched, interactions with the video player)",
              size: 18,
            ),
            CustomText(
              text: "How We Use Your Information",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "We may use the collected information for the following purposes:",
              size: 18,
            ),
            CustomText(
              text: "To provide and improve our video player and services.",
              size: 17,
            ),
            CustomText(
              text:
                  "To personalize your video player experience and offer content recommendations.",
              size: 17,
            ),
            CustomText(
              text:
                  "To communicate with you, respond to inquiries, and provide support.",
              size: 17,
            ),
            CustomText(
              text: "Security",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "We employ reasonable security measures to protect your personal information from unauthorized access and data breaches.",
              size: 17,
            ),
            CustomText(
              text: "Children's Privacy",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "Our video player is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13 years of age.",
              size: 17,
            ),
            CustomText(
              text: "Changes to this Privacy Policy",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  'We may update this privacy policy periodically. Any changes will be posted within the video player application, and the "Last Updated" date will be revised accordingly.',
              size: 17,
            ),
            CustomText(
              text: "Contact Us",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "If you have questions, concerns, or requests regarding this privacy policy or our data practices, please contact  me at afsal.achu3064z@gmail.com.",
              size: 17,
            )
          ],
        ),
      ),
    ]);
  }
}
