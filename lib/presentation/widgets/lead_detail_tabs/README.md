# Lead Detail Screen Tab Widgets

This directory contains the refactored tab widgets extracted from `lead_detail_screen.dart` to improve code organization and maintainability.

## Current Structure

The `lead_detail_screen.dart` file is currently 12,841 lines and contains 8 tabs:

1. **Lead Detail Tab** - Shows lead information, personal info, timeline, and activities
2. **Cross Sell Tab** - Manages cross-selling opportunities
3. **Reference Tab** - Shows referrals to and by the lead
4. **Site Visit Tab** - Manages scheduled site visits
5. **Task Tab** - Lists and manages tasks related to the lead
6. **Question Tab** - (Currently placeholder)
7. **Property Option Tab** - (Currently placeholder)
8. **Ticket Tab** - Manages support tickets

## Refactoring Approach

To make the code more accessible and maintainable:

1. Each tab widget should be in its own file
2. Shared helper widgets should be extracted to a `shared/` directory
3. Common dialogs and bottom sheets should be extracted to a `dialogs/` directory
4. The main screen should only import and use the tab widgets

## Next Steps

1. Extract each tab widget into its own file
2. Extract shared components (cards, forms, etc.)
3. Extract dialogs and bottom sheets
4. Update imports in the main screen
5. Test all functionality

