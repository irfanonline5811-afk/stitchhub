# StitchHub Design System

## Table of Contents
1. [Overview](#overview)
2. [Design Principles](#design-principles)
3. [Color System](#color-system)
4. [Typography](#typography)
5. [Spacing & Layout](#spacing--layout)
6. [Component Library](#component-library)
7. [Animation & Transitions](#animation--transitions)
8. [Responsive Design](#responsive-design)
9. [Accessibility](#accessibility)
10. [Implementation Guide](#implementation-guide)

---

## Overview

The StitchHub Design System provides a comprehensive set of guidelines, components, and patterns to create a cohesive, modern, and accessible user experience across all platforms.

### Design Philosophy
- **Minimalism**: Clean interfaces with purposeful elements
- **Clarity**: Clear visual hierarchy and intuitive navigation
- **Consistency**: Unified design language across all screens
- **Accessibility**: Inclusive design for all users
- **Performance**: Smooth animations and fast interactions

---

## Design Principles

### 1. Clean & Minimalist
- Use ample white space (minimum 16px between elements)
- Remove unnecessary visual clutter
- Focus on essential content and actions
- Use subtle shadows and borders for depth

### 2. Visual Hierarchy
- Clear distinction between primary, secondary, and tertiary elements
- Use size, color, and spacing to guide user attention
- Consistent heading structure (H1 → H6)
- Prominent call-to-action buttons

### 3. Consistency
- Unified color palette across all screens
- Consistent spacing scale
- Standardized component patterns
- Predictable interaction patterns

### 4. User-Centric
- Intuitive navigation patterns
- Clear feedback for all interactions
- Error prevention and clear error messages
- Fast loading and smooth transitions

---

## Color System

### Primary Colors

```dart
// Primary Green Palette
Color primaryGreen = Color(0xFF2E7D32);      // Main brand color
Color primaryGreenLight = Color(0xFF4CAF50);  // Hover states, accents
Color primaryGreenLighter = Color(0xFF66BB6A); // Light backgrounds
Color primaryGreenDark = Color(0xFF1B5E20);   // Darker variants
Color primaryGreenDarkest = Color(0xFF0D3E11); // Darkest shade
```

### Secondary Colors

```dart
// Accent Colors
Color accentBlue = Color(0xFF2196F3);         // Information, links
Color accentAmber = Color(0xFFFFC107);        // Warnings, ratings
Color accentOrange = Color(0xFFFF9800);       // Alerts, highlights
Color accentPurple = Color(0xFF9C27B0);       // Special features
```

### Neutral Colors

```dart
// Grayscale Palette
Color white = Color(0xFFFFFFFF);
Color gray50 = Color(0xFFFAFAFA);   // Backgrounds
Color gray100 = Color(0xFFF5F5F5);  // Light backgrounds
Color gray200 = Color(0xFFEEEEEE);  // Borders, dividers
Color gray300 = Color(0xFFE0E0E0);  // Disabled states
Color gray400 = Color(0xFFBDBDBD);  // Placeholder text
Color gray500 = Color(0xFF9E9E9E);  // Secondary text
Color gray600 = Color(0xFF757575);  // Body text
Color gray700 = Color(0xFF616161);  // Headings
Color gray800 = Color(0xFF424242);  // Dark text
Color gray900 = Color(0xFF212121);  // Primary text
Color black = Color(0xFF000000);
```

### Semantic Colors

```dart
// Status Colors
Color success = Color(0xFF4CAF50);    // Success messages, completed states
Color successLight = Color(0xFF81C784);
Color error = Color(0xFFE53935);      // Errors, destructive actions
Color errorLight = Color(0xFFEF5350);
Color warning = Color(0xFFFF9800);    // Warnings, pending states
Color warningLight = Color(0xFFFFB74D);
Color info = Color(0xFF2196F3);       // Information messages
Color infoLight = Color(0xFF64B5F6);
```

### Color Usage Guidelines

| Element | Color | Usage |
|---------|-------|-------|
| Primary Buttons | `primaryGreen` | Main actions, CTAs |
| Secondary Buttons | `gray200` | Secondary actions |
| Links | `primaryGreen` | All links |
| Success States | `success` | Completed orders, success messages |
| Error States | `error` | Errors, cancellations |
| Warning States | `warning` | Pending orders, warnings |
| Backgrounds | `white`, `gray50` | Screen backgrounds |
| Cards | `white` | Card backgrounds |
| Borders | `gray200` | Input borders, dividers |
| Text Primary | `gray900` | Headings, important text |
| Text Secondary | `gray600` | Body text, descriptions |
| Text Disabled | `gray400` | Disabled elements |

### Color Contrast Ratios

All text meets WCAG AA standards:
- **Normal text**: Minimum 4.5:1 contrast ratio
- **Large text**: Minimum 3:1 contrast ratio
- **Interactive elements**: Minimum 3:1 contrast ratio

---

## Typography

### Font Family

```dart
// Primary Font Stack
String primaryFont = 'Roboto';  // Default
String secondaryFont = 'Inter';  // Alternative (if available)

// Fallback
String fallbackFont = 'system-ui, -apple-system, sans-serif';
```

### Type Scale

```dart
// Heading Styles
TextStyle h1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
  height: 1.2,
  color: gray900,
);

TextStyle h2 = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
  height: 1.3,
  color: gray900,
);

TextStyle h3 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.3,
  height: 1.3,
  color: gray900,
);

TextStyle h4 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  height: 1.4,
  color: gray900,
);

TextStyle h5 = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  letterSpacing: 0,
  height: 1.4,
  color: gray900,
);

TextStyle h6 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.15,
  height: 1.5,
  color: gray900,
);

// Body Text
TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  letterSpacing: 0.15,
  height: 1.5,
  color: gray600,
);

TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  letterSpacing: 0.25,
  height: 1.5,
  color: gray600,
);

TextStyle bodySmall = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  letterSpacing: 0.4,
  height: 1.4,
  color: gray500,
);

// Special Text
TextStyle button = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  color: white,
);

TextStyle caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  letterSpacing: 0.4,
  color: gray500,
);

TextStyle overline = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  letterSpacing: 1.5,
  color: gray500,
  textTransform: TextTransform.uppercase,
);
```

### Typography Usage

| Element | Style | Example |
|---------|-------|---------|
| Page Title | H1 | "Welcome to StitchHub" |
| Section Headers | H2 | "My Orders" |
| Card Titles | H3 | "Order #12345" |
| Subsection Headers | H4 | "Order Details" |
| List Item Titles | H5 | "Shirt Alteration" |
| Small Headers | H6 | "Status" |
| Body Text | bodyMedium | "Your order is being processed..." |
| Button Text | button | "Place Order" |
| Captions | caption | "Last updated 2 hours ago" |

---

## Spacing & Layout

### Spacing Scale

```dart
// Base spacing unit: 4px
double spacing4 = 4.0;   // 0.25rem
double spacing8 = 8.0;   // 0.5rem
double spacing12 = 12.0; // 0.75rem
double spacing16 = 16.0; // 1rem (base unit)
double spacing20 = 20.0; // 1.25rem
double spacing24 = 24.0; // 1.5rem
double spacing32 = 32.0; // 2rem
double spacing40 = 40.0; // 2.5rem
double spacing48 = 48.0; // 3rem
double spacing64 = 64.0; // 4rem
double spacing80 = 80.0; // 5rem
```

### Layout Guidelines

```dart
// Screen Padding
EdgeInsets screenPadding = EdgeInsets.all(16.0);      // Mobile
EdgeInsets screenPaddingTablet = EdgeInsets.all(24.0); // Tablet
EdgeInsets screenPaddingDesktop = EdgeInsets.all(32.0); // Desktop

// Card Padding
EdgeInsets cardPadding = EdgeInsets.all(20.0);
EdgeInsets cardPaddingSmall = EdgeInsets.all(16.0);
EdgeInsets cardPaddingLarge = EdgeInsets.all(24.0);

// Section Spacing
double sectionSpacing = 32.0;  // Between major sections
double elementSpacing = 16.0;  // Between related elements
double groupSpacing = 24.0;    // Between groups of elements
```

### Grid System

```dart
// Mobile (default)
int mobileColumns = 1;
double mobileGutter = 16.0;

// Tablet
int tabletColumns = 2;
double tabletGutter = 24.0;

// Desktop
int desktopColumns = 3;
double desktopGutter = 32.0;
```

### Border Radius

```dart
double radiusSmall = 8.0;   // Small elements, tags
double radiusMedium = 12.0; // Buttons, inputs
double radiusLarge = 16.0;  // Cards
double radiusXLarge = 20.0; // Large cards, modals
double radiusRound = 999.0; // Pills, avatars
```

### Shadows

```dart
// Elevation Levels
List<BoxShadow> shadow1 = [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
];

List<BoxShadow> shadow2 = [
  BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 8,
    offset: Offset(0, 4),
  ),
];

List<BoxShadow> shadow3 = [
  BoxShadow(
    color: Colors.black.withOpacity(0.12),
    blurRadius: 16,
    offset: Offset(0, 8),
  ),
];

List<BoxShadow> shadow4 = [
  BoxShadow(
    color: Colors.black.withOpacity(0.16),
    blurRadius: 24,
    offset: Offset(0, 12),
  ),
];
```

---

## Component Library

### Buttons

#### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
  ),
  onPressed: () {},
  child: Text('Primary Action'),
)
```

#### Secondary Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    side: BorderSide(color: primaryGreen, width: 2),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  onPressed: () {},
  child: Text('Secondary Action'),
)
```

#### Text Button
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: primaryGreen,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  onPressed: () {},
  child: Text('Text Action'),
)
```

### Cards

#### Standard Card
```dart
Container(
  decoration: BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: shadow2,
  ),
  padding: EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Card content
    ],
  ),
)
```

#### Elevated Card
```dart
Container(
  decoration: BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: shadow3,
  ),
  padding: EdgeInsets.all(24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Card content
    ],
  ),
)
```

### Input Fields

#### Text Input
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    hintText: 'Placeholder',
    filled: true,
    fillColor: gray50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: gray200, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primaryGreen, width: 2.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: error, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  ),
)
```

### Badges & Chips

#### Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: successLight,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    'Completed',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: success,
    ),
  ),
)
```

#### Filter Chip
```dart
FilterChip(
  label: Text('Filter'),
  selected: isSelected,
  onSelected: (selected) {},
  selectedColor: primaryGreen,
  checkmarkColor: white,
  labelStyle: TextStyle(
    color: isSelected ? white : gray700,
    fontWeight: FontWeight.w600,
  ),
)
```

### Navigation

#### Bottom Navigation Bar
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  selectedItemColor: primaryGreen,
  unselectedItemColor: gray500,
  selectedLabelStyle: TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
  ),
  unselectedLabelStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
  ),
  backgroundColor: white,
  elevation: 8,
  items: [
    // Navigation items
  ],
)
```

---

## Animation & Transitions

### Duration Standards

```dart
Duration durationFast = Duration(milliseconds: 150);    // Micro-interactions
Duration durationNormal = Duration(milliseconds: 300);  // Standard transitions
Duration durationSlow = Duration(milliseconds: 500);    // Complex animations
Duration durationVerySlow = Duration(milliseconds: 800); // Page transitions
```

### Easing Curves

```dart
Curve easeInOut = Curves.easeInOut;        // Standard
Curve easeOut = Curves.easeOut;            // Enter animations
Curve easeIn = Curves.easeIn;              // Exit animations
Curve easeOutCubic = Curves.easeOutCubic;  // Smooth transitions
Curve elasticOut = Curves.elasticOut;      // Playful animations
```

### Common Animations

#### Fade In
```dart
FadeTransition(
  opacity: animation,
  duration: durationNormal,
  curve: easeOut,
  child: widget,
)
```

#### Slide In
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(0, 0.1),
    end: Offset.zero,
  ).animate(animation),
  duration: durationNormal,
  curve: easeOut,
  child: widget,
)
```

#### Scale Animation
```dart
ScaleTransition(
  scale: Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(animation),
  duration: durationNormal,
  curve: easeOutCubic,
  child: widget,
)
```

### Micro-interactions

#### Button Press
```dart
GestureDetector(
  onTapDown: (_) => setState(() => isPressed = true),
  onTapUp: (_) => setState(() => isPressed = false),
  child: AnimatedScale(
    scale: isPressed ? 0.95 : 1.0,
    duration: durationFast,
    child: button,
  ),
)
```

#### Card Hover (Web)
```dart
MouseRegion(
  onEnter: (_) => setState(() => isHovered = true),
  onExit: (_) => setState(() => isHovered = false),
  child: AnimatedContainer(
    duration: durationNormal,
    transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
    child: card,
  ),
)
```

---

## Responsive Design

### Breakpoints

```dart
// Mobile
double mobileBreakpoint = 0;      // 0-599px
double mobileMaxWidth = 599;

// Tablet
double tabletBreakpoint = 600;    // 600-1023px
double tabletMaxWidth = 1023;

// Desktop
double desktopBreakpoint = 1024;  // 1024px+
```

### Responsive Utilities

```dart
// Check device type
bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width < tabletBreakpoint;
}

bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= tabletBreakpoint && width < desktopBreakpoint;
}

bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= desktopBreakpoint;
}

// Responsive padding
EdgeInsets responsivePadding(BuildContext context) {
  if (isDesktop(context)) return screenPaddingDesktop;
  if (isTablet(context)) return screenPaddingTablet;
  return screenPadding;
}

// Responsive columns
int responsiveColumns(BuildContext context) {
  if (isDesktop(context)) return desktopColumns;
  if (isTablet(context)) return tabletColumns;
  return mobileColumns;
}
```

### Layout Patterns

#### Mobile Layout
- Single column layout
- Full-width cards
- Stacked navigation
- Bottom navigation bar

#### Tablet Layout
- 2-column grid for cards
- Side navigation option
- Larger touch targets
- More spacing

#### Desktop Layout
- 3-column grid for cards
- Side navigation
- Hover states
- Larger content areas

---

## Accessibility

### Color Contrast
- All text meets WCAG AA standards (4.5:1 minimum)
- Interactive elements have 3:1 contrast ratio
- Color is not the only indicator (use icons, text)

### Touch Targets
```dart
// Minimum touch target size: 44x44px
double minTouchTarget = 44.0;
```

### Text Scaling
```dart
// Support text scaling up to 200%
Text(
  'Text',
  style: TextStyle(fontSize: 16),
  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 2.0),
)
```

### Screen Reader Support
```dart
// Semantic labels
Semantics(
  label: 'Order status: Completed',
  child: statusBadge,
)

// Button labels
ElevatedButton(
  onPressed: () {},
  child: Text('Place Order'),
  semanticsLabel: 'Place new order button',
)
```

### Focus Indicators
```dart
// Visible focus indicators
Focus(
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      // Focus color should be visible
    ),
    onPressed: () {},
    child: Text('Button'),
  ),
)
```

### Keyboard Navigation
- All interactive elements should be keyboard accessible
- Logical tab order
- Skip links for main content
- Keyboard shortcuts for common actions

---

## Implementation Guide

### Theme Configuration

```dart
// Create theme.dart file
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF2E7D32),
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF4CAF50),
        surface: Colors.white,
        error: Color(0xFFE53935),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        // ... other text styles
      ),
      // ... other theme properties
    );
  }
}
```

### Component Usage

1. **Import theme utilities**
2. **Use predefined components**
3. **Follow spacing guidelines**
4. **Apply consistent colors**
5. **Add appropriate animations**

### Best Practices

1. **Consistency**: Always use design system components
2. **Spacing**: Use spacing scale, avoid arbitrary values
3. **Colors**: Use semantic color names, not hex codes directly
4. **Typography**: Use text styles from theme
5. **Accessibility**: Test with screen readers and keyboard navigation
6. **Performance**: Optimize animations, use const constructors
7. **Responsive**: Test on multiple screen sizes

---

## Design Tokens

### Quick Reference

```dart
// Colors
primaryGreen, primaryGreenLight, primaryGreenDark
success, error, warning, info
gray50 through gray900

// Spacing
spacing4, spacing8, spacing16, spacing24, spacing32

// Typography
h1, h2, h3, h4, h5, h6
bodyLarge, bodyMedium, bodySmall
button, caption, overline

// Border Radius
radiusSmall, radiusMedium, radiusLarge, radiusXLarge

// Shadows
shadow1, shadow2, shadow3, shadow4

// Durations
durationFast, durationNormal, durationSlow
```

---

## Conclusion

This design system provides a comprehensive foundation for building a modern, accessible, and consistent user interface for StitchHub. Follow these guidelines to ensure a cohesive user experience across all platforms and devices.

For questions or updates to the design system, refer to the design team or update this document accordingly.

