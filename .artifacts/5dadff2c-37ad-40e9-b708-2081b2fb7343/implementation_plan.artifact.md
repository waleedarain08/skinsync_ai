# Implementation Plan - Appointment Journey Feature

Add a new "Appointment Journey" feature to the Patient App to track the end-to-end flow from request to completion.

## User Review Required

> [!IMPORTANT]
> - The "Journey" option will be added to the `MyProfileScreen` as a new tile.
> - A new screen `AppointmentJourneyScreen` will be created.
> - The UI will feature a vertical timeline showing: Patient Request, Doctor Finalized, Branching Treatment Appointments, and Journey Completion.
> - Dummy data will represent a Botox journey for Cheeks and Lips.

## Proposed Changes

### Data Models
- [NEW] [appointment_journey_model.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/models/appointment_journey/appointment_journey_model.dart): Model representing the entire journey, including requests and appointments.

### View Models
- [NEW] [appointment_journey_view_model.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/view_models/appointment_journey/appointment_journey_view_model.dart): Riverpod notifier providing dummy journey data.

### Screens
- [MODIFY] [my_profile_screen.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/screens/bottom_nav_screens/my_profile_screen.dart): Add "Journey" tile.
- [NEW] [appointment_journey_screen.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/screens/appointment_journey/appointment_journey_screen.dart): The main journey visualization screen.

### Widgets
- [NEW] [journey_timeline_node.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/widgets/appointment_journey/journey_timeline_node.dart): A reusable component for timeline nodes.
- [NEW] [request_journey_card.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/widgets/appointment_journey/request_journey_card.dart): Specialized card for the Patient Request step.
- [NEW] [finalized_journey_card.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/widgets/appointment_journey/finalized_journey_card.dart): Specialized card for the Doctor Finalized step.

### Routing
- [MODIFY] [route_generator.dart](file:///Users/appstirr/Documents/Flutter/skin_sync_mobile_app/skinsync_ai/lib/route_generator.dart): Add route for `AppointmentJourneyScreen`.

## Verification Plan

### Automated Tests
- Unit tests for `AppointmentJourney` model to ensure progress calculation logic is correct.
- Widget tests for the timeline branching logic.

### Manual Verification
- Navigate to `My Profile` -> `Journey`.
- Verify the timeline displays the correct sequence: Request -> Finalized -> Branching Appointments -> Completion.
- Ensure the branching for "Botox Cheeks" and "Botox Lips" is visually distinct.
- Check responsive behavior on different screen sizes using Android Studio emulator.
