# StitchHub Project Documentation

Complete documentation for the StitchHub tailor marketplace Flutter application.

## Documentation Structure

### 📁 [Models](models/README.md)
Data models and structures used throughout the application.
- User models (UserModel, TailorModel)
- Order and payment models
- Service models (Appointment, Measurement, Review, Chat)
- Supporting models (Address, Search Filters, etc.)

### 📁 [Services](services/README.md)
Business logic and Firebase integration services.
- Authentication services
- Order and payment services
- Tailor and search services
- Feature services (Appointments, Measurements, Reviews, Chat)

### 📁 [Providers](providers/README.md)
State management using Provider pattern.
- Auth provider
- Order provider
- Tailor provider
- Feature providers

### 📁 [Screens](screens/README.md)
UI screens and user interfaces.
- Authentication screens
- Customer screens
- Tailor screens

### 📁 [Utils](utils/README.md)
Utility classes and helper functions.
- Error handling
- Network utilities

## Quick Start

1. **Understanding the Architecture**
   - Start with [Models](models/README.md) to understand data structures
   - Review [Services](services/README.md) for business logic
   - Check [Providers](providers/README.md) for state management

2. **Development Workflow**
   - Models define data structure
   - Services handle business logic
   - Providers manage state
   - Screens display UI

## Project Overview

StitchHub is a comprehensive tailor marketplace application that connects customers with local tailors. The app supports:
- User authentication (customers and tailors)
- Order management
- Appointment booking
- Measurement requests
- Payment processing
- Reviews and ratings
- Real-time chat
- Location-based search

## Technology Stack

- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Payment:** Stripe
- **Notifications:** Firebase Cloud Messaging

## Getting Help

For specific documentation:
- Check the README in each directory
- Review individual file documentation
- Refer to code comments in source files

## Contributing

When adding new features:
1. Create/update model documentation
2. Document service methods
3. Update provider documentation
4. Document new screens

