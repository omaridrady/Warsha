import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CommunicationService {

  // 1. Logic for Phone Calls
  static Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await  canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
    } else {
    print('Could not launch dialer for $phoneNumber');
    }
  }

  // 2. Logic for WhatsApp
  static Future<void> launchWhatsApp(String phoneNumber) async {
    // 1. Clean the number and add Jordan country code '962'
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '962' + cleanNumber.substring(1);
    }

    // 2. Build the Universal WhatsApp URI
    // This is the most reliable format for both iOS and Android
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanNumber");

    try {
      // 3. Launch it specifically as an external application
      // Using externalApplication forces it to look for the WhatsApp App
      // instead of opening an in-app browser.
      bool launched = await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication
      );

      if (!launched) {
        print('Could not launch WhatsApp - App might not be installed');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }
}