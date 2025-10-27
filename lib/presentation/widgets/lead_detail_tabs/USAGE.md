# Using Lead Detail Tab Widgets

This directory contains refactored tab widgets extracted from the large `lead_detail_screen.dart` file (12,841 lines).

## Current Status

✅ **Cross Sell Tab** - Extracted and ready to use in `cross_sell_tab.dart`

## How to Use in Main Screen

Instead of using the private `_CrossSellTab` class defined inline in `lead_detail_screen.dart`, you can now import and use the public `CrossSellTab` widget:

```dart
// In lead_detail_screen.dart, add this import at the top:
import '../widgets/lead_detail_tabs/cross_sell_tab.dart';

// Then in the TabBarView, replace:
_CrossSellTab(leadId: lead.id),

// With:
CrossSellTab(leadId: lead.id),
```

## Remaining Work

The following tabs still need to be extracted from `lead_detail_screen.dart`:

- [ ] Reference Tab
- [ ] Site Visit Tab  
- [ ] Task Tab
- [ ] Question Tab
- [ ] Property Option Tab
- [ ] Ticket Tab

Each tab follows a similar pattern:
1. Create a new file in this directory
2. Extract the tab class and state
3. Export as a public widget
4. Add helper methods as needed
5. Import and use in the main screen

## Benefits of This Refactoring

1. **Easier to navigate** - Each tab is in its own file
2. **Better maintainability** - Changes to one tab don't affect others
3. **Improved testing** - Each tab can be tested independently
4. **Reduced file size** - Main screen file becomes more manageable
5. **Better IDE performance** - Smaller files load and parse faster

## Next Steps

1. Test the `CrossSellTab` widget by updating `lead_detail_screen.dart`
2. Extract the remaining tabs using the same pattern
3. Extract shared widgets to a `shared/` subdirectory
4. Extract dialogs to a `dialogs/` subdirectory

