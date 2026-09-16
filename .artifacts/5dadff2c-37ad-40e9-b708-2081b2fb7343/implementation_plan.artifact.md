# Implementation Plan - "My Journey" Feature

Add a new "My Journey" feature to the Patient App to track treatment progress at the Treatment + Area level.

## User Review Required

> [!IMPORTANT]
> The "My Journey" feature will be added to the `MyProfileScreen` as a new tile.
> A new screen `MyJourneyScreen` will be created to list active journeys.
> A detail screen `JourneyDetailScreen` will be created to show the timeline of a specific journey.
> Dummy data will be used for now, following the specific scenarios provided (Botox Cheeks/Lips sharing appointments).

## Proposed Changes

### Data Models
- [NEW] [treatment_journey.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/models/journey/treatment_journey.dart): Model for a treatment journey.
- [NEW] [journey_event.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/models/journey/journey_event.dart): Model for individual events within a journey.

### View Models & State Management
- [NEW] [journey_view_model.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/view_models/journey_view_model.dart): Riverpod provider and notifier for journey data.

### Screens
- [MODIFY] [my_profile_screen.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/screens/bottom_nav_screens/my_profile_screen.dart): Add "My Journey" tile.
- [NEW] [my_journey_screen.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/screens/journey/my_journey_screen.dart): List of active journeys.
- [NEW] [journey_detail_screen.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/screens/journey/journey_detail_screen.dart): Detailed timeline for a journey.

### Widgets
- [NEW] [journey_card.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/widgets/journey/journey_card.dart): Card widget for journey list.
- [NEW] [journey_timeline_widget.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/widgets/journey/journey_timeline_widget.dart): Timeline/Stepper widget for journey details.

### Routing
- [MODIFY] [route_generator.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/route_generator.dart): Add routes for `MyJourneyScreen` and `JourneyDetailScreen`.

## Verification Plan

### Automated Tests
- Unit tests for `TreatmentJourney` model logic (progress calculation).
- Widget tests for `JourneyCard` to ensure it displays treatment and area correctly.

### Manual Verification
- Navigate to `My Profile` -> `My Journey`.
- Verify the list shows the dummy journeys (Botox Cheeks, Botox Lips, Dermal Filler).
- Tap a journey to see the detail screen.
- Verify the timeline shows correct status (Completed/Upcoming) and dates.
- Verify that Botox Cheeks and Botox Lips show the same date for Session 1 but different dates for Follow-ups.
