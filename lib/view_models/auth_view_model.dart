import 'dart:developer';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../exceptions/app_exception.dart';
import '../main.dart';
import '../models/base_state_model.dart';
import '../models/requests/onboarding_profile_request.dart';
import '../models/requests/otp_request.dart';
import '../models/requests/sign_in_request.dart';
import '../models/responses/address_data.dart';
import '../models/responses/appointments_list_response.dart';
import '../models/responses/auth_response.dart';
import '../models/responses/base_response_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_base_helper.dart';
import '../services/apple_auth_service.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import '../utils/biometric_helper.dart';
import '../utils/enums.dart';
import '../utils/secure_storage_service.dart';
import 'base_view_model.dart';

final authViewModel = NotifierProvider(() {
  final apiBaseHelper = ApiBaseHelper();
  final authService = AuthService(apiClient: apiBaseHelper);
  return AuthViewModel(authRepository: authService);
});

class AuthViewModel extends BaseViewModel<AuthState> {
  AuthViewModel({required this._authRepository})
    : super(initialState: AuthState(country: Country.parse('US')));

  final AuthRepository _authRepository;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  TextEditingController get phoneController => _phoneController;
  TextEditingController get nameController => _nameController;
  TextEditingController get dobController => _dobController;

  TextEditingController get passwordController => _passwordController;

  @override
  void init() {
    super.init();
    checkBiometricAvailability();
  }

  Future<void> checkBiometricAvailability() async {
    final result = await SecureStorage().getSecureString(
      key: SharedPreferencesKeys.biometricAuthKey.keyText,
    );
    final isAvailable = result != null;
    IconData? icon;
    if (isAvailable) {
      icon = await BiometricHelper().getBiometricIcon();
    }
    state = state.copyWith(
      isBiometricAvailable: isAvailable,
      biometricIcon: icon,
    );
  }

  Future<void> pickProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      await runSafely(() async {
        await EasyLoading.show(status: 'Loading....');
        final String? imageUrl = await MediaService().uploadImage(
          acceptAnyFormat: true,
          state.authData?.user?.primaryEmail ?? '',
          image,
        );
        if (imageUrl != null && state.authData?.user != null) {
          state = state.copyWith(profileImage: imageUrl);
          await EasyLoading.dismiss();
        }
      });
    } catch (e) {
      await EasyLoading.dismiss();
      onError('Error picking image: $e');
    }
  }

  Future<String?> uploadDocument({
    required ImageSource source,
    required String documentType, // e.g., 'driving_license' or 'passport'
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Retains high detail for readability
      );

      if (image == null) return null;

      String? uploadedUrl;

      await runSafely(() async {
        await EasyLoading.show(status: 'Uploading document...');

        final String userEmail = state.authData?.user?.primaryEmail ?? '';

        // Upload via MediaService
        uploadedUrl = await MediaService().uploadImage(
          acceptAnyFormat: true,
          '$userEmail/$documentType', // optional path subfolder organization
          image,
        );

        if (uploadedUrl != null) {
          await EasyLoading.dismiss();
          EasyLoading.showSuccess('Document uploaded successfully!');
        } else {
          await EasyLoading.dismiss();
          EasyLoading.showError('Failed to upload document');
        }
      });

      return uploadedUrl;
    } catch (e) {
      await EasyLoading.dismiss();
      onError('Error picking document: $e');
      return null;
    }
  }

  void setCountryCode(Country country) {
    state = state.copyWith(country: country);
  }

  void clearProfileImage() {
    state = state.copyWith(clearProfileImage: true);
  }

  // Validate OTP
  bool validateOtp() {
    String otp = otpController.text.trim();
    String? errorMessage;

    if (otp.isEmpty) {
      errorMessage = "Please enter the OTP";
    } else if (otp.length != 6) {
      errorMessage = "OTP must be 6 digits long";
    }

    if (errorMessage != null) {
      state = state.copyWith(otpError: errorMessage);
      return false;
    }

    state = state.copyWith(clearOtpError: true);
    return true;
  }

  Future<bool?> callSignInApi(BaseSignInRequest request) async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);
      final BaseResponseModel response = await _authRepository.signInApi(
        signInRequest: request,
      );
      state = state.copyWith(loading: false);
      return response.isSuccess == true;
    });
  }

  Future<bool?> callBiometricRegisterApi() async {
    return await runSafely(() async {
      EasyLoading.show(status: "Please wait");
      final BaseResponseModel response = await _authRepository
          .biometricRegisterApi();
      EasyLoading.showSuccess(response.message.toString());
      if (response.isSuccess == true) {
        await checkBiometricAvailability();
      }
      return response.isSuccess == true;
    });
  }

  Future<bool?> callBiometricUnregisterApi({
    required bool showLoader,
    String? savedEmail,
    String? currentEmail,
  }) async {
    // 1. If biometric key is not saved locally, there is nothing to unregister on the server.
    // Return early silently to prevent making unnecessary API calls that throw "no biometric key found".
    final localKey = await SecureStorage().getSecureString(
      key: SharedPreferencesKeys.biometricAuthKey.keyText,
    );
    if (localKey == null) {
      state = state.copyWith(isBiometricAvailable: false, biometricIcon: null);
      return true;
    }
    // 1.1. If the logged in user has the same email as the email from storage,
    //      then we don't unregister the user.
    log('CURRENT: $currentEmail');
    log('SAVED: $savedEmail');
    if (savedEmail != null &&
        currentEmail != null &&
        savedEmail == currentEmail) {
      log('CURRENT AND SAVED EMAIL SAME, NOT UNREGISTERING BIOMETRIC');
      return true;
    }

    // 2. Perform the unregister but catch any API errors silently so it doesn't disturb the login flow
    try {
      state = state.copyWith(loading: true);
      if (showLoader) {
        EasyLoading.show(status: 'Please wait...');
      }
      final BaseResponseModel response = await _authRepository
          .biometricUnregister();
      state = state.copyWith(loading: false);
      if (response.isSuccess == true) {
        state = state.copyWith(
          isBiometricAvailable: false,
          biometricIcon: null,
        );
      }
      EasyLoading.dismiss();
      return response.isSuccess == true;
    } catch (e) {
      log(
        "Silent biometric unregister failed: $e. This is expected if the key does not exist on the server database.",
      );
      state = state.copyWith(
        loading: false,
        isBiometricAvailable: false,
        biometricIcon: null,
      );
      EasyLoading.dismiss();
      return true; // Return true as a fallback so login flow continues undisturbed
    }
  }

  Future<bool?> callBiometricLoginApi() async {
    return await runSafely<bool>(() async {
      state = state.copyWith(loading: true);
      final AuthResponse response = await _authRepository.biometricLoginApi();
      if (response.isSuccess == true) {
        state = state.copyWith(authData: response.data);
        final isUpdateAvailable = await response.data?.isUpdateAvailable();
        if (isUpdateAvailable ?? false) {
          throw const UpdateAppException();
        }
        if (!isDeploymentMode) {
          _fetchLocationInBackground();
        }

        state = state.copyWith(loading: false);
        return true;
      }
      state = state.copyWith(loading: false, authData: response.data);
      return false;
    });
  }

  Future<bool?> callVerifyOtpApi() async {
    String? fcmToken = await _getFcmToken();
    final request = OtpRequest(
      email: emailController.text,
      otp: otpController.text,
      fcmToken: fcmToken ?? '',
    );
    return await runSafely(() async {
      final savedEmail = await SecureStorage().getUserEmail();
      state = state.copyWith(loading: true);
      final AuthResponse response = await _authRepository.verifyOTP(
        otpRequest: request,
      );

      state = state.copyWith(loading: false, authData: response.data);

      if (response.isSuccess == true) {
        otpController.clear();
        final isUpdateAvailable = await response.data?.isUpdateAvailable();
        if (isUpdateAvailable ?? false) {
          throw const UpdateAppException();
        }
        await callBiometricUnregisterApi(
          showLoader: false,
          currentEmail: response.data?.user?.primaryEmail,
          savedEmail: savedEmail,
        );
        // TODO: Research if this is needed
        // _fetchLocationInBackground();
      }
      return response.isSuccess == true;
    });
  }

  Future<bool?> callOnboardingProfileApi() async {
    return await runSafely(() async {
      state = state.copyWith(loading: true);

      final request = OnBoardingProfileRequest(
        name: nameController.text,
        phoneNumber: phoneController.text,
        emailAddress: emailController.text,
        location: '',
        bio: '',
        cc: '+${state.country.phoneCode}',
        country: state.country.name,
        profileImageUrl:
            state.profileImage ?? state.authData?.user?.profileImageUrl,
        dob: dobController.text,
      );
      log('SDFSDXgs--$request');
      final BaseResponseModel response = await _authRepository
          .onboardingProfile(onBoardingProfileRequest: request);

      if (response.isSuccess == true) {
        await callGetMe();
        clearProfileImage();
      }
      state = state.copyWith(loading: false);
      return response.isSuccess == true;
    });
  }

  Future<AuthData?> callGetMe() async {
    return await runSafely(() async {
      try {
        final authData = await _authRepository.getMe();
        state = state.copyWith(authData: authData);
        log('get me call successful,');
        // Location is fetched in background to avoid blocking the UI thread during splash/init
        if (!isDeploymentMode) {
          _fetchLocationInBackground();
        }

        return authData;
      } on AppException catch (e) {
        if (e.message == 'No Internet Connection') {
          return null;
        }
        rethrow;
      } catch (_) {
        rethrow;
      }
    });
  }

  Future<void> fetchLocation([bool shouldThrow = false]) async {
    if (state.addressData != null) return;
    await _fetchLocationInBackground(shouldThrow);
  }

  Future<void> _fetchLocationInBackground([bool shouldThrow = false]) async {
    try {
      final addressData = await LocationService().fetchAddress();
      state = state.copyWith(addressData: addressData);
    } catch (e) {
      EasyLoading.showError('Location fetch failed: $e');
      log('Background location fetch skipped or failed: $e');
      if (shouldThrow) {
        rethrow;
      }
    }
  }

  Future<bool?> callGoogleSignInApi() async {
    return await runSafely<bool>(() async {
      state = state.copyWith(loading: true);
      final savedEmail = await SecureStorage().getUserEmail();
      final user = await GoogleAuthService().signIn();
      final idToken = await user.getIdToken();
      String? fcmToken = await _getFcmToken();

      log("google sign IDToken ${idToken.toString}");
      String type = Platform.isIOS ? 'apple' : 'android';
      final AuthResponse response = await _authRepository.googleSignInApi(
        request: SocialLoginRequest(
          deviceType: type,
          idToken: idToken.toString(),
          fcmToken: fcmToken ?? '',
        ),
      );
      if (response.isSuccess ?? false) {
        final isUpdateAvailable = await response.data?.isUpdateAvailable();
        if (isUpdateAvailable ?? false) {
          throw const UpdateAppException();
        }
        await callBiometricUnregisterApi(
          showLoader: false,
          currentEmail: response.data?.user?.primaryEmail,
          savedEmail: savedEmail,
        );
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        if (ref.mounted) {
          state = state.copyWith(loading: false, authData: response.data);
        }
      });
      return response.isSuccess ?? false;
    });
  }

  Future<bool?> callAppleSignInApi() async {
    String type = Platform.isIOS ? 'apple' : 'android';
    return await runSafely<bool>(() async {
      state = state.copyWith(loading: true);
      final savedEmail = await SecureStorage().getUserEmail();
      final user = await AppleAuthService().signIn();
      final idToken = await user.getIdToken();
      String? fcmToken = await _getFcmToken();
      final response = await _authRepository.appleSignInApi(
        request: SocialLoginRequest(
          deviceType: type,
          idToken: idToken.toString(),
          fcmToken: fcmToken ?? '',
        ),
      );
      if (response.isSuccess ?? false) {
        await callBiometricUnregisterApi(
          showLoader: false,
          currentEmail: response.data?.user?.primaryEmail,
          savedEmail: savedEmail,
        );
      }
      state = state.copyWith(loading: false, authData: response.data);
      return response.isSuccess ?? false;
    });
  }

  void clearData() {
    emailController.clear();
    otpController.clear();
    dobController.clear();
    phoneController.clear();
    clearProfileImage();
  }

  Future<String?> _getFcmToken() async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          log("APNS token not available yet, FCM token will be fetched later.");
          return null;
        }
      }
      final token = await FirebaseMessaging.instance.getToken();
      log('FCM TOKEN: $token');
      return token;
    } catch (e) {
      log("Error getting FCM token: $e");
      return null;
    }
  }

  void addAppointment(AppointmentItem appointment) {
    state = state.copyWith(
      authData: state.authData?.copyWith(
        dashboard: state.authData!.dashboard?.copyWith(
          appointments: [
            appointment,
            ...state.authData!.dashboard!.appointments!,
          ],
        ),
      ),
    );
  }

  @override
  Future<void> onError(String message) async {
    super.onError(message);
    state = state.copyWith(loading: false, errorMessage: message);
  }

  @override
  void onCancel() {
    state = state.copyWith(loading: false);
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}

@immutable
class AuthState extends BaseStateModel {
  final AuthData? authData;
  final String? otpError;
  final String? profileImage;
  final AddressData? addressData;
  final bool isBiometricAvailable;
  final IconData? biometricIcon;
  final Country country;
  const AuthState({
    super.loading = false,
    super.errorMessage,
    this.authData,
    this.otpError,
    this.profileImage,
    this.addressData,
    this.isBiometricAvailable = false,
    this.biometricIcon,
    required this.country,
  });

  @override
  AuthState copyWith({
    bool? loading,
    String? errorMessage,
    bool? loginWithEmail,
    bool? loginWithPhone,
    String? build,
    String? device,
    String? version,
    AuthData? authData,
    String? otpError,
    bool clearOtpError = false,
    String? profileImage,
    bool clearProfileImage = false,
    AddressData? addressData,
    bool? isBiometricAvailable,
    IconData? biometricIcon,
    Country? country,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      authData: authData ?? this.authData,
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      profileImage: clearProfileImage
          ? null
          : (profileImage ?? this.profileImage),
      addressData: addressData ?? this.addressData,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      biometricIcon: biometricIcon ?? this.biometricIcon,
      country: country ?? this.country,
    );
  }
}
