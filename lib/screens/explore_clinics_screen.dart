import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../main.dart';
import '../models/responses/get_clinic_response.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/enums.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/clinic_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_clinic_grid_view_title.dart';
import '../widgets/custom_search_field.dart';
import '../widgets/selected_treatment_and_areas_widget.dart';
import 'clinics_detail_screen.dart';

class ExploreClinicsScreen extends ConsumerStatefulWidget {
  const ExploreClinicsScreen({super.key});

  static const String routeName = '/ExploreClinicsScreen';

  @override
  ConsumerState<ExploreClinicsScreen> createState() =>
      _ExploreClinicsScreenState();
}

class _ExploreClinicsScreenState extends ConsumerState<ExploreClinicsScreen> {
  Timer? _timer;
  final _searchController = TextEditingController();
  late final _pagingController = PagingController<int, Clinic>(
    getNextPageKey: (state) {
      final lastPageLength = state.pages?.lastOrNull?.length;
      if (lastPageLength == null) {
        return 1;
      }
      return lastPageLength < 10 ? null : state.nextIntPageKey;
    },
    fetchPage: (page) async {
      final clinics = await ref
          .read(clinicProvider.notifier)
          .getClinic(page: page, search: _searchController.text.trim());
      return clinics ?? [];
    },
  );

  // @override
  // void initState() {
  //   super.initState();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     // if (isDeploymentMode) {
  //     //   ref.read(clinicProvider.notifier).fetchClinicsFromMap();
  //     // } else {
  //     ref.read(clinicProvider.notifier).getClinic();
  //     // }
  //   });
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clinicProvider);
    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: const CustomAppBar(showTitle: true, title: "Explore Clinics"),
      body: Stack(
        children: [
          DefaultTabController(
            length: isDeploymentMode ? 1 : 2,
            child: Column(
              children: [
                SizedBox(height: context.h(20)),
                // Premium Reusable Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                  child: CustomSearchField(
                    controller: _searchController,
                    hintText: "Search Clinics...",
                    onChanged: (query) {
                      _timer?.cancel();
                      _timer = Timer(const Duration(milliseconds: 500), () {
                        _pagingController.refresh();
                      });
                    },
                  ),
                ),

                // Selected Treatment & Sub-Areas Horizontal Scrollable Chips Row
                SelectedTreatmentAndAreasWidget(
                  onRemove: () {
                    _pagingController.refresh();
                  },
                ),
                SizedBox(height: context.h(16)),

                // Premium Styled TabBar
                if (!isDeploymentMode)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                    child: TabBar(
                      indicatorColor: CustomColors.darkPurple,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey.shade500,
                      labelStyle: CustomFonts.black16w600,
                      unselectedLabelStyle: CustomFonts.grey16w500,
                      dividerColor: Colors.transparent,
                      onTap: (index) {
                        if (index == 0) {
                          ref
                              .read(checkoutViewModel.notifier)
                              .setInviteClinic(false);
                          _pagingController.refresh();
                        } else {
                          ref
                              .read(checkoutViewModel.notifier)
                              .setInviteClinic(true);
                          if (!isDeploymentMode) {
                            ref
                                .read(clinicProvider.notifier)
                                .fetchClinicsFromMap();
                          }
                        }
                      },
                      tabs: const [
                        Tab(text: 'Clinics'),
                        Tab(text: 'Invite Clinics'),
                      ],
                    ),
                  ),
                SizedBox(height: context.h(16)),

                if (state.clinicLoading)
                  const Expanded(child: AppLoader())
                else
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if (!isDeploymentMode)
                          _buildClinics(
                            ref: ref,
                            viewType: state.viewType,
                            clinics: state.clinics,
                          ),
                        _buildViewType(
                          ref: ref,
                          viewType: state.viewType,
                          clinics: state.clinicsToInvite,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Floating Action Button for Map/Grid View Toggle
          if (state.clinicsToInvite.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom + context.h(20),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(50)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: ref.read(clinicProvider.notifier).toggleViewType,
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(50)),
                    ),
                    icon: Image.asset(
                      switch (state.viewType) {
                        ViewType.grid => PngAssets.mapIcon,
                        ViewType.map => PngAssets.syringe,
                      },
                      height: context.h(20),
                      width: context.w(20),
                      color: Colors.white,
                    ),
                    label: Text(switch (state.viewType) {
                      ViewType.grid => "Map View",
                      ViewType.map => 'Grid View',
                    }, style: CustomFonts.white16w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViewType({
    required WidgetRef ref,
    required ViewType viewType,
    required List<Clinic> clinics,
  }) {
    // Beautiful Empty State Design
    if (clinics.isEmpty) {
      return _buildEmptyClinicsView();
    }

    return switch (viewType) {
      ViewType.grid => Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(24)),
        child: MasonryGridView.count(
          padding: EdgeInsets.only(
            left: context.w(24),
            right: context.w(24),
            top: context.h(8),
            bottom: context.h(MediaQuery.paddingOf(context).bottom + 100),
          ),
          crossAxisCount: 2,
          itemCount: clinics.length,
          crossAxisSpacing: context.w(14),
          mainAxisSpacing: context.h(14),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return CustomClinicGridViewTile(
              clinicData: clinics[index],
              onTap: () {
                ref
                    .read(clinicProvider.notifier)
                    .setClinic(clinics[index]);
                Navigator.pushNamed(
                  context,
                  ClinicsDetailScreen.routeName,
                  arguments: clinics[index],
                );
              },
            );
          },
        ),
      ),
      ViewType.map => Consumer(
        builder: (_, ref, _) {
          final addressData = ref.watch(
            authViewModel.select((s) => s.addressData),
          );
          final position = CameraPosition(
            target: addressData?.latLng ?? const LatLng(24.9211313, 67.0708059),
            zoom: 13,
          );
          log('ADDRESS: ${addressData?.address}');
          return GoogleMap(
            key: ValueKey(clinics.length),
            initialCameraPosition: position,
            padding: MediaQuery.paddingOf(ref.context),
            markers: clinics.where((clinic) => clinic.location != null).map((
              clinic,
            ) {
              return Marker(
                markerId: MarkerId('${clinic.id}'),
                position: clinic.location!,
                icon: AssetMapBitmap(
                  PngAssets.customMarker,
                  width: context.w(50),
                  height: context.w(50),
                ),
              );
            }).toSet(),
            onMapCreated: (controller) async {
              await controller.animateCamera(
                CameraUpdate.newCameraPosition(position),
              );
            },
          );
        },
      ),
    };
  }

  Widget _buildClinics({
    required WidgetRef ref,
    required ViewType viewType,
    required List<Clinic> clinics,
  }) {
    return switch (viewType) {
      ViewType.grid => _buildPagedGrid(ref),
      ViewType.map => Consumer(
        builder: (_, ref, _) {
          final addressData = ref.watch(
            authViewModel.select((s) => s.addressData),
          );
          final position = CameraPosition(
            target: addressData?.latLng ?? const LatLng(24.9211313, 67.0708059),
            zoom: 13,
          );
          log('ADDRESS: ${addressData?.address}');
          return GoogleMap(
            key: ValueKey(clinics.length),
            initialCameraPosition: position,
            padding: MediaQuery.paddingOf(ref.context),
            markers: clinics.where((clinic) => clinic.location != null).map((
              clinic,
            ) {
              return Marker(
                markerId: MarkerId('${clinic.id}'),
                position: clinic.location!,
                icon: AssetMapBitmap(
                  PngAssets.customMarker,
                  width: context.w(50),
                  height: context.w(50),
                ),
              );
            }).toSet(),
            onMapCreated: (controller) async {
              await controller.animateCamera(
                CameraUpdate.newCameraPosition(position),
              );
            },
          );
        },
      ),
    };
  }

  PagingListener<int, Clinic> _buildPagedGrid(WidgetRef ref) {
    return PagingListener(
      controller: _pagingController,
      builder: (_, state, fetchNextPage) {
        return PagedGridView<int, Clinic>(
          padding: EdgeInsets.only(
            left: context.w(24),
            right: context.w(24),
            top: context.h(8),
            bottom: context.h(MediaQuery.paddingOf(context).bottom + 100),
          ),
          state: state,
          fetchNextPage: fetchNextPage,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: context.w(14),
            mainAxisSpacing: context.h(14),
          ),
          builderDelegate: PagedChildBuilderDelegate(
            noItemsFoundIndicatorBuilder: (_) => _buildEmptyClinicsView(),
            firstPageErrorIndicatorBuilder: (_) => _buildEmptyClinicsView(),
            firstPageProgressIndicatorBuilder: (_) => const AppLoader(),
            newPageProgressIndicatorBuilder: (_) => const AppLoader(),
            itemBuilder: (_, clinic, _) {
              return CustomClinicGridViewTile(
                clinicData: clinic,
                onTap: () {
                  ref.read(clinicProvider.notifier).setClinic(clinic);
                  Navigator.pushNamed(
                    context,
                    ClinicsDetailScreen.routeName,
                    arguments: clinic,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Center _buildEmptyClinicsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_rounded,
              size: context.sp(64),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.h(16)),
            Text("No Clinics Found", style: CustomFonts.grey800_20w600),
            SizedBox(height: context.h(6)),
            Text(
              "Try searching for a different keyword or check back later.",
              textAlign: TextAlign.center,
              style: CustomFonts.textGrey14w400,
            ),
          ],
        ),
      ),
    );
  }
}
