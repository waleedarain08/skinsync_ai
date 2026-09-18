import 'dart:developer';

import 'package:flutter/material.dart';

import 'models/treatment_progress/treatment_progress.dart';
import 'models/requests/preferred_slot.dart';
import 'models/responses/appointments_list_response.dart';
import 'models/responses/appointment_detail_response.dart';
import 'models/responses/get_clinic_response.dart';
import 'models/responses/patient_treatment_request_response.dart';
import 'models/responses/simulation_history_response.dart';
import 'models/responses/treatment_area_list_response.dart';
import 'models/responses/treatment_category_list_response.dart';
import 'models/responses/treatment_list_response.dart';
import 'screens/clinical_journey/clinical_journey_screen.dart';
import 'screens/my_care_screen.dart';
import 'screens/additional_info_screen.dart';
import 'screens/allergy_and_medical_history.dart';
import 'screens/appointment_detail_screen.dart';
import 'screens/appointment_forms_screen.dart';
import 'screens/ar_face_model_preview_screen.dart';
import 'screens/biometric_screen.dart';
import 'screens/bottom_nav_page.dart';
import 'screens/bottom_nav_screens/appointments_screen.dart';
import 'screens/bottom_nav_screens/face_detection_screen.dart';
import 'screens/bottom_nav_screens/home_screen.dart';
import 'screens/bottom_nav_screens/my_profile_screen.dart';
import 'screens/bottom_nav_screens/reels_screen.dart';
import 'screens/bottom_nav_screens/treatment_explore_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/clinic_service_screen.dart';
import 'screens/clinics_detail_screen.dart';
import 'screens/compliance_form_screen.dart';
import 'screens/consent_detail_screen.dart';
import 'screens/consent_forms_screen.dart';
import 'screens/consent_forms/ai_transparency_policy_screen.dart';
import 'screens/consent_forms/face_consent_screen.dart';
import 'screens/doctor_detail_screen.dart';
import 'screens/treatment_progress/treatment_progress_detail_screen.dart';
import 'screens/treatment_progress/my_treatment_progress_screen.dart';
import 'screens/legal_document_screen.dart';
import 'screens/doctors_screen.dart';
import 'screens/explore_clinics_screen.dart';
import 'screens/face_pose_capture_screen.dart';
import 'screens/face_scan_screen.dart';
import 'screens/get_notified_screen.dart';
import 'screens/get_started_screen.dart';
import 'screens/help_chat_screen.dart';
import 'screens/new_patient_intake_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/journey_clinic_detail_screen.dart';
import 'screens/journey_clinics_screen.dart';
import 'screens/login_bottom_screen.dart';
import 'screens/login_screen.dart';
import 'screens/medical_disclaimer_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/patient_treatment_request_detail_screen.dart';
import 'screens/patient_treatment_requests_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/pdf_viewer_screen.dart';
import 'screens/personal_detail_screen.dart';
import 'screens/personal_document_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/progress_detail_screen.dart';
import 'screens/review_screen.dart';
import 'screens/saved_treatment_screen.dart';
import 'screens/select_appointment_type_screen.dart';
import 'screens/select_date_time_screen.dart';
import 'screens/select_product_screen.dart';
import 'screens/shared_treatment_requests_screen.dart';
import 'screens/subscription_plans_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/signup_onboarding.dart';
import 'screens/simulation_history_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/treatment_area_screen.dart';
import 'screens/treatment_category_screen.dart';
import 'screens/treatment_detail_screen.dart';
import 'screens/treatment_request_detail_screen.dart';
import 'screens/treatment_requests_screen.dart';
import 'screens/treatment_payment_screen.dart';
import 'screens/treatment_review_screen.dart';
import 'screens/treatments_screen.dart';
import 'screens/update_version_screen.dart';
import 'screens/your_profile_screen.dart';
import 'utils/enums.dart';
import 'widgets/custom_app_bar.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    log('Navigating to ${settings.name} with args: $args');
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SplashScreen.routeName),
          builder: (_) => const SplashScreen(),
        );
      case HomeScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: HomeScreen.routeName),
          builder: (_) => const HomeScreen(),
        );
      case GetStartedScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: GetStartedScreen.routeName),
          builder: (_) => const GetStartedScreen(),
        );
      case NewPatientIntakeScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: NewPatientIntakeScreen.routeName),
          builder: (_) => const NewPatientIntakeScreen(),
        );
      case HelpChatScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: HelpChatScreen.routeName),
          builder: (_) => const HelpChatScreen(),
        );
      case LegalDocumentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: LegalDocumentScreen.routeName),
          builder: (_) => LegalDocumentScreen(args: args as LegalDocumentArgs),
        );
      case AiTransparencyPolicyScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: AiTransparencyPolicyScreen.routeName,
          ),
          builder: (_) => AiTransparencyPolicyScreen(
            onPolicyAccepted: args as VoidCallback?,
          ),
        );
      case FaceConsentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: FaceConsentScreen.routeName),
          builder: (_) => const FaceConsentScreen(),
        );
      case IntroScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: IntroScreen.routeName),
          builder: (_) => const IntroScreen(),
        );
      case ConsentFormsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ConsentFormsScreen.routeName),
          builder: (_) => const ConsentFormsScreen(),
        );
      case ComplianceFormsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ComplianceFormsScreen.routeName),
          builder: (_) => const ComplianceFormsScreen(),
        );
      case ConsentDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ConsentDetailScreen.routeName),
          builder: (_) => const ConsentDetailScreen(),
        );
      case LoginScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: LoginScreen.routeName),
          builder: (_) => LoginScreen(loginWith: args as LoginProviders),
        );
      case OtpScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: OtpScreen.routeName),
          builder: (_) => const OtpScreen(),
        );
      case SignupOnboarding.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SignupOnboarding.routeName),
          builder: (_) => const SignupOnboarding(),
        );
      case YourProfileScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: YourProfileScreen.routeName),
          builder: (_) => const YourProfileScreen(),
        );
      case GetNotifiedScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: GetNotifiedScreen.routeName),
          builder: (_) => const GetNotifiedScreen(),
        );
      case JourneyClinicsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: JourneyClinicsScreen.routeName),
          builder: (_) => const JourneyClinicsScreen(),
        );
      case JourneyClinicDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: JourneyClinicDetailScreen.routeName,
          ),
          builder: (_) => JourneyClinicDetailScreen(clinic: args as Clinic?),
        );
      case BottomNavPage.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: BottomNavPage.routeName),
          builder: (_) => const BottomNavPage(),
        );
      case FaceDetectionScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: FaceDetectionScreen.routeName),
          builder: (_) => FaceDetectionScreen(pose: args as String? ?? 'front'),
        );
      case FacePoseCaptureScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: FacePoseCaptureScreen.routeName),
          builder: (_) => const FacePoseCaptureScreen(),
        );
      case FaceScanScreen.routeName:
        final pose = settings.arguments as String? ?? 'front';
        return MaterialPageRoute(
          settings: RouteSettings(
            name: FaceScanScreen.routeName,
            arguments: pose,
          ),
          builder: (_) => FaceScanScreen(pose: pose),
        );
      case AppointmentsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: AppointmentsScreen.routeName),
          builder: (_) => const AppointmentsScreen(),
        );
      case MyProfileScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: MyProfileScreen.routeName),
          builder: (_) => const MyProfileScreen(),
        );
      case ArFaceModelPreviewScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: ArFaceModelPreviewScreen.routeName,
          ),
          builder: (_) => const ArFaceModelPreviewScreen(),
        );
      case AppointmentDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: AppointmentDetailScreen.routeName,
          ),
          builder: (_) =>
              AppointmentDetailScreen(appointment: args as AppointmentItem),
        );
      case AppointmentFormsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: AppointmentFormsScreen.routeName,
          ),
          builder: (_) => AppointmentFormsScreen(
            detail: args as AppointmentDetailData?,
          ),
        );
      case ExploreClinicsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ExploreClinicsScreen.routeName),
          builder: (_) => const ExploreClinicsScreen(),
        );
      case TreatmentDetailScreen.routeName:
        final treatments = settings.arguments as TreatmentData;
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentDetailScreen.routeName),
          builder: (_) => TreatmentDetailScreen(treatments: treatments),
        );
      case ClinicsDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ClinicsDetailScreen.routeName),
          builder: (_) => ClinicsDetailScreen(clinic: args as Clinic?),
        );
      case SelectAppointmentTypeScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: SelectAppointmentTypeScreen.routeName,
          ),
          builder: (_) => const SelectAppointmentTypeScreen(),
        );
      case DoctorsScreen.routeName:
        final argsMap = args as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: const RouteSettings(name: DoctorsScreen.routeName),
          builder: (_) => DoctorsScreen(
            isFromHome: argsMap['isFromHome'] as bool? ?? false,
          ),
        );
      case DoctorDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: DoctorDetailScreen.routeName),
          builder: (_) {
            final data = args as Map<String, dynamic>;
            return DoctorDetailScreen(
              doctor: data['doctor']!,
              clinic: data['clinic'],
            );
          },
        );
      case SelectDateTimeScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SelectDateTimeScreen.routeName),
          builder: (_) => const SelectDateTimeScreen(),
        );
      case ReviewScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ReviewScreen.routeName),
          builder: (_) => const ReviewScreen(),
        );
      case PaymentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: PaymentScreen.routeName),
          builder: (_) => const PaymentScreen(),
        );
      case ClinicServiceScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ClinicServiceScreen.routeName),
          builder: (_) => const ClinicServiceScreen(),
        );
      case SettingScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SettingScreen.routeName),
          builder: (_) => const SettingScreen(),
        );
      case SubscriptionPlansScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: SubscriptionPlansScreen.routeName,
          ),
          builder: (_) => const SubscriptionPlansScreen(),
        );
      case PersonalDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: PersonalDetailScreen.routeName),
          builder: (_) => const PersonalDetailScreen(),
        );
      case PersonalDocumentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: PersonalDocumentScreen.routeName),
          builder: (_) => const PersonalDocumentScreen(),
        );
      case SavedTreatmentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SavedTreatmentScreen.routeName),
          builder: (_) => const SavedTreatmentScreen(),
        );
      case AllergyAndMedicalHistory.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: AllergyAndMedicalHistory.routeName,
          ),
          builder: (_) => const AllergyAndMedicalHistory(),
        );
      case AdditionalInfoScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: AdditionalInfoScreen.routeName),
          builder: (_) => const AdditionalInfoScreen(),
        );
      case MedicalDisclaimerScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: MedicalDisclaimerScreen.routeName,
          ),
          builder: (_) => const MedicalDisclaimerScreen(),
        );
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: PrivacyPolicyScreen.routeName),
          builder: (_) => const PrivacyPolicyScreen(),
        );
      case TermsOfServiceScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: TermsOfServiceScreen.routeName),
          builder: (_) => const TermsOfServiceScreen(),
        );
      case TreatmentsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentsScreen.routeName),
          builder: (_) => const TreatmentsScreen(),
        );
      case TreatmentExploreScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentExploreScreen.routeName),
          builder: (_) => const TreatmentExploreScreen(),
        );
      case TreatmentCategoryScreen.routeName:
        final argsMap = args as Map<String, dynamic>? ?? {};
        final list = argsMap['categories'] as List<TreatmentCategoryModel>?;
        final screenTitle = argsMap['title'] as String? ?? "By Category";
        final path = argsMap['selectionPath'] as String? ?? "Categories";
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: TreatmentCategoryScreen.routeName,
          ),
          builder: (_) => TreatmentCategoryScreen(
            categories: list,
            title: screenTitle,
            selectionPath: path,
          ),
        );
      case TreatmentAreaScreen.routeName:
        final argsMap = args as Map<String, dynamic>? ?? {};
        final list = argsMap['areas'] as List<TreatmentAreaModel>?;
        final screenTitle = argsMap['title'] as String? ?? "Focus Areas";
        final path = argsMap['selectionPath'] as String? ?? "Focus Areas";
        final treatmentId = argsMap['treatmentId'] as int?;
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentAreaScreen.routeName),
          builder: (_) => TreatmentAreaScreen(
            areas: list,
            title: screenTitle,
            selectionPath: path,
            treatmentId: treatmentId,
          ),
        );
      case SelectProductScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: SelectProductScreen.routeName),
          builder: (_) => const SelectProductScreen(),
        );
      case TreatmentPaymentScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentPaymentScreen.routeName),
          builder: (_) => const TreatmentPaymentScreen(),
        );
      case NotesScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: NotesScreen.routeName),
          builder: (_) => const NotesScreen(),
        );
      case NotificationScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: NotificationScreen.routeName),
          builder: (_) {
            return const NotificationScreen();
          },
        );
      case ReelsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ReelsScreen.routeName),
          builder: (_) => const ReelsScreen(),
        );
      case ProgressDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ProgressDetailScreen.routeName),
          builder: (_) => const ProgressDetailScreen(),
        );
      case BiometricScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: BiometricScreen.routeName),
          builder: (_) => const BiometricScreen(),
        );
      case MyCareScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: MyCareScreen.routeName),
          builder: (_) => const MyCareScreen(),
        );
      case ClinicalJourneyScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ClinicalJourneyScreen.routeName),
          builder: (_) => const ClinicalJourneyScreen(),
        );
      case MyTreatmentProgressScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: MyTreatmentProgressScreen.routeName),
          builder: (_) => const MyTreatmentProgressScreen(),
        );
      case TreatmentProgressDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentProgressDetailScreen.routeName),
          builder: (_) => TreatmentProgressDetailScreen(treatmentProgress: args as TreatmentProgress),
        );
      case SimulationHistoryScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: SimulationHistoryScreen.routeName,
          ),
          builder: (_) => const SimulationHistoryScreen(),
        );
      case TreatmentRequestsScreen.routeName:
        final arg = args as bool? ?? true;
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentRequestsScreen.routeName),
          builder: (_) => TreatmentRequestsScreen(isTreatmentRequest: arg),
        );
      case SharedTreatmentRequestsScreen.routeName:
        return MaterialPageRoute(
          settings: RouteSettings(
            name: SharedTreatmentRequestsScreen.routeName,
            arguments: args,
          ),
          builder: (_) => SharedTreatmentRequestsScreen(title: args as String?),
        );
      case PatientTreatmentRequestsScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: PatientTreatmentRequestsScreen.routeName,
          ),
          builder: (_) => PatientTreatmentRequestsScreen(clinicId: args as int),
        );
      case PatientTreatmentRequestDetailScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: PatientTreatmentRequestDetailScreen.routeName,
          ),
          builder: (_) => PatientTreatmentRequestDetailScreen(
            request: args as PatientTreatmentRequest,
          ),
        );
      case TreatmentRequestDetailScreen.routeName:
        final argsMap = args as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: const RouteSettings(
            name: TreatmentRequestDetailScreen.routeName,
          ),
          builder: (_) => TreatmentRequestDetailScreen(
            groupId: argsMap['groupId'] as int,
            groupName: argsMap['groupName'] as String,
          ),
        );
      case TreatmentReviewScreen.routeName:
        final argsMap = args as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: const RouteSettings(name: TreatmentReviewScreen.routeName),
          builder: (_) => TreatmentReviewScreen(
            simulationData: argsMap['simulationData'] as SimulationData?,
            preferredSlots: argsMap['preferredSlots'] as List<PreferredSlot>,
            clinic: argsMap['clinic'] as Clinic,
          ),
        );
      case UpdateVersionScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: UpdateVersionScreen.routeName),
          builder: (_) => const UpdateVersionScreen(),
        );
      case ChatListScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ChatListScreen.routeName),
          builder: (_) => ChatListScreen(
            showBackButton: args as bool? ?? true,
          ),
        );
      case ChatScreen.routeName:
        return MaterialPageRoute(
          settings: const RouteSettings(name: ChatScreen.routeName),
          builder: (_) => ChatScreen(
            showBackButton: args as bool? ?? true,
          ),
        );
      case PdfViewerScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: const RouteSettings(name: PdfViewerScreen.routeName),
          builder: (_) => PdfViewerScreen(
            title: args['title'] ?? 'PDF Viewer',
            url: args['url'] ?? '',
          ),
        );
      case LoginBottomScreen.routeName:
        return PageRouteBuilder(
          settings: const RouteSettings(name: LoginBottomScreen.routeName),
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginBottomScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return const Scaffold(
          appBar: CustomAppBar(title: 'Error'),
          body: Center(child: Text('ERROR')),
        );
      },
    );
  }
}
