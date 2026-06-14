# Component Examples & Usage Guide

This document provides practical examples of how to use the design system components in your StitchHub application.

## Table of Contents
1. [Cards](#cards)
2. [Buttons](#buttons)
3. [Input Fields](#input-fields)
4. [Badges & Status Indicators](#badges--status-indicators)
5. [Lists & Items](#lists--items)
6. [Modals & Dialogs](#modals--dialogs)
7. [Loading States](#loading-states)
8. [Empty States](#empty-states)

---

## Cards

### Standard Card with Shadow
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    boxShadow: AppTheme.shadow2,
  ),
  padding: EdgeInsets.all(AppTheme.spacing20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Card Title', style: Theme.of(context).textTheme.headlineSmall),
      SizedBox(height: AppTheme.spacing12),
      Text('Card content goes here', 
           style: Theme.of(context).textTheme.bodyMedium),
    ],
  ),
)
```

### Elevated Card with Gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
    boxShadow: AppTheme.shadow3,
  ),
  padding: EdgeInsets.all(AppTheme.spacing24),
  child: Column(
    children: [
      Icon(Icons.check_circle, color: AppTheme.white, size: 48),
      SizedBox(height: AppTheme.spacing16),
      Text('Success!', 
           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
             color: AppTheme.white,
           )),
    ],
  ),
)
```

---

## Buttons

### Primary Button with Icon
```dart
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.add),
  label: Text('Create Order'),
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: AppTheme.spacing24, 
      vertical: AppTheme.spacing16
    ),
  ),
)
```

### Secondary Button
```dart
OutlinedButton(
  onPressed: () {},
  child: Text('Cancel'),
  style: OutlinedButton.styleFrom(
    padding: EdgeInsets.symmetric(
      horizontal: AppTheme.spacing24, 
      vertical: AppTheme.spacing16
    ),
  ),
)
```

### Icon Button
```dart
IconButton(
  onPressed: () {},
  icon: Icon(Icons.favorite),
  color: AppTheme.primaryGreen,
  iconSize: 24,
)
```

### Full Width Button
```dart
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Place Order'),
  ),
)
```

---

## Input Fields

### Text Input with Icon
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icon(Icons.email_outlined),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {},
    ),
  ),
)
```

### Search Input
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search tailors...',
    prefixIcon: Icon(Icons.search),
    filled: true,
    fillColor: AppTheme.gray50,
  ),
)
```

### Password Input
```dart
TextFormField(
  obscureText: true,
  decoration: InputDecoration(
    labelText: 'Password',
    prefixIcon: Icon(Icons.lock_outlined),
    suffixIcon: IconButton(
      icon: Icon(Icons.visibility),
      onPressed: () {},
    ),
  ),
)
```

---

## Badges & Status Indicators

### Status Badge
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppTheme.spacing12, 
    vertical: AppTheme.spacing6
  ),
  decoration: BoxDecoration(
    color: AppTheme.successLight,
    borderRadius: BorderRadius.circular(AppTheme.radiusRound),
  ),
  child: Text(
    'Completed',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppTheme.success,
    ),
  ),
)
```

### Rating Badge
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppTheme.spacing10, 
    vertical: AppTheme.spacing4
  ),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.accentAmber, AppTheme.accentOrange],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: AppTheme.white, size: 16),
      SizedBox(width: AppTheme.spacing4),
      Text(
        '4.5',
        style: TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
)
```

### Notification Badge
```dart
Stack(
  children: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
    Positioned(
      right: 8,
      top: 8,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.error,
          shape: BoxShape.circle,
        ),
        child: Text(
          '3',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
)
```

---

## Lists & Items

### Order List Item
```dart
Container(
  margin: EdgeInsets.only(bottom: AppTheme.spacing16),
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    boxShadow: AppTheme.shadow2,
  ),
  child: ListTile(
    contentPadding: EdgeInsets.all(AppTheme.spacing20),
    leading: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Icon(Icons.shopping_bag, color: AppTheme.white),
    ),
    title: Text('Order #12345', 
                style: Theme.of(context).textTheme.titleLarge),
    subtitle: Text('Shirt Alteration', 
                   style: Theme.of(context).textTheme.bodyMedium),
    trailing: Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12, 
        vertical: AppTheme.spacing6
      ),
      decoration: BoxDecoration(
        color: AppTheme.warningLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
      ),
      child: Text('Pending', 
                  style: TextStyle(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  )),
    ),
  ),
)
```

### Tailor Card
```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Image or Avatar
      Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLarge),
            topRight: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tailor Name', 
                 style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: AppTheme.spacing8),
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.accentAmber, size: 20),
                SizedBox(width: AppTheme.spacing4),
                Text('4.5', 
                     style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(width: AppTheme.spacing8),
                Text('(25 reviews)', 
                     style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            SizedBox(height: AppTheme.spacing16),
            ElevatedButton(
              onPressed: () {},
              child: Text('View Profile'),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

## Modals & Dialogs

### Confirmation Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    ),
    title: Text('Confirm Action'),
    content: Text('Are you sure you want to proceed?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          // Handle confirmation
          Navigator.pop(context);
        },
        child: Text('Confirm'),
      ),
    ],
  ),
);
```

### Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppTheme.radiusXLarge),
    ),
  ),
  builder: (context) => Container(
    padding: EdgeInsets.all(AppTheme.spacing24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sheet content
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text('Delete'),
          onTap: () {},
        ),
      ],
    ),
  ),
);
```

---

## Loading States

### Loading Indicator
```dart
Center(
  child: CircularProgressIndicator(
    color: AppTheme.primaryGreen,
  ),
)
```

### Skeleton Loader
```dart
Container(
  padding: EdgeInsets.all(AppTheme.spacing20),
  child: Column(
    children: [
      Container(
        height: 20,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.gray200,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
      SizedBox(height: AppTheme.spacing12),
      Container(
        height: 20,
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.gray200,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    ],
  ),
)
```

---

## Empty States

### Empty State with Icon
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.shopping_bag_outlined,
        size: 64,
        color: AppTheme.gray400,
      ),
      SizedBox(height: AppTheme.spacing16),
      Text(
        'No orders yet',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      SizedBox(height: AppTheme.spacing8),
      Text(
        'Place your first order to get started',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: AppTheme.spacing24),
      ElevatedButton(
        onPressed: () {},
        child: Text('Browse Tailors'),
      ),
    ],
  ),
)
```

---

## Animation Examples

### Fade In Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: AppTheme.durationNormal,
  curve: Curves.easeOut,
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: child,
    );
  },
  child: YourWidget(),
)
```

### Slide Up Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: AppTheme.durationNormal,
  curve: Curves.easeOutCubic,
  builder: (context, value, child) {
    return Transform.translate(
      offset: Offset(0, 30 * (1 - value)),
      child: Opacity(
        opacity: value,
        child: child,
      ),
    );
  },
  child: YourWidget(),
)
```

### Scale Animation
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0.0, end: 1.0),
  duration: AppTheme.durationNormal,
  curve: Curves.elasticOut,
  builder: (context, value, child) {
    return Transform.scale(
      scale: value,
      child: child,
    );
  },
  child: YourWidget(),
)
```

---

## Responsive Examples

### Responsive Grid
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = AppTheme.responsiveColumns(context);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
      ),
      itemBuilder: (context, index) => YourCard(),
    );
  },
)
```

### Responsive Padding
```dart
Padding(
  padding: AppTheme.responsivePadding(context),
  child: YourContent(),
)
```

---

## Best Practices

1. **Always use theme constants** - Don't hardcode colors or spacing
2. **Use semantic colors** - Use `AppTheme.success` instead of green hex codes
3. **Follow spacing scale** - Use predefined spacing values
4. **Add animations** - Use smooth transitions for better UX
5. **Test responsiveness** - Check on different screen sizes
6. **Maintain consistency** - Use the same patterns throughout the app

For more details, refer to [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

