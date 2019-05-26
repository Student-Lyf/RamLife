import "package:firebase_dynamic_links/firebase_dynamic_links.dart";

final FirebaseDynamicLinks firebase = FirebaseDynamicLinks.instance;

Future<Uri> getLink() async => (await firebase.retrieveDynamicLink())?.link;