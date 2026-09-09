import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class NewPatientIntakeScreen extends StatefulWidget {
  static const String routeName = '/NewPatientIntakeScreen';

  const NewPatientIntakeScreen({super.key});

  @override
  State<NewPatientIntakeScreen> createState() => _NewPatientIntakeScreenState();
}

class _NewPatientIntakeScreenState extends State<NewPatientIntakeScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Patient Information
  String? _selectedTitle;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _miController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _gender;
  final TextEditingController _phoneHome = TextEditingController();
  final TextEditingController _phoneWork = TextEditingController();
  final TextEditingController _phoneWorkExt = TextEditingController();
  final TextEditingController _phoneCell = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final Map<String, bool> _contactMethods = {
    'Home': false,
    'Work': false,
    'Cell': false,
    'Email': false,
    'Text Message': false,
  };

  // 2. Emergency Contact
  final TextEditingController _emergNameController = TextEditingController();
  final TextEditingController _emergRelationController = TextEditingController();
  final TextEditingController _emergCellController = TextEditingController();
  final TextEditingController _emergWorkController = TextEditingController();
  final TextEditingController _emergWorkExtController = TextEditingController();
  final TextEditingController _emergHomeController = TextEditingController();
  final Map<String, bool> _emergContactMethods = {
    'Home': false,
    'Work': false,
    'Cell': false,
    'Email': false,
  };

  // 3. How Did You Hear About Us
  final Map<String, bool> _hearAboutUs = {
    'Friend': false,
    'Past Patient': false,
    'Referring Physician': false,
    'Magazine': false,
    'Google': false,
    'Website': false,
    'Facebook': false,
    'Ad': false,
    'Instagram': false,
  };
  final TextEditingController _hearFriendDetail = TextEditingController();
  final TextEditingController _hearPastPatientDetail = TextEditingController();
  final TextEditingController _hearDrDetail = TextEditingController();
  final TextEditingController _hearMagDetail = TextEditingController();

  // 4. HIPAA Authorizations
  bool? _hipaaHomePhone;
  bool? _hipaaWorkPhone;
  bool? _hipaaCellPhone;
  bool? _hipaaFaxRecords;
  late final GlobalKey<SfSignaturePadState> _hipaaSignatureController;

  // 5. Physicians Information
  final TextEditingController _refPhysician = TextEditingController();
  final TextEditingController _refPhysicianPhone = TextEditingController();
  final TextEditingController _refPhysicianAddress = TextEditingController();
  final TextEditingController _priPhysician = TextEditingController();
  final TextEditingController _priPhysicianPhone = TextEditingController();
  final TextEditingController _priPhysicianAddress = TextEditingController();

  // 6. Social History
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  bool? _isSmoking;
  final TextEditingController _smokingPacks = TextEditingController();
  final TextEditingController _smokingHowLong = TextEditingController();
  final TextEditingController _smokingQuitDate = TextEditingController();
  bool? _useVaporDevice;
  String? _alcoholUse;
  bool? _historyAlcoholAbuse;
  final Map<String, bool> _recreationalDrugs = {
    'Marijuana': false,
    'Cocaine': false,
    'Heroin': false,
    'Pain Meds': false,
    'Meth': false,
  };

  // 7. Surgical History
  final TextEditingController _surgBreast = TextEditingController();
  final TextEditingController _surgAbdomen = TextEditingController();
  final TextEditingController _surgFacial = TextEditingController();
  final TextEditingController _surgCosmetic = TextEditingController();
  final TextEditingController _surgOther = TextEditingController();
  final TextEditingController _surgComplications = TextEditingController();
  bool? _anesthesiaProblems;
  final TextEditingController _anesthesiaExplain = TextEditingController();

  // 8. Past Medical History
  final Map<String, bool?> _pastMedicalHistory = {
    'None': null,
    'HIV/AIDS': null,
    'Breast Cancer': null,
    'Kidney Disease': null,
    'Bleeding Tendency': null,
    'Liver Disease': null,
    'Diabetes': null,
    'Lung Disease': null,
    'Eye Problems': null,
    'Mental Illness': null,
    'Heart Disease/MI': null,
    'Neurologic Disease': null,
    'Heart Murmur': null,
    'Other Cancer': null,
    'High Blood Pressure': null,
    'Skin Cancer': null,
    'History DVT/PE': null,
    'Thyroid Disease': null,
    'Sleep Apnea': null,
  };

  // 9. Family History
  final Map<String, TextEditingController> _familyHistory = {
    'Skin Cancer': TextEditingController(),
    'Diabetes': TextEditingController(),
    'Stroke': TextEditingController(),
    'Breast Cancer': TextEditingController(),
    'Other Cancer': TextEditingController(),
    'Heart Disease': TextEditingController(),
    'Abnormal Bleeding': TextEditingController(),
    'Malignant Hypothermia': TextEditingController(),
    'Other': TextEditingController(),
  };

  // 10. Medications & Allergies
  bool _medsSeeList = false;
  bool _medsNone = false;
  final List<TextEditingController> _medListControllers =
      List.generate(6, (_) => TextEditingController());
  bool? _drugAspirin;
  bool? _drugIbuprofen;
  bool? _drugHomeopathic;
  bool? _drugSbeProphylaxis;
  bool? _steroidsLast12Mo;
  bool? _bloodThinner;
  final TextEditingController _bloodThinnerName = TextEditingController();
  final Map<String, bool> _allergies = {
    'Penicillin': false,
    'Lidocaine': false,
    'Latex': false,
    'Tape': false,
    'No known allergies': false,
    'Other': false,
  };
  final TextEditingController _allergyOtherDesc = TextEditingController();
  final TextEditingController _allergyReactionNotes = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // 11. Female Patients
  bool? _femalePregnant;
  bool? _femaleBreastfeeding;
  bool? _femaleBreastfeedingPast;
  bool? _femaleBirthControl;
  bool? _femalePlanningPregnancy;
  bool? _femaleCSection;
  final TextEditingController _femaleCSectionWhen = TextEditingController();
  String? _femaleMammogram;

  // Final Signature
  late final GlobalKey<SfSignaturePadState> _finalSignatureController;
  final TextEditingController _reviewerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hipaaSignatureController = GlobalKey<SfSignaturePadState>();
    _finalSignatureController = GlobalKey<SfSignaturePadState>();
  }

  @override
  void dispose() {
    for (var controller in _familyHistory.values) {
      controller.dispose();
    }
    for (var controller in _medListControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          "New Patient Intake Form",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Column(
              children: [
                _buildPatientInfoCard(),
                const SizedBox(height: 12),
                _buildEmergencyContactCard(),
                const SizedBox(height: 12),
                _buildHowDidYouHearCard(),
                const SizedBox(height: 12),
                _buildHipaaCard(),
                const SizedBox(height: 12),
                _buildPhysiciansInfoCard(),
                const SizedBox(height: 12),
                _buildSocialHistoryCard(),
                const SizedBox(height: 12),
                _buildSurgicalHistoryCard(),
                const SizedBox(height: 12),
                _buildMedicalHistoryCard(),
                const SizedBox(height: 12),
                _buildFamilyHistoryCard(),
                const SizedBox(height: 12),
                _buildMedicationsCard(),
                const SizedBox(height: 12),
                _buildFemalePatientsCard(),
                const SizedBox(height: 12),
                _buildFinalSignatureCard(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Intake Form Submitted Successfully!")),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Submit Intake Form", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 1: Patient Information
  // -------------------------------------------------------------
  Widget _buildPatientInfoCard() {
    return _sectionWrapper(
      title: "PATIENT INFORMATION",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Title: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              Wrap(
                spacing: 4,
                children: ['Dr', 'Mr', 'Mrs', 'Ms'].map((t) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: t,
                        groupValue: _selectedTitle,
                        onChanged: (val) => setState(() => _selectedTitle = val),
                      ),
                      Text(t, style: const TextStyle(color: Colors.black)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_firstNameController, "First Name")),
              const SizedBox(width: 8),
              SizedBox(width: 60, child: _buildTextField(_miController, "MI")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_lastNameController, "Last Name")),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_addressController, "Street Address"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 3, child: _buildTextField(_cityController, "City")),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(_stateController, "State")),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(_zipController, "Zip")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_dobController, "Date of Birth (MM/DD/YYYY)")),
              const SizedBox(width: 12),
              const Text("Gender: ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: ['M', 'F'].map((g) {
                  return Row(
                    children: [
                      Radio<String>(
                        value: g,
                        groupValue: _gender,
                        onChanged: (val) => setState(() => _gender = val),
                      ),
                      Text(g, style: const TextStyle(color: Colors.black)),
                    ],
                  );
                }).toList(),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_phoneHome, "Phone (Home)")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_phoneCell, "Phone (Cell)")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 3, child: _buildTextField(_phoneWork, "Phone (Work)")),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: _buildTextField(_phoneWorkExt, "Ext")),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_emailController, "Email Address"),
          const SizedBox(height: 10),
          const Text("Preferred method of contact:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 10,
            children: _contactMethods.keys.map((method) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _contactMethods[method],
                    onChanged: (v) => setState(() => _contactMethods[method] = v ?? false),
                  ),
                  Text(method, style: const TextStyle(fontSize: 12.5, color: Colors.black)),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 2: Emergency Contact
  // -------------------------------------------------------------
  Widget _buildEmergencyContactCard() {
    return _sectionWrapper(
      title: "EMERGENCY CONTACT INFORMATION",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField(_emergNameController, "Emergency Contact Name")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_emergRelationController, "Relationship to Patient")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_emergCellController, "Phone (Cell)")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_emergHomeController, "Phone (Home)")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 3, child: _buildTextField(_emergWorkController, "Phone (Work)")),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: _buildTextField(_emergWorkExtController, "Ext")),
            ],
          ),
          const SizedBox(height: 10),
          const Text("Preferred method of contact:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 10,
            children: _emergContactMethods.keys.map((method) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _emergContactMethods[method],
                    onChanged: (v) => setState(() => _emergContactMethods[method] = v ?? false),
                  ),
                  Text(method, style: const TextStyle(fontSize: 12.5, color: Colors.black)),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 3: How Did You Hear About Us
  // -------------------------------------------------------------
  Widget _buildHowDidYouHearCard() {
    return _sectionWrapper(
      title: "HOW DID YOU HEAR ABOUT US?",
      child: Column(
        children: [
          _buildHearRow('Friend', 'Friend, who can we thank?', _hearFriendDetail),
          _buildHearRow('Past Patient', 'Past Patient, who can we thank?', _hearPastPatientDetail),
          _buildHearRow('Referring Physician', 'Referring Physician, Dr:', _hearDrDetail),
          _buildHearRow('Magazine', 'Magazine, which one?', _hearMagDetail),
          Wrap(
            spacing: 12,
            children: ['Google', 'Website', 'Facebook', 'Ad', 'Instagram'].map((ch) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _hearAboutUs[ch],
                    onChanged: (v) => setState(() => _hearAboutUs[ch] = v ?? false),
                  ),
                  Text(ch, style: const TextStyle(fontSize: 12.5, color: Colors.black)),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildHearRow(String key, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Checkbox(
            value: _hearAboutUs[key],
            onChanged: (v) => setState(() => _hearAboutUs[key] = v ?? false),
          ),
          Expanded(
            child: _hearAboutUs[key] == true
                ? _buildTextField(controller, label)
                : Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 4: HIPAA
  // -------------------------------------------------------------
  Widget _buildHipaaCard() {
    return _sectionWrapper(
      title: "HIPAA POLICY & CONSENT",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HIPAA is an acronym for the Health Insurance Portability & Accountability Act of 1996. "
            "It is our policy to not release confidential information except appointment confirmation. "
            "I authorize the doctor's office to leave medical information pertaining to my care by the following methods:",
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black),
          ),
          const SizedBox(height: 12),
          _buildYesNoRadioRow("Home telephone", _hipaaHomePhone, (v) => setState(() => _hipaaHomePhone = v)),
          _buildYesNoRadioRow("Work phone", _hipaaWorkPhone, (v) => setState(() => _hipaaWorkPhone = v)),
          _buildYesNoRadioRow("Cell phone / voice mail", _hipaaCellPhone, (v) => setState(() => _hipaaCellPhone = v)),
          _buildYesNoRadioRow("May we fax medical records for referrals?", _hipaaFaxRecords, (v) => setState(() => _hipaaFaxRecords = v)),
          const SizedBox(height: 12),
          const Text("Signature of Patient or Guardian:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 4),
          _buildSignatureBox(_hipaaSignatureController),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 5: Physicians Information
  // -------------------------------------------------------------
  Widget _buildPhysiciansInfoCard() {
    return _sectionWrapper(
      title: "PHYSICIANS INFORMATION",
      child: Column(
        children: [
          _buildTextField(_refPhysician, "Referring Physician"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_refPhysicianPhone, "Phone #")),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(_refPhysicianAddress, "Address")),
            ],
          ),
          const Divider(height: 20),
          _buildTextField(_priPhysician, "Primary Physician"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_priPhysicianPhone, "Phone #")),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _buildTextField(_priPhysicianAddress, "Address")),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 6: Social History
  // -------------------------------------------------------------
  Widget _buildSocialHistoryCard() {
    return _sectionWrapper(
      title: "SOCIAL HISTORY",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField(_occupationController, "Occupation")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_maritalStatusController, "Marital Status")),
            ],
          ),
          const SizedBox(height: 10),
          _buildYesNoRadioRow("Smoking (including e-cigarette):", _isSmoking, (v) => setState(() => _isSmoking = v)),
          if (_isSmoking == true) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: _buildTextField(_smokingPacks, "Pack per Day")),
                const SizedBox(width: 6),
                Expanded(child: _buildTextField(_smokingHowLong, "How Long")),
                const SizedBox(width: 6),
                Expanded(child: _buildTextField(_smokingQuitDate, "Quit Date")),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _buildYesNoRadioRow("Vapor Device:", _useVaporDevice, (v) => setState(() => _useVaporDevice = v)),
          const SizedBox(height: 10),
          const Text("Alcohol Use:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 8,
            children: ['NONE', 'RARE', 'OCCASIONALLY', 'FREQUENT'].map((val) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: val,
                    groupValue: _alcoholUse,
                    onChanged: (v) => setState(() => _alcoholUse = v),
                  ),
                  Text(val, style: const TextStyle(fontSize: 12, color: Colors.black)),
                ],
              );
            }).toList(),
          ),
          _buildYesNoRadioRow("History of Alcohol Abuse:", _historyAlcoholAbuse, (v) => setState(() => _historyAlcoholAbuse = v)),
          const SizedBox(height: 10),
          const Text("Recreational Drug Use:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 12,
            children: _recreationalDrugs.keys.map((d) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _recreationalDrugs[d],
                    onChanged: (v) => setState(() => _recreationalDrugs[d] = v ?? false),
                  ),
                  Text(d, style: const TextStyle(fontSize: 12, color: Colors.black)),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 7: Surgical History
  // -------------------------------------------------------------
  Widget _buildSurgicalHistoryCard() {
    return _sectionWrapper(
      title: "SURGICAL HISTORY (Past Surgeries with Dates)",
      child: Column(
        children: [
          _buildTextField(_surgBreast, "Breast"),
          const SizedBox(height: 6),
          _buildTextField(_surgAbdomen, "Abdomen"),
          const SizedBox(height: 6),
          _buildTextField(_surgFacial, "Facial"),
          const SizedBox(height: 6),
          _buildTextField(_surgCosmetic, "Cosmetic"),
          const SizedBox(height: 6),
          _buildTextField(_surgOther, "Other Surgeries"),
          const SizedBox(height: 6),
          _buildTextField(_surgComplications, "Surgical Complications"),
          const SizedBox(height: 8),
          _buildYesNoRadioRow("Anesthesia Problems:", _anesthesiaProblems, (v) => setState(() => _anesthesiaProblems = v)),
          if (_anesthesiaProblems == true) ...[
            const SizedBox(height: 6),
            _buildTextField(_anesthesiaExplain, "Explain Anesthesia Problems"),
          ]
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 8: Past Medical History
  // -------------------------------------------------------------
  Widget _buildMedicalHistoryCard() {
    final keys = _pastMedicalHistory.keys.toList();
    return _sectionWrapper(
      title: "PAST MEDICAL HISTORY",
      child: Column(
        children: [
          for (int i = 0; i < keys.length; i += 2)
            Row(
              children: [
                Expanded(
                  child: _buildYesNoRadioRow(
                    keys[i],
                    _pastMedicalHistory[keys[i]],
                    (v) => setState(() => _pastMedicalHistory[keys[i]] = v),
                  ),
                ),
                if (i + 1 < keys.length)
                  Expanded(
                    child: _buildYesNoRadioRow(
                      keys[i + 1],
                      _pastMedicalHistory[keys[i + 1]],
                      (v) => setState(() => _pastMedicalHistory[keys[i + 1]] = v),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 9: Family History
  // -------------------------------------------------------------
  Widget _buildFamilyHistoryCard() {
    return _sectionWrapper(
      title: "FAMILY HISTORY (Indicate Blood Relative)",
      child: Column(
        children: _familyHistory.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(entry.key, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.black)),
                ),
                Expanded(child: _buildTextField(entry.value, "Relative (e.g. Mother, Father)")),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 10: Current Medications & Allergies
  // -------------------------------------------------------------
  Widget _buildMedicationsCard() {
    return _sectionWrapper(
      title: "CURRENT MEDICATIONS & ALLERGIES",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _medsSeeList,
                onChanged: (v) => setState(() => _medsSeeList = v ?? false),
              ),
              const Text("See List (Please list dosage/schedule)", style: TextStyle(fontSize: 12, color: Colors.black)),
              const Spacer(),
              Checkbox(
                value: _medsNone,
                onChanged: (v) => setState(() => _medsNone = v ?? false),
              ),
              const Text("None", style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
          if (!_medsNone) ...[
            for (int i = 0; i < 6; i += 2)
              Row(
                children: [
                  Expanded(child: _buildTextField(_medListControllers[i], "${i + 1}. Medication")),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_medListControllers[i + 1], "${i + 2}. Medication")),
                ],
              ),
          ],
          const SizedBox(height: 12),
          const Text("NON-PRESCRIPTION DRUGS:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 12,
            children: [
              _buildCompactYesNo("ASPIRIN", _drugAspirin, (v) => setState(() => _drugAspirin = v)),
              _buildCompactYesNo("IBUPROFEN", _drugIbuprofen, (v) => setState(() => _drugIbuprofen = v)),
              _buildCompactYesNo("HOMEOPATHIC", _drugHomeopathic, (v) => setState(() => _drugHomeopathic = v)),
              _buildCompactYesNo("SBE PROPHYLAXIS", _drugSbeProphylaxis, (v) => setState(() => _drugSbeProphylaxis = v)),
            ],
          ),
          const SizedBox(height: 8),
          _buildYesNoRadioRow("Steroids in the last 12 months:", _steroidsLast12Mo, (v) => setState(() => _steroidsLast12Mo = v)),
          Row(
            children: [
              Expanded(
                child: _buildYesNoRadioRow("Do you take a Blood Thinner?", _bloodThinner, (v) => setState(() => _bloodThinner = v)),
              ),
              if (_bloodThinner == true)
                Expanded(child: _buildTextField(_bloodThinnerName, "Name of Thinner")),
            ],
          ),
          const Divider(height: 20),
          const Text("ALLERGIES TO MEDICATIONS:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          Wrap(
            spacing: 12,
            children: _allergies.keys.map((all) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _allergies[all],
                    onChanged: (v) => setState(() => _allergies[all] = v ?? false),
                  ),
                  Text(all, style: const TextStyle(fontSize: 12, color: Colors.black)),
                ],
              );
            }).toList(),
          ),
          if (_allergies['Other'] == true) ...[
            const SizedBox(height: 6),
            _buildTextField(_allergyOtherDesc, "Specify other allergy"),
          ],
          const SizedBox(height: 8),
          _buildTextField(_allergyReactionNotes, "Note / Type of Allergic Reaction"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTextField(_heightController, "Height (e.g. 5'8\")")),
              const SizedBox(width: 8),
              Expanded(child: _buildTextField(_weightController, "Current Weight (lbs)")),
            ],
          )
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 11: Female Patients
  // -------------------------------------------------------------
  Widget _buildFemalePatientsCard() {
    return _sectionWrapper(
      title: "FEMALE PATIENTS",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYesNoRadioRow("Are you currently pregnant?", _femalePregnant, (v) => setState(() => _femalePregnant = v)),
          Row(
            children: [
              Expanded(
                child: _buildYesNoRadioRow("Breast feeding?", _femaleBreastfeeding, (v) => setState(() => _femaleBreastfeeding = v)),
              ),
              Expanded(
                child: _buildYesNoRadioRow("In the past?", _femaleBreastfeedingPast, (v) => setState(() => _femaleBreastfeedingPast = v)),
              ),
            ],
          ),
          _buildYesNoRadioRow("Do you take birth control pills?", _femaleBirthControl, (v) => setState(() => _femaleBirthControl = v)),
          _buildYesNoRadioRow("Are you planning pregnancy?", _femalePlanningPregnancy, (v) => setState(() => _femalePlanningPregnancy = v)),
          Row(
            children: [
              Expanded(
                child: _buildYesNoRadioRow("Have you had a C-section?", _femaleCSection, (v) => setState(() => _femaleCSection = v)),
              ),
              if (_femaleCSection == true)
                Expanded(child: _buildTextField(_femaleCSectionWhen, "If so, when?")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("When was your last mammogram? ", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Colors.black)),
              Radio<String>(
                value: "1 year",
                groupValue: _femaleMammogram,
                onChanged: (v) => setState(() => _femaleMammogram = v),
              ),
              const Text("1 year", style: TextStyle(fontSize: 12, color: Colors.black)),
              Radio<String>(
                value: "> 1 year",
                groupValue: _femaleMammogram,
                onChanged: (v) => setState(() => _femaleMammogram = v),
              ),
              const Text("> 1 year", style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Card 12: Final Signature & Review
  // -------------------------------------------------------------
  Widget _buildFinalSignatureCard() {
    return _sectionWrapper(
      title: "SIGNATURE & ACKNOWLEDGEMENT",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Patient / Parent's Guardian Signature:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 4),
          _buildSignatureBox(_finalSignatureController),
          const SizedBox(height: 12),
          _buildTextField(_reviewerNameController, "Reviewed with Patient By (Staff Name)"),
          const SizedBox(height: 6),
          Text(
            "Date: ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}",
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // UI Helpers
  // -------------------------------------------------------------
  Widget _sectionWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 12.5, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildYesNoRadioRow(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<bool>(value: true, groupValue: value, onChanged: onChanged),
              const Text("YES", style: TextStyle(fontSize: 11, color: Colors.black)),
              Radio<bool>(value: false, groupValue: value, onChanged: onChanged),
              const Text("NO", style: TextStyle(fontSize: 11, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactYesNo(String label, bool? value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Colors.black)),
        Radio<bool>(value: true, groupValue: value, onChanged: onChanged),
        const Text("Y", style: TextStyle(fontSize: 11, color: Colors.black)),
        Radio<bool>(value: false, groupValue: value, onChanged: onChanged),
        const Text("N", style: TextStyle(fontSize: 11, color: Colors.black)),
      ],
    );
  }

  Widget _buildSignatureBox(GlobalKey<SfSignaturePadState> controller) {
    return Column(
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SfSignaturePad(
              key: controller,
              minimumStrokeWidth: 1,
              maximumStrokeWidth: 3,
              strokeColor: Colors.black,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => controller.currentState?.clear(),
              child: const Text("Clear Signature", style: TextStyle(fontSize: 12, color: Colors.black)),
            ),
          ],
        )
      ],
    );
  }
}
