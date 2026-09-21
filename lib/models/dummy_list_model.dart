import '../utils/assets.dart';
import 'responses/treatment_progress_detail_response.dart';
import 'responses/treatment_progress_response.dart';

class Treatments {
  final String svg;
  final String title;
  Treatments({required this.title, required this.svg});
}

final List<Treatments> treatments = [
  Treatments(title: "DERMAL FILLERS", svg: SvgAssets.treatment),
  Treatments(title: "BOTOX", svg: SvgAssets.treatment),
];

final List<Treatments> sections = [
  Treatments(title: "Upper Face", svg: PngAssets.splashLogo),
  Treatments(title: "Midface", svg: PngAssets.splashLogo),
  Treatments(title: "Lower Face", svg: PngAssets.splashLogo),
  Treatments(title: "Jawline", svg: PngAssets.splashLogo),
];

final List<Treatments> subSections = [
  Treatments(title: "Tear Trough", svg: SvgAssets.treatment),
  Treatments(title: "Cheeks/ Midface", svg: SvgAssets.treatment),
  Treatments(title: "Nasolabial Folds", svg: SvgAssets.treatment),
  Treatments(title: "Preauricular Area", svg: SvgAssets.treatment),
];

class DummySession {
  final DateTime date;
  final String doctorName;
  final String clinicName;
  final String type; // Session or Follow-up
  final String outcome;
  final List<String> products;
  final String materials; // e.g., "2 Syringes", "50 Units"
  final String postCare;

  DummySession({
    required this.date,
    required this.doctorName,
    required this.clinicName,
    required this.type,
    required this.outcome,
    required this.products,
    required this.materials,
    required this.postCare,
  });
}

class DummyAppointment {
  final String id;
  final String clinicName;
  final String doctorName;
  final String treatmentName;
  final String area;
  final DateTime date;
  final String time;
  final String type;
  final String status;
  final String notes;
  final List<DummySession> pastSessions;

  DummyAppointment({
    required this.id,
    required this.clinicName,
    required this.doctorName,
    required this.treatmentName,
    required this.area,
    required this.date,
    required this.time,
    required this.type,
    this.status = "Scheduled",
    this.notes =
        "Patient requested subtle results with focus on natural appearance.",
    this.pastSessions = const [],
  });
}

class DummyDoctor {
  final String id;
  final String name;
  final String image;
  final String specialization;
  final String clinicName;
  final double rating;

  DummyDoctor({
    required this.id,
    required this.name,
    required this.image,
    required this.specialization,
    required this.clinicName,
    required this.rating,
  });
}

class DummyClinic {
  final String id;
  final String name;
  final String image;
  final String address;
  final int treatmentCount;
  final int doctorCount;

  DummyClinic({
    required this.id,
    required this.name,
    required this.image,
    required this.address,
    required this.treatmentCount,
    required this.doctorCount,
  });
}

final List<DummyDoctor> dummyDoctors = [
  DummyDoctor(
    id: "1",
    name: "Dr. Sarah Smith",
    image:
        "https://t4.ftcdn.net/jpg/03/20/52/31/360_F_320523164_cc7at9W77BRD96qLYpSPlSdrofD8oM0S.jpg",
    specialization: "Dermatologist",
    clinicName: "Glow Skin Clinic",
    rating: 4.8,
  ),
  DummyDoctor(
    id: "2",
    name: "Dr. John Doe",
    image:
        "https://t3.ftcdn.net/jpg/02/60/04/08/360_F_260040863_7y7D6shY6K75YI0yS2666OAXm0C46RRT.jpg",
    specialization: "Cosmetic Surgeon",
    clinicName: "Radiance Care",
    rating: 4.9,
  ),
  DummyDoctor(
    id: "3",
    name: "Dr. Emily Brown",
    image:
        "https://t4.ftcdn.net/jpg/03/17/85/49/360_F_317854905_2idSd8Kps97L9p85nL8k8uK07NMTQ3mF.jpg",
    specialization: "Aesthetic Physician",
    clinicName: "Skin Sync Center",
    rating: 4.7,
  ),
  DummyDoctor(
    id: "4",
    name: "Dr. Michael Wilson",
    image:
        "https://t3.ftcdn.net/jpg/02/95/51/80/360_F_295518052_NmSFeE1VPVCu499rkcyYpL6x6686K856.jpg",
    specialization: "Laser Specialist",
    clinicName: "Elite Dermatology",
    rating: 4.6,
  ),
];

final List<DummyClinic> topClinics = [
  DummyClinic(
    id: "1",
    name: "Glow Skin Clinic",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQl-cyJqFlcZav1TlRMEuajtrg2RJlWY3rTQA&s",
    address: "Bedford-Stuyvesant, Brooklyn, NY",
    treatmentCount: 25,
    doctorCount: 8,
  ),
  DummyClinic(
    id: "2",
    name: "Radiance Care",
    image:
        "https://images.squarespace-cdn.com/content/v1/5b3a6e9f1aef1db0d7a0c7e2/1531149791485-Y86L86E8N8V8M8N8Y8N8/Radiance-Care-Logo.png",
    address: "Manhattan, New York, NY",
    treatmentCount: 40,
    doctorCount: 12,
  ),
  DummyClinic(
    id: "3",
    name: "Skin Sync Center",
    image:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0_7K8G9C8g_9n9k_y_x_w_v_z_y_x_w_v_z_y_x_w_v_z_y_x_w_v_z&s",
    address: "Queens, New York, NY",
    treatmentCount: 30,
    doctorCount: 10,
  ),
];

final List<DummySession> _botoxCheeksHistory = [
  DummySession(
    date: DateTime(2024, 1, 10),
    doctorName: "Dr. Sarah Smith",
    clinicName: "Glow Skin Clinic",
    type: "Session",
    outcome:
        "Successful initial application. Slight swelling resolved in 2 days.",
    products: ["Botox Cosmetic"],
    materials: "25 Units",
    postCare: "Avoid heavy exercise for 24 hours. Keep upright for 4 hours.",
  ),
  DummySession(
    date: DateTime(2024, 1, 24),
    doctorName: "Dr. Sarah Smith",
    clinicName: "Glow Skin Clinic",
    type: "Follow-up",
    outcome: "Results look natural. No touch-up required.",
    products: [],
    materials: "N/A",
    postCare: "Continue standard skincare routine.",
  ),
];

final List<DummyAppointment> dummyAppointments = [
  // Grouped on May 20
  DummyAppointment(
    id: "1",
    clinicName: "Glow Skin Clinic",
    doctorName: "Dr. Sarah Smith",
    treatmentName: "BOTOX",
    area: "Forehead",
    date: DateTime(2024, 5, 20),
    time: "09:00 AM - 10:00 AM",
    type: "Consultation",
    pastSessions: _botoxCheeksHistory,
  ),
  DummyAppointment(
    id: "2",
    clinicName: "Glow Skin Clinic",
    doctorName: "Dr. Sarah Smith",
    treatmentName: "BOTOX",
    area: "Cheeks",
    date: DateTime(2024, 5, 20),
    time: "10:00 AM - 11:00 AM",
    type: "Consultation",
    pastSessions: _botoxCheeksHistory,
  ),
  DummyAppointment(
    id: "3",
    clinicName: "Radiance Care",
    doctorName: "Dr. John Doe",
    treatmentName: "DERMAL FILLERS",
    area: "Lips",
    date: DateTime(2024, 5, 20),
    time: "11:30 AM - 12:30 PM",
    type: "Sessions",
  ),
  DummyAppointment(
    id: "4",
    clinicName: "Radiance Care",
    doctorName: "Dr. John Doe",
    treatmentName: "DERMAL FILLERS",
    area: "Jawline",
    date: DateTime(2024, 5, 20),
    time: "12:30 PM - 01:30 PM",
    type: "Sessions",
  ),

  // Grouped on May 21
  DummyAppointment(
    id: "5",
    clinicName: "Skin Sync Center",
    doctorName: "Dr. Emily Brown",
    treatmentName: "Chemical Peel",
    area: "Full Face",
    date: DateTime(2024, 5, 21),
    time: "02:00 PM - 03:00 PM",
    type: "Follow-Up / Touch-Up",
  ),
  DummyAppointment(
    id: "6",
    clinicName: "Elite Dermatology",
    doctorName: "Dr. Michael Wilson",
    treatmentName: "BOTOX",
    area: "Neck",
    date: DateTime(2024, 5, 21),
    time: "03:30 PM - 04:30 PM",
    type: "Sessions",
  ),

  // Grouped on May 22
  DummyAppointment(
    id: "7",
    clinicName: "Awaiting Clinic Confirmation",
    doctorName: "Pending",
    treatmentName: "Laser Hair Removal",
    area: "Underarms",
    date: DateTime(2024, 5, 22),
    time: "09:00 AM - 10:00 AM",
    type: "Provisional Booking",
  ),
  DummyAppointment(
    id: "8",
    clinicName: "Awaiting Clinic Confirmation",
    doctorName: "Pending",
    treatmentName: "Laser Hair Removal",
    area: "Lower Legs",
    date: DateTime(2024, 5, 22),
    time: "10:00 AM - 11:30 AM",
    type: "Provisional Booking",
  ),
  DummyAppointment(
    id: "9",
    clinicName: "Elite Dermatology",
    doctorName: "Dr. Michael Wilson",
    treatmentName: "Chemical Peel",
    area: "Hands",
    date: DateTime(2024, 5, 22),
    time: "01:00 PM - 02:00 PM",
    type: "Sessions",
  ),

  // Individual dates
  DummyAppointment(
    id: "10",
    clinicName: "Radiance Care",
    doctorName: "Dr. John Doe",
    treatmentName: "BOTOX",
    area: "Crow's Feet",
    date: DateTime(2024, 5, 23),
    time: "01:00 PM - 02:00 PM",
    type: "Consultation",
  ),
  DummyAppointment(
    id: "11",
    clinicName: "Skin Sync Center",
    doctorName: "Dr. Emily Brown",
    treatmentName: "BOTOX",
    area: "Frown Lines",
    date: DateTime(2024, 5, 24),
    time: "12:00 PM - 01:00 PM",
    type: "Follow-Up / Touch-Up",
  ),
  DummyAppointment(
    id: "12",
    clinicName: "Awaiting Clinic Confirmation",
    doctorName: "Pending",
    treatmentName: "DERMAL FILLERS",
    area: "Cheeks",
    date: DateTime(2024, 5, 25),
    time: "11:00 AM - 12:00 PM",
    type: "Provisional Booking",
  ),
  DummyAppointment(
    id: "13",
    clinicName: "Awaiting Clinic Confirmation",
    doctorName: "Pending",
    treatmentName: "DERMAL FILLERS",
    area: "Chin",
    date: DateTime(2024, 5, 25),
    time: "12:00 PM - 01:00 PM",
    type: "Provisional Booking",
  ),
  DummyAppointment(
    id: "14",
    clinicName: "Glow Skin Clinic",
    doctorName: "Dr. Sarah Smith",
    treatmentName: "DERMAL FILLERS",
    area: "Tear Trough",
    date: DateTime(2024, 5, 26),
    time: "10:00 AM - 11:00 AM",
    type: "Follow-Up / Touch-Up",
  ),
  DummyAppointment(
    id: "15",
    clinicName: "Radiance Care",
    doctorName: "Dr. John Doe",
    treatmentName: "BOTOX",
    area: "Jawline",
    date: DateTime(2024, 5, 27),
    time: "11:30 AM - 12:30 PM",
    type: "Consultation",
  ),
  DummyAppointment(
    id: "16",
    clinicName: "Awaiting Clinic Confirmation",
    doctorName: "Pending",
    treatmentName: "BOTOX",
    area: "Forehead",
    date: DateTime(2024, 5, 28),
    time: "09:00 AM - 10:00 AM",
    type: "Provisional Booking",
  ),
  DummyAppointment(
    id: "17",
    clinicName: "Skin Sync Center",
    doctorName: "Dr. Emily Brown",
    treatmentName: "DERMAL FILLERS",
    area: "Nasolabial Folds",
    date: DateTime(2024, 5, 29),
    time: "12:30 PM - 01:30 PM",
    type: "Follow-Up / Touch-Up",
  ),
  DummyAppointment(
    id: "18",
    clinicName: "Radiance Care",
    doctorName: "Dr. John Doe",
    treatmentName: "Chemical Peel",
    area: "Neck",
    date: DateTime(2024, 5, 24),
    time: "03:00 PM - 04:00 PM",
    type: "Sessions",
  ),
  DummyAppointment(
    id: "19",
    clinicName: "Glow Skin Clinic",
    doctorName: "Dr. Sarah Smith",
    treatmentName: "Laser Hair Removal",
    area: "Full Arms",
    date: DateTime(2024, 5, 20),
    time: "05:00 PM - 06:00 PM",
    type: "Sessions",
  ),
  DummyAppointment(
    id: "20",
    clinicName: "Glow Skin Clinic",
    doctorName: "Dr. Sarah Smith",
    treatmentName: "Laser Hair Removal",
    area: "Underarms",
    date: DateTime(2024, 5, 20),
    time: "06:00 PM - 06:30 PM",
    type: "Sessions",
  ),
];

class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? image;
  final String? shortDescription;
  final int? parentId;
  final List<CategoryModel> subCategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.image,
    this.shortDescription,
    this.parentId,
    this.subCategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var subList = json['sub_categories'] as List? ?? [];
    List<CategoryModel> subs = subList
        .map((e) => CategoryModel.fromJson(e))
        .toList();
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      image: json['image'],
      shortDescription: json['short_description'],
      parentId: json['parent_id'],
      subCategories: subs,
    );
  }
}

final List<CategoryModel> dummyCategories = [
  CategoryModel(
    id: 1,
    name: "Aesthetics",
    icon: "face",
    image:
        "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
    shortDescription:
        "Advanced facials, medical skin peels, and glow therapies.",
    parentId: null,
    subCategories: [
      CategoryModel(
        id: 10,
        name: "Facial Aesthetics",
        icon: "face",
        image:
            "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Signature dermaplaning, laser, and microdermabrasion.",
        parentId: 1,
        subCategories: [
          CategoryModel(
            id: 101,
            name: "Chemical Peels",
            icon: "peel",
            image:
                "https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Target hyperpigmentation and skin texture flaws.",
            parentId: 10,
            subCategories: [],
          ),
          CategoryModel(
            id: 102,
            name: "Hydrafacials",
            icon: "water",
            image:
                "https://images.unsplash.com/photo-1590439471364-192aa70c0b53?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Intense hydration and deep pore vortex cleansing.",
            parentId: 10,
            subCategories: [],
          ),
        ],
      ),
      CategoryModel(
        id: 11,
        name: "Body Aesthetics",
        icon: "accessibility",
        image:
            "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Non-surgical skin tightening and cellulite contouring.",
        parentId: 1,
        subCategories: [
          CategoryModel(
            id: 111,
            name: "CoolSculpting",
            icon: "ac_unit",
            image:
                "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Freeze stubborn fat cells safely and permanently.",
            parentId: 11,
            subCategories: [],
          ),
        ],
      ),
    ],
  ),
  CategoryModel(
    id: 2,
    name: "Injectables",
    icon: "syringe",
    image:
        "https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=800",
    shortDescription:
        "High-end dermal fillers, collagen boosters, and anti-aging injections.",
    parentId: null,
    subCategories: [
      CategoryModel(
        id: 20,
        name: "Dermal Fillers",
        icon: "medical_services",
        image:
            "https://images.unsplash.com/photo-15122909023902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
        shortDescription: "Hyaluronic acid-based structural volumization.",
        parentId: 2,
        subCategories: [
          CategoryModel(
            id: 201,
            name: "Lip Fillers",
            icon: "lips",
            image:
                "https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Plump, hydrate, and define your lip contour.",
            parentId: 20,
            subCategories: [],
          ),
          CategoryModel(
            id: 202,
            name: "Cheek Fillers",
            icon: "face",
            image:
                "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Lift cheekbones and restore youthful mid-face volume.",
            parentId: 20,
            subCategories: [],
          ),
        ],
      ),
      CategoryModel(
        id: 21,
        name: "Mesotherapy",
        icon: "spa",
        image:
            "https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Micro-injections of custom medical vitamin cocktails.",
        parentId: 2,
        subCategories: [],
      ),
    ],
  ),
  CategoryModel(
    id: 3,
    name: "Neurotoxins",
    icon: "health_and_safety",
    image:
        "https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?auto=format&fit=crop&q=80&w=800",
    shortDescription:
        "Wrinkle relaxers, frown line injections, and botulinum therapies.",
    parentId: null,
    subCategories: [
      CategoryModel(
        id: 30,
        name: "Botox Cosmetics",
        icon: "science",
        image:
            "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Frown lines, forehead wrinkles, and crow's feet relaxation.",
        parentId: 3,
        subCategories: [
          CategoryModel(
            id: 301,
            name: "Forehead Botox",
            icon: "spa",
            image:
                "https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Smooth persistent horizontal forehead expression lines.",
            parentId: 30,
            subCategories: [],
          ),
          CategoryModel(
            id: 302,
            name: "Crow's Feet Botox",
            icon: "remove_red_eye",
            image:
                "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Soften fine laughter lines around your eye zone.",
            parentId: 30,
            subCategories: [],
          ),
        ],
      ),
      CategoryModel(
        id: 31,
        name: "Dysport Injections",
        icon: "vaccines",
        image:
            "https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Fast-acting frown line smoothing with natural finish.",
        parentId: 3,
        subCategories: [],
      ),
    ],
  ),
];

class DummyAreaModel {
  final int id;
  final String name;
  final String? image;
  final String? shortDescription;
  final int? parentId;
  final List<DummyAreaModel> subAreas;

  DummyAreaModel({
    required this.id,
    required this.name,
    this.image,
    this.shortDescription,
    this.parentId,
    this.subAreas = const [],
  });
}

final List<DummyAreaModel> dummyAreas = [
  DummyAreaModel(
    id: 1,
    name: "Face",
    image:
        "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
    shortDescription:
        "Explore treatments targeting specific facial muscles and zones.",
    parentId: null,
    subAreas: [
      DummyAreaModel(
        id: 11,
        name: "Upper Face",
        image:
            "https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&q=80&w=800",
        shortDescription: "Forehead, frown lines, temples, and brow lifts.",
        parentId: 1,
        subAreas: [
          DummyAreaModel(
            id: 111,
            name: "Forehead",
            image:
                "https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Horizontal lines and forehead skin rejuvenation.",
            parentId: 11,
          ),
          DummyAreaModel(
            id: 112,
            name: "Frown Lines",
            image:
                "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Relax persistence eleven lines between the eyebrows.",
            parentId: 11,
          ),
          DummyAreaModel(
            id: 113,
            name: "Temples",
            image:
                "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Restore lost volume in temporal hollows.",
            parentId: 11,
          ),
        ],
      ),
      DummyAreaModel(
        id: 12,
        name: "Middle Face",
        image:
            "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
        shortDescription: "Under-eye area, cheeks, and nasolabial folds.",
        parentId: 1,
        subAreas: [
          DummyAreaModel(
            id: 121,
            name: "Cheeks",
            image:
                "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Lift and volume restoration for structural definition.",
            parentId: 12,
          ),
          DummyAreaModel(
            id: 122,
            name: "Tear Troughs",
            image:
                "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Treat tired under-eye bags and hollows.",
            parentId: 12,
          ),
          DummyAreaModel(
            id: 123,
            name: "Nasolabial Folds",
            image:
                "https://images.unsplash.com/photo-1590439471364-192aa70c0b53?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Soften laugh lines extending from nose to mouth.",
            parentId: 12,
          ),
        ],
      ),
      DummyAreaModel(
        id: 13,
        name: "Lower Face",
        image:
            "https://movelmedspa.com/storage/2024/05/Cheek-Filler-Treatment-at-Movel-Med-Spa.webp",
        shortDescription: "Lips, chin, jawline definition, and mouth corners.",
        parentId: 1,
        subAreas: [
          DummyAreaModel(
            id: 131,
            name: "Lips",
            image:
                "https://images.unsplash.com/photo-1600334089648-b0d9d3028eb2?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Volumize, hydrate, and contour lips.",
            parentId: 13,
          ),
          DummyAreaModel(
            id: 132,
            name: "Jawline",
            image:
                "https://movelmedspa.com/storage/2024/05/Cheek-Filler-Treatment-at-Movel-Med-Spa.webp",
            shortDescription: "Sharpen jawline angle and tighten jowls.",
            parentId: 13,
          ),
          DummyAreaModel(
            id: 133,
            name: "Chin",
            image:
                "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Elongate chin projection and balance facial symmetry.",
            parentId: 13,
          ),
        ],
      ),
    ],
  ),
  DummyAreaModel(
    id: 2,
    name: "Body",
    image:
        "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
    shortDescription:
        "Treatments covering arms, neck, chest, abdomen, and legs.",
    parentId: null,
    subAreas: [
      DummyAreaModel(
        id: 21,
        name: "Upper Body",
        image:
            "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800",
        shortDescription: "Neck bands, shoulders, decolletage, and chest.",
        parentId: 2,
        subAreas: [
          DummyAreaModel(
            id: 211,
            name: "Neck",
            image:
                "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Tighten horizontal neck rings and skin sag.",
            parentId: 21,
          ),
          DummyAreaModel(
            id: 212,
            name: "Shoulders",
            image:
                "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Laser treatment and sculpting on the shoulder zone.",
            parentId: 21,
          ),
        ],
      ),
      DummyAreaModel(
        id: 22,
        name: "Middle Body",
        image:
            "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Abdomen contouring, flank fat freezing, and upper arms.",
        parentId: 2,
        subAreas: [
          DummyAreaModel(
            id: 221,
            name: "Abdomen",
            image:
                "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Fat reduction and muscle toning for stomach area.",
            parentId: 22,
          ),
          DummyAreaModel(
            id: 222,
            name: "Upper Arms",
            image:
                "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
            shortDescription: "Tighten batwing arms and contour upper arm fat.",
            parentId: 22,
          ),
        ],
      ),
      DummyAreaModel(
        id: 23,
        name: "Lower Body",
        image:
            "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
        shortDescription:
            "Thighs tightening, buttocks contouring, and lower legs.",
        parentId: 2,
        subAreas: [
          DummyAreaModel(
            id: 231,
            name: "Thighs",
            image:
                "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Cellulite reduction and inner/outer thigh tightening.",
            parentId: 23,
          ),
          DummyAreaModel(
            id: 232,
            name: "Lower Legs",
            image:
                "https://images.unsplash.com/photo-1519824141125-994e37c7af46?auto=format&fit=crop&q=80&w=800",
            shortDescription:
                "Laser hair removal and capillary vein therapies.",
            parentId: 23,
          ),
        ],
      ),
    ],
  ),
];

// final List<Clinic> dummyClinicsForService = [
//   Clinic(
//     clinicId: 1,
//     clinicName: "Elite Aesthetic Wellness Clinic",
//     email: "info@eliteaesthetics.com",
//     phone: "+1 555-019-2834",
//     description: "Premium clinical skin & non-surgical face and body enhancements.",
//     address: "102 Beverly Hills Dr, Los Angeles, CA 90210",
//     logo: "https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&q=80&w=150",
//     price: 550,
//     syringeSize: 1,
//     status: "active",
//   ),
//   Clinic(
//     clinicId: 2,
//     clinicName: "Skinsync AI MedSpa",
//     email: "reception@skinsyncmedspa.com",
//     phone: "+1 555-024-8849",
//     description: "State-of-the-art AI-driven facial contouring & clinical dermatology.",
//     address: "742 Evergreen Terrace, Seattle, WA 98101",
//     logo: "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&q=80&w=150",
//     price: 480,
//     syringeSize: 1,
//     status: "active",
//   ),
//   Clinic(
//     clinicId: 3,
//     clinicName: "Radiant Skin Clinical Suite",
//     email: "support@radiantclinical.com",
//     phone: "+1 555-072-1209",
//     description: "Elite dermatological injections and bespoke skincare therapies.",
//     address: "505 Fifth Avenue, New York, NY 10017",
//     logo: "https://images.unsplash.com/photo-1522337360788-8b13edd793be?auto=format&fit=crop&q=80&w=150",
//     price: 620,
//     syringeSize: 1,
//     status: "active",
//   ),
// ];

// Dummy Dataset
// TODO(temp): dummy data, delete with the fallback above.
List<TreatmentProgressData> dummyTreatmentProgress() => [
  TreatmentProgressData(
    id: 101,
    treatmentName: 'Laser Hair Removal',
    treatmentId: 1,
    areaName: 'Full Face',
    areaId: 2,
    status: 'in_progress',
    progress: 60,
    totalSteps: 5,
    currentStep: 3,
  ),
  TreatmentProgressData(
    id: 102,
    treatmentName: 'Skin Rejuvenation',
    treatmentId: 3,
    areaName: 'Cheeks & Forehead',
    areaId: 4,
    status: 'completed',
    progress: 100,
    totalSteps: 4,
    currentStep: 4,
  ),
  TreatmentProgressData(
    id: 103,
    treatmentName: 'Acne Scar Treatment',
    treatmentId: 5,
    areaName: 'Upper Back',
    areaId: 6,
    status: 'upcoming',
    progress: 0,
    totalSteps: 6,
    currentStep: 0,
  ),
  TreatmentProgressData(
    id: 104,
    treatmentName: 'Chemical Peel',
    treatmentId: 7,
    areaName: 'Neck & Decolletage',
    areaId: 8,
    status: 'paused',
    progress: 25,
    totalSteps: 4,
    currentStep: 1,
  ),
  TreatmentProgressData(
    id: 105,
    treatmentName: 'HydraFacial',
    treatmentId: 9,
    areaName: 'Full Face',
    areaId: 10,
    status: 'in_progress',
    progress: 50,
    totalSteps: 2,
    currentStep: 1,
  ),
];
TreatmentProgressDetailResponse dummyTreatmentProgressDetail(int id) {
  final now = DateTime.now();
  int ts(int daysFromNow, {int hour = 10}) => DateTime(
        now.year,
        now.month,
        now.day + daysFromNow,
        hour,
      ).millisecondsSinceEpoch ~/ 1000; // change to ms if your API uses ms

  return TreatmentProgressDetailResponse(
    isSuccess: true,
    message: 'Dummy data',
    data: TreatmentProgressDetailData(
      treatmentId: id,
      areaId: 2,
      treatmentName: 'Laser Hair Removal',
      areaName: 'Full Face',
      progressData: [
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.consultation,
          status: 'completed',
          date: ts(-30),
          time: ts(-30, hour: 11),
        ),
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.treatment,
          status: 'completed',
          sessionId: 201,
          sessionName: 'Session 1',
          sessionDate: ts(-20),
          sessionTime: ts(-20, hour: 14),
          doctorId: 1,
          doctorName: 'Dr. Sarah Khan',
          clinicId: 1,
          clinicName: 'Glow Skin Clinic',
        ),
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.followUp,
          status: 'completed',
          date: ts(-10),
          time: ts(-10, hour: 12),
        ),
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.treatment,
          status: 'in_progress',
          sessionId: 202,
          sessionName: 'Session 2',
          sessionDate: ts(0),
          sessionTime: ts(0, hour: 16),
          doctorId: 1,
          doctorName: 'Dr. Sarah Khan',
          clinicId: 1,
          clinicName: 'Glow Skin Clinic',
        ),
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.followUp,
          status: 'upcoming',
          date: ts(14),
          time: ts(14, hour: 11),
        ),
        TreatmentProgressDetailItem(
          appointmentType: AppointmentType.treatment,
          status: 'upcoming',
          sessionId: 203,
          sessionName: 'Session 3',
          sessionDate: ts(30),
          sessionTime: ts(30, hour: 15),
          doctorId: 2,
          doctorName: 'Dr. Ali Raza',
          clinicId: 1,
          clinicName: 'Glow Skin Clinic',
        ),
      ],
    ),
  );
}
// Removed AppointmentTypeModel and dummyAppointmentTypes as they are now fetched from the API
