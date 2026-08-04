import 'package:get/get.dart';
import 'package:jimamuapp/data/models/rider_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../routes/app_routes.dart';
import '../utils/snakckbar_helper.dart';

class AuthController extends GetxController {
  var email = ''.obs;
    var token = ''.obs;
  var user = Rxn<UserModel>();
  var riderProfile = Rxn<RiderProfile>();

  void setEmail(String value) {
    email.value = value;
  }

  void setToken(String value) {
    token.value = value;
  }

  void setUserProfile(UserModel userProfile) {
    user.value = userProfile;
  }

  void setRiderProfile(RiderProfile rider) {
    riderProfile.value = rider;
  }

  logOut() async {
    await AuthService.clearToken();
    AppSnackbar.error( "Your session has been expired!");
    Get.offAllNamed(AppRoutes.signIn);
  }

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackbar.error( 'Could not launch $url');
    }
  }
}
