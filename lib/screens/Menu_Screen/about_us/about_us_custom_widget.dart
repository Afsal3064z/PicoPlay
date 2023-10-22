import 'package:flutter/material.dart';
import 'package:picoplay/screens/Menu_Screen/menu_screen.dart';
import 'package:picoplay/screens/Menu_Screen/privacy_policy_screen/privacy_policy_custom_text_widget.dart';

///This is the custom list view for the about us page///
class AboutUsCustomListView extends StatelessWidget {
  const AboutUsCustomListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(shrinkWrap: true, children: const [
//////////////////////////////////////////////////////
      // The custom Text widget we had called//
      Padding(
        padding: EdgeInsets.all(18.0),
        child: Column(
          children: [
            CustomText(
              text: "About Pico player",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "At Brototype, we are passionate about delivering an exceptional video playback experience. Our mission is to provide you with a seamless and immersive way to enjoy your favorite videos, whether you're watching movies, TV shows, educational content, or anything in between.",
              size: 18,
            ),
            CustomText(
              text: "What Sets Us Apart",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "We understand that watching videos is a deeply personal experience, and that's why we've poured our expertise into creating Pico player. Here's what sets us apart:",
              size: 18,
            ),
            CustomText(
              text:
                  "Cutting-Edge Technology:** Our video player is powered by cutting-edge technology that ensures smooth playback, sharp visuals, and crystal-clear audio. We're constantly pushing the boundaries to bring you the best possible viewing experience.",
              size: 18,
            ),
            CustomText(
              text:
                  "User-Centric Design:** We've designed our video player with you in mind. It's intuitive, easy to use, and packed with features that enhance your viewing pleasure. Whether you're streaming online or playing local files, we've got you covered.",
              size: 18,
            ),
            CustomText(
              text:
                  "When you use our video player, certain information may be collected automatically, such as:Device information (e.g., device type, operating system)Usage information (e.g., videos watched, interactions with the video player)",
              size: 18,
            ),
            CustomText(
              text: "Personalization",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  " We believe in personalization because everyone's taste is unique. Our video player learns from your viewing habits to provide tailored recommendations, so you can discover new content you'll love.",
              size: 18,
            ),
            CustomText(
              text: "Privacy and Security",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  " Your privacy matters to us. We take data security seriously, and we're committed to protecting your personal information while you enjoy our video player.",
              size: 17,
            ),
            CustomText(
              text: " Support and Community",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "Our dedicated support team is here to assist you with any questions or issues you may encounter. We value our community of users and are always eager to hear your feedback and suggestions.",
              size: 18,
            ),
            CustomText(
              text: "Our Vision",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "We envision a world where video content is an enriching and accessible source of entertainment, education, and inspiration for all.Pico player is our contribution to making this vision a reality.",
              size: 18,
            ),
            CustomText(
              text: "Join Us on this Journey",
              size: 20,
              isBold: true,
            ),
            CustomText(
              text:
                  "We invite you to join us on this exciting journey of video discovery, exploration, and enjoyment. Download Pico player today and experience a new level of video playback excellence.",
              size: 18,
            ),
            CustomText(
              text:
                  "Thank you for choosing Pico player. We look forward to enhancing your video-watching experience and being a part of your entertainment journey.",
              size: 18,
            ),
          ],
        ),
      ),
    ]);
  }
}

///This is the custom appber for the menu infos///
//////////////////////////////////////////////////////////////
class CustomMenuAppBar extends StatelessWidget {
  const CustomMenuAppBar({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: TextButton(
        onPressed: () {
          Navigator.pop(context,
              MaterialPageRoute(builder: (context) => const MenuPage()));
        },
        child: const Icon(
          Icons.navigate_before,
          color: Colors.white,
          size: 36,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
