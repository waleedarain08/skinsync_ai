import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../models/responses/patient_plans_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../utils/list_utils.dart';
import '../view_models/subscription_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/horizontal_empty_state.dart';
import '../widgets/subscription_plan_card.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  static const String routeName = "/SubscriptionPlansScreen";

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  String? selectedPlanId;

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(showTitle: true, title: "Subscription Plans"),
      body: _buildBody(subscriptionState),
      bottomNavigationBar: subscriptionState.plans.isEmpty
          ? null
          : _buildBottomButton(subscriptionState),
    );
  }

  Widget _buildBottomButton(SubscriptionState state) {
    final currentPlan = state.currentPlan;
    final allPlans = state.plans;

    if (selectedPlanId == null && allPlans.isNotEmpty) {
      selectedPlanId = state.currentPlan?.id ?? allPlans.firstOrNull?.id;
    }

    final selectedPlan = allPlans.firstWhereOrNull(
      (p) => p.id == selectedPlanId,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.w(24),
        context.h(12),
        context.w(24),
        context.h(32),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentPlan != null &&
              selectedPlanId != currentPlan.id &&
              allPlans.isNotEmpty &&
              selectedPlan != null) ...[
            CustomButton(
              isBorder: true,
              borderRadius: context.r(30),
              textColor: CustomColors.blackColor,
              onPressed: () {
                _showComparisonSheet(context, currentPlan, selectedPlan);
              },
              text: "Compare with Current Plan",
            ),
            SizedBox(height: context.h(12)),
          ],
          CustomButton(
            onPressed: selectedPlanId == currentPlan?.id
                ? null
                : () async {
                    if (selectedPlan == null) return;

                    if (selectedPlan.isLifetime == true) {
                      // Direct API call for lifetime plan
                      await ref
                          .read(subscriptionProvider.notifier)
                          .upgradePlan(selectedPlan.id!);
                      return;
                    }

                    final options = selectedPlan.durationOptions ?? [];

                    if (options.isEmpty) {
                      // Fallback if no options (though shouldn't happen based on requirement)
                      await ref
                          .read(subscriptionProvider.notifier)
                          .upgradePlan(selectedPlan.id!);
                    } else if (options.length == 1) {
                      // Direct API call for single duration
                      await ref
                          .read(subscriptionProvider.notifier)
                          .upgradePlan(
                            selectedPlan.id!,
                            durationId: options.first.id,
                          );
                    } else {
                      // Show bottom sheet for multiple durations
                      _showDurationSelectionSheet(context, selectedPlan);
                    }
                  },
            text: selectedPlanId == currentPlan?.id
                ? "Currently Active"
                : "Upgrade to ${selectedPlan?.name ?? 'N/A'}",
          ),
        ],
      ),
    );
  }

  void _showDurationSelectionSheet(BuildContext context, Plan selectedPlan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: .new(minWidth: 1.sw),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(20),
          context.w(24),
          context.h(32) + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(32)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.w(40),
              height: context.h(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Select Duration", style: CustomFonts.black22w600),
            SizedBox(height: context.h(8)),
            Text(
              "Choose how often you'd like to be billed for ${selectedPlan.name}",
              style: CustomFonts.grey14w400,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(24)),
            ...?selectedPlan.durationOptions?.map(
              (option) => Padding(
                padding: EdgeInsets.only(bottom: context.h(12)),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    await ref
                        .read(subscriptionProvider.notifier)
                        .upgradePlan(selectedPlan.id!, durationId: option.id);
                  },
                  borderRadius: BorderRadius.circular(context.r(16)),
                  child: Container(
                    padding: EdgeInsets.all(context.w(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(context.r(16)),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.interval?.label ?? 'N/A',
                          style: CustomFonts.black16w600,
                        ),
                        Text(
                          "\$${option.amount?.toStringAsFixed(2) ?? 0}",
                          style: CustomFonts.black16w600.copyWith(
                            color: CustomColors.purpleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.h(12)),
            CustomButton(
              isBorder: true,
              borderRadius: context.r(30),
              textColor: CustomColors.blackColor,
              onPressed: () => Navigator.pop(context),
              text: "Cancel",
            ),
          ],
        ),
      ),
    );
  }

  void _showComparisonSheet(
    BuildContext context,
    CurrentPlan current,
    Plan selected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: .new(minWidth: 1.sw),
      builder: (context) => Container(
        height: 0.6.sh,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(32)),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(20),
        ),
        child: Column(
          children: [
            Container(
              width: context.w(40),
              height: context.h(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Plan Comparison", style: CustomFonts.black22w600),
            SizedBox(height: context.h(32)),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildComparisonForSubscription(
                        "Current",
                        current,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 400.h, // Fixed height for vertical divider
                      color: Colors.grey.shade200,
                      margin: EdgeInsets.symmetric(horizontal: context.w(12)),
                    ),
                    Expanded(
                      child: _buildComparisonColumn(
                        "Selected",
                        selected,
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.h(20)),
            CustomButton(
              onPressed: () => Navigator.pop(context),
              text: "Close",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonColumn(
    String label,
    Plan plan, {
    bool isHighlighted = false,
  }) {
    final textColor = isHighlighted ? CustomColors.purpleColor : Colors.grey;

    return Column(
      children: [
        Text(
          label,
          style: CustomFonts.grey14w400.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.h(8)),
        Text(
          plan.name ?? '',
          style: CustomFonts.black18w600,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(4)),
        Text(
          _getPriceText(plan),
          style: CustomFonts.black14w600.copyWith(
            color: CustomColors.purpleColor,
            fontSize: context.sp(11),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(24)),
        _comparisonItem(
          (plan.unlimitedSimulation ?? false)
              ? "Unlimited AI Simulations"
              : "${plan.simulationCount ?? 0} AI Simulations",
        ),
        _comparisonItem(
          (plan.unlimitedPostsView ?? false)
              ? "Unlimited Posts View"
              : "${plan.postsViewCount ?? 0} Posts View",
        ),
        if (plan.benefits != null)
          ...plan.benefits!.map(
            (benefit) => _comparisonItem(benefit.title ?? ''),
          ),
      ],
    );
  }

  Widget _buildComparisonForSubscription(
    String label,
    CurrentPlan plan, {
    bool isHighlighted = false,
  }) {
    final textColor = isHighlighted ? CustomColors.purpleColor : Colors.grey;

    return Column(
      children: [
        Text(
          label,
          style: CustomFonts.grey14w400.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.h(8)),
        Text(
          plan.name ?? '',
          style: CustomFonts.black18w600,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(4)),
        Text(
          _getPriceSubText(plan),
          style: CustomFonts.black14w600.copyWith(
            color: CustomColors.purpleColor,
            fontSize: context.sp(11),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.h(24)),
        _comparisonItem(
          (plan.unlimitedSimulation ?? false)
              ? "Unlimited AI Simulations"
              : "AI Simulations: ${plan.usedSimulationCount ?? 0} Used / ${plan.simulationCount ?? 0} Total",
        ),
        _comparisonItem(
          (plan.unlimitedPostsView ?? false)
              ? "Unlimited Posts View"
              : "Posts View: ${plan.usedPostCount ?? 0} Used / ${plan.postsViewCount ?? 0} Total",
        ),
        if (plan.benefits != null)
          ...plan.benefits!.map(
            (benefit) => _comparisonItem(benefit.title ?? ''),
          ),
      ],
    );
  }

  String _getPriceSubText(CurrentPlan plan) {
    final bool isLifetime = plan.isLifetime ?? false;
    if (isLifetime) {
      return "Lifetime";
    }

    if (plan.endDate != null) {
      return "Expires: ${plan.endDate!.formattedDate}";
    }

    final String formattedPrice = (plan.price == 0 || plan.price == null)
        ? "Free"
        : "\$${plan.price! % 1 == 0 ? plan.price!.toInt() : plan.price}";

    if (plan.durationName != null && plan.durationName!.isNotEmpty) {
      return formattedPrice == "Free"
          ? "Free / ${plan.durationName}"
          : "$formattedPrice / ${plan.durationName}";
    }

    return formattedPrice;
  }

  String _getPriceText(Plan plan) {
    if (plan.isLifetime == true) {
      return "\$${plan.basePrice} (Lifetime)";
    }
    if (plan.durationOptions == null || plan.durationOptions!.isEmpty) {
      return plan.basePrice == 0 || plan.basePrice == null
          ? "Free"
          : "\$${plan.basePrice}";
    }
    return plan.durationOptions!
        .map((opt) => "\$${opt.amount}/${opt.interval?.label}")
        .join("\n"); // Using newline for better fit in comparison column
  }

  Widget _comparisonItem(String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: context.sp(14),
            color: CustomColors.darkPurple,
          ),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Text(
              title,
              style: CustomFonts.black14w400.copyWith(
                fontSize: context.sp(12),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SubscriptionState state) {
    final currentPlan = state.currentPlan;
    final allPlans = state.plans;

    // Initialize selectedPlanId if not set
    if (selectedPlanId == null && allPlans.isNotEmpty) {
      selectedPlanId = currentPlan?.id ?? allPlans.first.id;
    }

    return AnimationLimiter(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              Divider(
                color: CustomColors.greyColor.withValues(alpha: 0.6),
                height: context.h(1),
              ),

              // Current Plan Section
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(24),
                  context.h(24),
                  context.w(24),
                  context.h(12),
                ),
                child: Text(
                  "Current Active Plan",
                  style: CustomFonts.black18w600,
                ),
              ),
              if (currentPlan != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                  child: SubscriptionCard(
                    plan: currentPlan,
                    isSelected: selectedPlanId == currentPlan.id,
                    isActive: true,
                    onTap: () =>
                        setState(() => selectedPlanId = currentPlan.id),
                  ),
                )
              else
                const HorizontalEmptyState(
                  icon: Icons.subscriptions_outlined,
                  title: "No Active Plan",
                  subtitle:
                      "You are not currently subscribed to any plan. Choose a plan below to get started.",
                ),
              SizedBox(height: context.h(20)),

              // Other Plans Section
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(24),
                  currentPlan == null ? context.h(24) : 0,
                  context.w(24),
                  context.h(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Explore More Plans", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(4)),
                    Text(
                      "Choose a plan that fits your skincare journey best",
                      style: CustomFonts.grey14w400,
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 0.32.sh,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                  scrollDirection: Axis.horizontal,
                  itemCount: allPlans.length,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final plan = allPlans[index];
                    // Hide from "Other" if it's the current plan
                    if (plan.id == currentPlan?.id) {
                      return const SizedBox.shrink();
                    }

                    final isSelected = plan.id == selectedPlanId;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: SubscriptionPlanCard(
                            width: context.w(300),
                            height: double.infinity,
                            margin: EdgeInsets.only(right: context.w(16)),
                            plan: plan,
                            isSelected: isSelected,
                            isActive: plan.id == currentPlan?.id,
                            onTap: () =>
                                setState(() => selectedPlanId = plan.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: context.h(20)),
            ],
          ),
        ),
      ),
    );
  }
}
