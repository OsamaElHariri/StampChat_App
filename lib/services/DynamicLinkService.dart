import 'package:StampChat/models/Channel.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {
  static Future<Uri> createLink(Channel channel) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "http://stampchat.page.link",
      link: Uri.parse("http://stampchat.page.link/${channel.topic}"),
      androidParameters: AndroidParameters(
        packageName: 'com.osama.StampChat',
        minimumVersion: 0,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "StampChat: ${channel.name}",
        description:
            "StampChat invite link! Follow this link to join the chat \"${channel.name}\"",
      ),
    );

    return (await parameters.buildShortLink()).shortUrl;
  }
}
