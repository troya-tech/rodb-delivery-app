# UX Anti-Patterns — What to Avoid & What to Do Instead

> **Purpose**: A reference for developers and AI assistants to avoid common UX mistakes in this Flutter project. Each anti-pattern includes the **problem**, **why it's bad**, and the **recommended alternative**.

---

## 1. Fire-and-Forget Timers for UI State

### ❌ Anti-Pattern: Auto-clearing errors with `Future.delayed`

```dart
// BAD — error disappears after 5 seconds whether user read it or not
catch (e) {
  setState(() { _isError = true; _statusMessage = message; });

  Future.delayed(const Duration(seconds: 5), () {
    if (mounted) {
      setState(() { _statusMessage = null; _isError = false; });
    }
  });
}
```

**Why it's bad:**
- User may not have read the error yet (slow readers, accessibility)
- Creates pending timers that break `FakeAsync` in widget tests
- Non-deterministic — UI state depends on wall-clock time, not user intent
- Multiple rapid errors can interleave and clear the wrong message

### ✅ Best Practice: User-driven dismissal

```dart
// GOOD — error persists until user takes action
catch (e) {
  setState(() { _isError = true; _statusMessage = message; });
  // Cleared by: dismiss button, retry action, or navigation
}
```

**Acceptable dismissal triggers:**
| Trigger | When to Use |
|---------|-------------|
| **Dismiss button** (✕ / close icon) | Always provide for error banners |
| **Retry action** | Reset error state at the top of the retry handler |
| **Navigation** | Error naturally gone when widget is disposed |
| **SnackBar with fixed duration** | Only for non-critical confirmations ("Saved!") |

---

## 2. Blocking UI Without Feedback

### ❌ Anti-Pattern: Disabling a button with no visual indicator

```dart
// BAD — button goes grey, user doesn't know why
FilledButton(
  onPressed: _isLoading ? null : _handleAction,
  child: Text('Submit'),
)
```

### ✅ Best Practice: Show a loading indicator inside the button

```dart
// GOOD — user sees the button is working
FilledButton.icon(
  onPressed: _isLoading ? null : _handleAction,
  icon: _isLoading
      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      : const Icon(Icons.check),
  label: Text(_isLoading ? 'Saving...' : 'Submit'),
)
```

---

## 3. Silent Failures

### ❌ Anti-Pattern: Catching errors without informing the user

```dart
// BAD — user taps button, nothing happens, no feedback
try {
  await repository.save(data);
} catch (e) {
  debugPrint('Save failed: $e'); // Only in console
}
```

### ✅ Best Practice: Always surface errors to the user

```dart
// GOOD — user knows what happened
try {
  await repository.save(data);
  // Show success feedback (SnackBar is fine for confirmations)
} catch (e) {
  if (!mounted) return;
  setState(() {
    _isError = true;
    _statusMessage = _parseErrorMessage(e.toString());
  });
}
```

---

## 4. Confirmation on Destructive Actions

### ❌ Anti-Pattern: Immediate destructive action without confirmation

```dart
// BAD — one tap deletes with no undo
onPressed: () => repository.delete(item.id),
```

### ✅ Best Practice: Require confirmation for destructive actions

```dart
// GOOD — confirm before destroying
onPressed: () async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Delete ${item.name}?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
      ],
    ),
  );
  if (confirmed == true) await repository.delete(item.id);
},
```

**Rules:**
- Delete, logout, discard changes → **always confirm**
- Save, toggle, reorder → **no confirmation needed** (reversible)

---

## 5. Validation Feedback Location

### ❌ Anti-Pattern: Showing validation errors behind the triggering dialog

```dart
// BAD — SnackBar renders behind the dialog, user can't see it
onPressed: () {
  if (nameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Name is required')),
    );
  }
}
```

### ✅ Best Practice: Inline validation within the same context

```dart
// GOOD — error appears right next to the field
TextFormField(
  controller: nameController,
  decoration: InputDecoration(
    labelText: 'Name',
    errorText: _nameError, // Inline error, always visible
  ),
)
```

**Rule:** If the user is inside a dialog, validation feedback **must** appear inside that dialog.

---

## 6. Unresponsive Long Lists

### ❌ Anti-Pattern: Loading entire dataset without pagination

```dart
// BAD — loads 10,000 items, UI freezes
ListView(
  children: allItems.map((item) => ItemTile(item)).toList(),
)
```

### ✅ Best Practice: Use `ListView.builder` for lazy rendering

```dart
// GOOD — only renders visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(items[index]),
)
```

---

## 7. Navigation Without State Awareness

### ❌ Anti-Pattern: Navigating after an async gap without checking `mounted`

```dart
// BAD — may crash if user navigated away during the async call
await repository.save(data);
Navigator.of(context).pop();
```

### ✅ Best Practice: Check `mounted` after every async gap

```dart
// GOOD — safe navigation
await repository.save(data);
if (!mounted) return;
Navigator.of(context).pop();
```

---

## Quick Reference

| Anti-Pattern | Fix |
|---|---|
| Timer-based error auto-clear | User-driven dismiss (button / retry / navigation) |
| Disabled button, no indicator | Loading spinner inside button + loading text |
| Silent catch blocks | Always show error to user |
| One-tap delete | Confirmation dialog for destructive actions |
| SnackBar behind dialog | Inline `errorText` on form fields |
| `ListView` with `.map().toList()` | `ListView.builder` |
| `Navigator.pop()` after `await` | Guard with `if (!mounted) return` |
