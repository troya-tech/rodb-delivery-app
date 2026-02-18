# Flutter UI Best Practices: Always Use SafeArea

## The Rule
**All screens and overlay content (Bottom Sheets, Dialogs, Modals) MUST be wrapped in a `SafeArea` widget.**

## Why?
Modern mobile devices have complex screen geometries:
- **System Navigation Bars**: Android gesture bars or 3-button navigation take up space at the bottom.
- **Notches & Dynamic Islands**: Cameras and sensors cut into the top display area.
- **Rounded Corners**: Content in the absolute corners may be clipped.

Without `SafeArea`, critical UI elements—especially buttons like "Save", "Apply", or "Continue" placed at the bottom—can be **obscured** by the operating system's navigation bar, making them unclickable.

## Implementation Guide

### 1. Scaffold Body
Wrap the body of your `Scaffold` if you have content that scrolls to the edges or fixed elements.

```dart
Scaffold(
  appBar: AppBar(title: Text('Settings')),
  body: SafeArea(
    child: ListView(
      children: [ ... ],
    ),
  ),
);
```

### 2. Bottom Sheets & Modals (Critical)
Bottom sheets slide up from the bottom, exactly where the system navigation bar lives. **Always** wrap the content returned by your builder.

```dart
showModalBottomSheet(
  context: context,
  builder: (ctx) => SafeArea(  // <--- CRITICAL
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your content
          FilledButton(onPressed: () {}, child: Text('Apply')),
        ],
      ),
    ),
  ),
);
```

### 3. Bottom Navigation Bars
Flutter's `BottomNavigationBar` handles safe areas automatically, but custom bottom bars or floating action buttons (FABs) might need manual adjustment or `SafeArea` wrapping if they are not part of the standard Scaffold slots.

## lint/review
- [ ] Does every `showModalBottomSheet` builder start with `SafeArea`?
- [ ] Does every screen body start with `SafeArea` (unless it's a map or fullscreen image)?
