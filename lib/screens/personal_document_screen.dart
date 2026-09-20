import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/dialogs/image_source_dialog.dart';
import '../widgets/app_network_image.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class PersonalDocumentScreen extends ConsumerStatefulWidget {
  const PersonalDocumentScreen({super.key});
  static const String routeName = '/PersonalDocumentScreen';

  @override
  ConsumerState<PersonalDocumentScreen> createState() =>
      _PersonalDocumentScreenState();
}

class _PersonalDocumentScreenState
    extends ConsumerState<PersonalDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Document states (replace with your dynamic URLs/paths from AuthViewModel state)
  String? _drivingLicenseUrl;
  String? _passportUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Future<void> _onSavePressed() async {
    // final success = await ref
    //     .read(authViewModel.notifier)
    //     .callOnboardingProfileApi(
    //       name: _nameController.text,
    //       phoneNumber: _phoneController.text.trim(),
    //       emailAddress: _emailController.text.trim(),
    //       location: '',
    //       bio: '',
    //     );
    // if (success ?? false) {
    //   EasyLoading.showSuccess('Profile updated!');
  }

  Future<void> _showImageSourceDialog({
    required Function(ImageSource source) onSelect,
  }) async {
    final source = await showImageSourceDialog(context);
    if (source != null) {
      onSelect(source);
    }
  }

  Future<void> _pickDocumentImage({required bool isDrivingLicense}) async {
    _showImageSourceDialog(
      onSelect: (source) async {
        final String docType = isDrivingLicense
            ? 'driving_license'
            : 'passport';

        final uploadedUrl = await ref
            .read(authViewModel.notifier)
            .uploadDocument(source: source, documentType: docType);

        if (uploadedUrl != null) {
          setState(() {
            if (isDrivingLicense) {
              _drivingLicenseUrl = uploadedUrl;
            } else {
              _passportUrl = uploadedUrl;
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(showTitle: true, title: "Personal Documents"),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(24),
            vertical: context.h(10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Identity Documents", style: CustomFonts.black16w600),
                SizedBox(height: context.h(4)),
                Text(
                  "Upload clear photos of your official identity documents.",
                  style: CustomFonts.grey14w400,
                ),
                SizedBox(height: context.h(16)),

                // Driving License Card
                _buildDocumentCard(
                  title: "Driving License",
                  imageUrl: _drivingLicenseUrl,
                  onTapUpload: () => _pickDocumentImage(isDrivingLicense: true),
                ),
                SizedBox(height: context.h(16)),

                // Passport Card
                _buildDocumentCard(
                  title: "Passport",
                  imageUrl: _passportUrl,
                  onTapUpload: () =>
                      _pickDocumentImage(isDrivingLicense: false),
                ),
                SizedBox(height: context.h(20)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: context.w(24),
            right: context.w(24),
            top: context.h(12),
            bottom: MediaQuery.paddingOf(context).bottom + context.h(30),
          ),
          child: Consumer(
            builder: (_, ref, _) {
              final loading = ref.watch(authViewModel.select((s) => s.loading));

              return SizedBox(
                height: context.h(52),
                width: double.infinity,
                child: loading
                    ? const AppLoader()
                    : CustomButton(
                        text: "Save Changes",
                        isLoading: loading,
                        onPressed: _onSavePressed,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String? imageUrl,
    required VoidCallback onTapUpload,
  }) {
    final bool isUploaded = imageUrl != null && imageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomFonts.black14w600),
        SizedBox(height: context.h(8)),
        InkWell(
          onTap: onTapUpload,
          borderRadius: BorderRadius.circular(context.r(16)),
          child: Container(
            height: context.h(150),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(
                color: isUploaded
                    ? CustomColors.purpleColor.withValues(alpha: 0.5)
                    : CustomColors.greyColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                if (isUploaded) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(15)),
                    child: imageUrl.startsWith('http')
                        ? AppNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: context.h(10),
                    right: context.w(10),
                    child: Container(
                      padding: EdgeInsets.all(context.w(6)),
                      decoration: BoxDecoration(
                        color: CustomColors.darkPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.edit_2,
                        size: context.w(16),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.w(12)),
                          decoration: BoxDecoration(
                            color: CustomColors.purpleColor.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Iconsax.document_upload,
                            color: CustomColors.purpleColor,
                            size: context.w(26),
                          ),
                        ),
                        SizedBox(height: context.h(10)),
                        Text(
                          "Tap to upload $title",
                          style: CustomFonts.grey14w400.copyWith(
                            color: CustomColors.purpleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          "JPG, PNG or PDF up to 10MB",
                          style: CustomFonts.grey12w400,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
