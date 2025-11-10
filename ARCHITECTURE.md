# 🏗️ TiggerOn CRM - Architecture & File Organization Guide

This document provides a comprehensive guide to understanding the codebase structure, file organization, and development workflow.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Directory Structure](#directory-structure)
4. [File Organization Principles](#file-organization-principles)
5. [Data Flow](#data-flow)
6. [Key Components](#key-components)
7. [Development Workflow](#development-workflow)
8. [Naming Conventions](#naming-conventions)

---

## 🎯 Project Overview

**TiggerOn CRM** is a Flutter-based Real Estate CRM system following **Clean Architecture** principles with a clear separation of concerns:

- **Core Layer**: Configuration, constants, themes, and core utilities
- **Data Layer**: Models, repositories, services, and API integration
- **Presentation Layer**: UI screens, widgets, and user interactions
- **Shared Layer**: Reusable utilities, helpers, and managers

---

## 🏛️ Architecture Pattern

The project follows **Clean Architecture** with **Repository Pattern**:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                     │
│  (Screens, Widgets, Pages, State Management)            │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  (Repositories → Services → Models → API)              │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                      Core Layer                          │
│  (Config, Constants, Theme, Utils)                     │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

### Root Level
```
tigger/
├── lib/                    # Main application code
├── android/                # Android platform-specific code
├── ios/                    # iOS platform-specific code
├── assets/                 # Images, icons, animations
├── pubspec.yaml           # Dependencies and configuration
└── README.md              # Project documentation
```

### `lib/` Directory Structure

```
lib/
├── main.dart                          # 🚀 Application entry point
│
├── core/                             # ⚙️ Core application layer
│   ├── config/                       # Configuration files
│   │   └── supabase_config.dart      # Supabase client configuration
│   ├── constants/                    # Application constants
│   │   └── constants.dart            # API URLs, keys, app constants
│   ├── errors/                       # Error handling classes
│   ├── theme/                        # Theme configuration
│   ├── utils/                        # Core utilities
│   │   └── page_transitions.dart     # Page transition animations
│   └── widgets/                      # Core reusable widgets
│
├── data/                             # 📊 Data layer
│   ├── api/                          # API DTOs and network helpers
│   │   ├── api_helper.dart           # API utility functions
│   │   ├── api_network.dart          # HTTP client wrapper
│   │   ├── api_response.dart         # API response models
│   │   └── *_dto.dart                # Data Transfer Objects (DTOs)
│   │
│   ├── models/                       # Domain models
│   │   ├── models.dart               # Model exports
│   │   ├── *_model.dart              # Individual model classes
│   │   └── export_models.dart        # Model export utilities
│   │
│   ├── repositories/                 # Repository implementations
│   │   └── *_repository.dart         # Feature-specific repositories
│   │
│   └── services/                     # Business logic services
│       ├── database_service.dart     # 🔑 Main database operations
│       ├── auth_service.dart         # Authentication service
│       ├── *_service.dart            # Feature-specific services
│       └── supabase_service.dart     # Supabase wrapper service
│
├── presentation/                     # 🎨 Presentation layer
│   ├── pages/                        # Page-level widgets
│   │   ├── auth_wrapper.dart         # Authentication routing
│   │   ├── role_gate.dart            # Role-based access control
│   │   ├── splash_screen.dart        # Splash screen
│   │   └── widgets/                 # Page-specific widgets
│   │
│   ├── screens/                      # Feature screens
│   │   ├── auth/                     # Authentication screens
│   │   ├── dashboard/                # Dashboard & analytics
│   │   ├── leads/                    # Lead management
│   │   ├── bookings/                 # Booking management
│   │   ├── projects/                 # Project management
│   │   ├── vendors/                  # Vendor management
│   │   ├── tickets/                  # Ticket system
│   │   ├── profile/                  # User profile
│   │   └── notifications/            # Notification screens
│   │
│   └── widgets/                      # Reusable UI widgets
│       ├── lead_detail/              # Lead detail components
│       ├── lead_detail_tabs/         # Lead detail tab widgets
│       ├── lead_disposition/         # Lead disposition widgets
│       └── ticket_widgets/          # Ticket-related widgets
│
└── shared/                           # 🔄 Shared utilities
    ├── extensions/                   # Dart extensions
    ├── helpers/                      # Helper functions
    │   └── notification_helper.dart  # Notification utilities
    ├── managers/                     # State managers
    │   ├── auth_state_manager.dart   # Authentication state
    │   ├── notification_manager.dart # Notification state
    │   └── notification_store.dart  # Notification storage
    ├── services/                     # Shared services
    │   ├── permission_manager.dart   # Permission handling
    │   └── push_notification_service.dart # Push notifications
    ├── utils/                        # Utility functions
    │   └── helpers.dart              # General helpers
    └── widgets/                      # Shared widgets
```

---

## 📐 File Organization Principles

### 1. **Feature-Based Organization**
Files are organized by feature/domain rather than by type:
- ✅ `screens/leads/` - All lead-related screens
- ✅ `services/lead_service.dart` - Lead business logic
- ✅ `models/lead_model.dart` - Lead data model
- ✅ `repositories/lead_repository.dart` - Lead data access

### 2. **Layer Separation**
Clear separation between layers:
- **Core**: Configuration and constants (no business logic)
- **Data**: Models, repositories, services (no UI)
- **Presentation**: Screens and widgets (no direct database access)
- **Shared**: Reusable across layers

### 3. **Naming Conventions**
- **Models**: `*_model.dart` (e.g., `lead_model.dart`)
- **Services**: `*_service.dart` (e.g., `lead_service.dart`)
- **Repositories**: `*_repository.dart` (e.g., `lead_repository.dart`)
- **Screens**: `*_screen.dart` (e.g., `lead_screen.dart`)
- **Widgets**: Descriptive names (e.g., `lead_detail_card.dart`)

---

## 🔄 Data Flow

### Typical Data Flow Pattern

```
User Action (UI)
    ↓
Screen/Widget
    ↓
Repository (Data Access)
    ↓
Service (Business Logic)
    ↓
Database Service / API
    ↓
Supabase / External API
    ↓
Response → Model → Repository → Service → UI Update
```

### Example: Creating a Lead

```
1. User fills form in `create_lead_screen.dart`
   ↓
2. Screen calls `LeadService.createLead()`
   ↓
3. Service calls `DatabaseService.createLead()`
   ↓
4. Database service inserts into Supabase `leads` table
   ↓
5. Database trigger generates `lead_id` with "TIG" prefix
   ↓
6. Response returns `Lead` model
   ↓
7. Service returns to screen
   ↓
8. Screen shows success message and navigates
```

---

## 🔑 Key Components

### Core Files (Start Here)

1. **`main.dart`**
   - Application entry point
   - Initializes Supabase, Firebase, providers
   - Sets up error handling
   - Routes to `AuthWrapper`

2. **`core/constants/constants.dart`**
   - API endpoints
   - Supabase credentials
   - App-wide constants

3. **`core/config/supabase_config.dart`**
   - Supabase client initialization
   - Database connection

### Data Layer Files

1. **`data/services/database_service.dart`** ⭐
   - **Most important service file**
   - Contains all database operations
   - Lead, customer, ticket, booking CRUD
   - ID generation logic (TIG, TIC, TIK prefixes)

2. **`data/models/models.dart`**
   - Exports all model classes
   - Import this for type definitions

3. **`data/repositories/*_repository.dart`**
   - Repository pattern implementation
   - Abstracts data sources

### Presentation Layer Files

1. **`presentation/pages/auth_wrapper.dart`**
   - Authentication routing
   - Determines login vs. home screen

2. **`presentation/screens/dashboard/home_screen.dart`**
   - Main dashboard after login
   - Navigation hub

3. **`presentation/screens/leads/lead_detail_screen.dart`**
   - Comprehensive lead management
   - Multiple tabs and features

### Shared Files

1. **`shared/managers/auth_state_manager.dart`**
   - Authentication state management
   - Session persistence

2. **`shared/helpers/notification_helper.dart`**
   - Notification creation utilities

---

## 🛠️ Development Workflow

### Adding a New Feature

1. **Create Model** (`data/models/feature_model.dart`)
   ```dart
   class Feature {
     final String id;
     // ... properties
   }
   ```

2. **Create Service** (`data/services/feature_service.dart`)
   ```dart
   class FeatureService {
     static Future<Feature> createFeature(...) async {
       return await DatabaseService.createFeature(...);
     }
   }
   ```

3. **Create Repository** (`data/repositories/feature_repository.dart`)
   ```dart
   class FeatureRepository {
     Future<List<Feature>> getFeatures() async {
       return await FeatureService.getFeatures();
     }
   }
   ```

4. **Create Screen** (`presentation/screens/features/feature_screen.dart`)
   ```dart
   class FeatureScreen extends StatefulWidget {
     // ... implementation
   }
   ```

5. **Add Navigation** (in appropriate screen/router)

### Modifying Existing Features

1. **Find the feature** in `presentation/screens/`
2. **Check the service** in `data/services/`
3. **Update the model** if needed in `data/models/`
4. **Modify database operations** in `database_service.dart`

---

## 📝 Naming Conventions

### Files
- **Screens**: `*_screen.dart` (e.g., `lead_screen.dart`)
- **Widgets**: Descriptive names (e.g., `lead_detail_card.dart`)
- **Services**: `*_service.dart` (e.g., `lead_service.dart`)
- **Models**: `*_model.dart` (e.g., `lead_model.dart`)
- **Repositories**: `*_repository.dart` (e.g., `lead_repository.dart`)

### Classes
- **Screens**: `*Screen` (e.g., `LeadScreen`)
- **Widgets**: Descriptive names (e.g., `LeadDetailCard`)
- **Services**: `*Service` (e.g., `LeadService`)
- **Models**: Feature name (e.g., `Lead`, `Customer`, `Ticket`)

### Variables
- **camelCase** for variables and methods
- **PascalCase** for classes and types
- **UPPER_SNAKE_CASE** for constants

---

## 🗺️ Navigation Map

### Finding Files by Purpose

**Authentication:**
- Login: `presentation/screens/auth/login_screen.dart`
- Auth Logic: `data/services/auth_service.dart`
- Auth State: `shared/managers/auth_state_manager.dart`

**Leads:**
- Lead List: `presentation/screens/leads/lead_screen.dart`
- Lead Detail: `presentation/screens/leads/lead_detail_screen.dart`
- Create Lead: `presentation/screens/leads/create_lead_screen.dart`
- Lead Service: `data/services/lead_service.dart`
- Lead Model: `data/models/lead_model.dart`
- Database Ops: `data/services/database_service.dart` (search for "Lead")

**Tickets:**
- Ticket Hub: `presentation/screens/ticket_hub_screen.dart`
- Ticket Detail: `presentation/screens/tickets/ticket_detail_screen.dart`
- Ticket Service: `data/services/ticket_service.dart`
- Ticket Model: `data/models/ticket_model.dart`
- Database Ops: `data/services/database_service.dart` (search for "Ticket")

**Bookings:**
- Booking List: `presentation/screens/bookings/booking_screen.dart`
- Booking Detail: `presentation/screens/bookings/booking_detail_screen.dart`
- Booking Service: `data/services/booking_service.dart`
- Booking Model: `data/models/booking_model.dart`

**Database Operations:**
- Main File: `data/services/database_service.dart`
- Contains: All CRUD operations for leads, customers, tickets, bookings, etc.
- ID Generation: Lead IDs (TIG), Customer Codes (TIC), Ticket Numbers (TIK)

---

## 🔍 Quick Reference

### Most Important Files

1. **`lib/main.dart`** - Start here to understand app initialization
2. **`data/services/database_service.dart`** - All database operations
3. **`presentation/pages/auth_wrapper.dart`** - App routing logic
4. **`core/constants/constants.dart`** - Configuration values
5. **`shared/managers/auth_state_manager.dart`** - Authentication state

### ID Generation Logic

- **Lead IDs**: `TIG` prefix + 10 alphanumeric chars (13 total)
  - Location: `database_service.dart` → `createMinimalLead()`
  - Database: `generate_lead_id()` function

- **Customer Codes**: `TIC` prefix + sequential number
  - Location: `booking_service.dart` → `generateCustomerCode()`

- **Ticket Numbers**: `TIK` prefix + 6-digit sequential number
  - Location: Database trigger `generate_ticket_number()`
  - Application: `database_service.dart` → `createTicket()`

---

## 📚 Additional Resources

- **README.md**: Project overview, setup instructions, features
- **Database Schema**: Check Supabase dashboard for table structures
- **API Documentation**: See `data/api/` for API integration details

---

## 🎯 Best Practices

1. **Always check `database_service.dart` first** for database operations
2. **Follow the feature-based organization** when adding new code
3. **Use models for type safety** - import from `data/models/models.dart`
4. **Keep business logic in services**, not in UI
5. **Use repositories** to abstract data sources
6. **Follow naming conventions** for consistency

---

## 🚀 Getting Started for New Developers

1. **Read this file** (ARCHITECTURE.md)
2. **Read README.md** for project overview
3. **Explore `main.dart`** to understand app initialization
4. **Check `database_service.dart`** to see data operations
5. **Browse `presentation/screens/`** to understand UI structure
6. **Start with a simple feature** (e.g., viewing leads) and trace the code

---

**Last Updated**: 2025-01-08
**Maintained By**: Development Team

