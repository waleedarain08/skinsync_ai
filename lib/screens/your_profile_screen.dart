import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/image_source_dialog.dart';
import '../widgets/phone_widget.dart';
import 'terms_of_service_screen.dart';

class YourProfileScreen extends ConsumerStatefulWidget {
  const YourProfileScreen({super.key});
  static const String routeName = '/YourProfileScreen';

  @override
  ConsumerState<YourProfileScreen> createState() => _YourProfileScreenState();
}

class _YourProfileScreenState extends ConsumerState<YourProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime? _selectedDob;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authViewModel);
    final authVM = ref.read(authViewModel.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authVM.emailController.text =
          authState.authData?.user?.primaryEmail ?? '';
      authVM.nameController.text = authState.authData?.user?.name ?? '';
      final cc = authState.authData?.user?.cc;
      ref
          .read(authViewModel.notifier)
          .setCountryCode(Country.parse(cc ?? "US"));
    });
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime initialDate =
        _selectedDob ?? DateTime.now().subtract(const Duration(days: 18 * 365));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.darkPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final age = _calculateAge(picked);
      if (age < 18) {
        if (!mounted) return;
        _showUnderageDialog();
      } else {
        setState(() {
          final authVM = ref.read(authViewModel.notifier);
          _selectedDob = picked;
          authVM.dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }
  }

  void _showUnderageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(16)),
          ),
          title: Text('Age Restriction', style: CustomFonts.black20w600),
          content: Text(
            'You are not authorized to use this app because you must be at least 18 years old.',
            style: CustomFonts.black16w400,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final authVM = ref.read(authViewModel.notifier);
                authVM.dobController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: CustomFonts.black14w500.copyWith(
                  color: CustomColors.purpleColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showImageSourceDialog(context);
    if (source != null) {
      ref.read(authViewModel.notifier).pickProfileImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = ref.watch(authViewModel).profileImage;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minHeight: MediaQuery.heightOf(context)),
        decoration: const BoxDecoration(
          gradient: CustomColors.purpleWhiteBlueGradient,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(30)),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.h(104)),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipOval(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: profileImage != null
                            ? Image.network(
                                profileImage,
                                fit: BoxFit.cover,
                                height: context.w(75),
                                width: context.w(75),
                              )
                            : Image.asset(
                                DummyAssets.profile,
                                fit: BoxFit.cover,
                                height: context.w(75),
                                width: context.w(75),
                              ),
                      ),
                      Positioned(
                        bottom: -6,
                        right: -6,
                        child: Container(
                          height: context.w(35),
                          width: context.w(35),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: _showImageSourceDialog,
                              icon: Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black,
                                size: context.w(21),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(27)),
                  Text("Your Profile", style: CustomFonts.black30w600),
                  SizedBox(height: context.h(4)),
                  Text(
                    "Create your profile to personalize your SkinSync experience.",
                    style: CustomFonts.black18w400,
                  ),
                  SizedBox(height: context.h(22)),
                  TextFormField(
                    controller: ref.read(authViewModel.notifier).nameController,
                    style: CustomFonts.black18w400,
                    decoration: const InputDecoration(hintText: "Your Name"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  PhoneWidget(
                    enableCountrySelection: !isDeploymentMode,
                    controller: ref
                        .read(authViewModel.notifier)
                        .phoneController,
                    initialCountryCode: ref
                        .read(authViewModel)
                        .country
                        .countryCode,
                    onCountryChanged: (country) {
                      ref.read(authViewModel.notifier).setCountryCode(country);
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  TextFormField(
                    readOnly: true,
                    controller: ref
                        .read(authViewModel.notifier)
                        .emailController,
                    style: CustomFonts.black18w400,
                    decoration: const InputDecoration(
                      hintText: "Email Address",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegExp = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegExp.hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(20)),
                  // Date of Birth Field
                  TextFormField(
                    controller: ref.read(authViewModel.notifier).dobController,
                    readOnly: true,
                    onTap: () => _selectDateOfBirth(context),
                    style: CustomFonts.black18w400,
                    decoration: InputDecoration(
                      hintText: "Date of Birth (YYYY-MM-DD)",
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: CustomColors.darkPurple,
                        size: context.w(20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: context.h(35)),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      isLoading: ref.watch(authViewModel).loading,
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_selectedDob != null &&
                              _calculateAge(_selectedDob!) < 18) {
                            _showUnderageDialog();
                            return;
                          }
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            TermsOfServiceScreen.routeName,
                            (Route<dynamic> route) => false,
                          );
                          // ref
                          //     .read(authViewModel.notifier)
                          //     .callOnboardingProfileApi(
                          //       name: _nameController.text,
                          //       phoneNumber: _phoneController.text.trim(),
                          //      emailAddress: _emailController.text.trim(),
                          //       // dob: _dobController.text, // Pass dob here if supported by your ViewModel
                          //     )
                          //     .then((value) {
                          //   if (value == true) {
                          //     Navigator.pushNamedAndRemoveUntil(
                          //       context,
                          //       TermsOfServiceScreen.routeName,
                          //       (Route<dynamic> route) => false,
                          //     );
                          //   }
                          // });
                        }
                      },
                      text: "Next",
                    ),
                  ),
                  SizedBox(height: context.h(30)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
