# 🚀 Quick Reference Guide

Quick lookup guide for common development tasks and file locations.

## 📍 File Locations by Feature

### Authentication
| Task | File Location |
|------|---------------|
| Login Screen | `lib/presentation/screens/auth/login_screen.dart` |
| Auth Logic | `lib/data/services/auth_service.dart` |
| Auth State | `lib/shared/managers/auth_state_manager.dart` |
| Auth Routing | `lib/presentation/pages/auth_wrapper.dart` |

### Leads
| Task | File Location |
|------|---------------|
| Lead List | `lib/presentation/screens/leads/lead_screen.dart` |
| Lead Detail | `lib/presentation/screens/leads/lead_detail_screen.dart` |
| Create Lead | `lib/presentation/screens/leads/create_lead_screen.dart` |
| Lead Service | `lib/data/services/lead_service.dart` |
| Lead Model | `lib/data/models/lead_model.dart` |
| Lead DB Ops | `lib/data/services/database_service.dart` (search "Lead") |

### Tickets
| Task | File Location |
|------|---------------|
| Ticket Hub | `lib/presentation/screens/ticket_hub_screen.dart` |
| Ticket Detail | `lib/presentation/screens/tickets/ticket_detail_screen.dart` |
| Ticket Service | `lib/data/services/ticket_service.dart` |
| Ticket Model | `lib/data/models/ticket_model.dart` |
| Ticket DB Ops | `lib/data/services/database_service.dart` (search "Ticket") |

### Bookings
| Task | File Location |
|------|---------------|
| Booking List | `lib/presentation/screens/bookings/booking_screen.dart` |
| Booking Detail | `lib/presentation/screens/bookings/booking_detail_screen.dart` |
| Booking Service | `lib/data/services/booking_service.dart` |
| Booking Model | `lib/data/models/booking_model.dart` |

### Customers
| Task | File Location |
|------|---------------|
| Customer Screen | `lib/presentation/screens/customer_screen.dart` |
| Customer Service | `lib/data/services/customer_service.dart` |
| Customer Model | `lib/data/models/customer_model.dart` |
| Customer Code Gen | `lib/data/services/booking_service.dart` (generateCustomerCode) |

### Projects
| Task | File Location |
|------|---------------|
| Project List | `lib/presentation/screens/projects/active_projects_screen.dart` |
| Project Detail | `lib/presentation/screens/projects/project_detail_screen.dart` |
| Site Visits | `lib/presentation/screens/projects/site_visit_screen.dart` |
| Project Service | `lib/data/services/project_service.dart` |

### Vendors
| Task | File Location |
|------|---------------|
| Vendor List | `lib/presentation/screens/vendors/vendor_screen.dart` |
| Vendor Profile | `lib/presentation/screens/vendors/vendor_profile_screen.dart` |
| Vendor Service | `lib/data/services/vendor_service.dart` |

### Dashboard
| Task | File Location |
|------|---------------|
| Home Screen | `lib/presentation/screens/dashboard/home_screen.dart` |
| Dashboard Stats | `lib/presentation/screens/dashboard/dashboard_screen.dart` |
| Dashboard Service | `lib/data/services/dashboard_service.dart` |

## 🔑 Key Files

### Core Files
- **Entry Point**: `lib/main.dart`
- **Constants**: `lib/core/constants/constants.dart`
- **Supabase Config**: `lib/core/config/supabase_config.dart`

### Database Operations
- **Main DB Service**: `lib/data/services/database_service.dart` ⭐
  - Contains all CRUD operations
  - ID generation (TIG, TIC, TIK)
  - Lead, Customer, Ticket, Booking operations

### State Management
- **Auth State**: `lib/shared/managers/auth_state_manager.dart`
- **Notifications**: `lib/shared/managers/notification_manager.dart`

### Models
- **All Models**: `lib/data/models/models.dart` (import this)

## 🆔 ID Generation

### Lead IDs (TIG prefix)
- **Format**: `TIG` + 10 alphanumeric characters (13 total)
- **Location**: 
  - App: `database_service.dart` → `createMinimalLead()`
  - DB: `generate_lead_id()` function

### Customer Codes (TIC prefix)
- **Format**: `TIC` + sequential number (e.g., TIC001, TIC002)
- **Location**: `booking_service.dart` → `generateCustomerCode()`

### Ticket Numbers (TIK prefix)
- **Format**: `TIK` + 6-digit number (e.g., TIK000001)
- **Location**: 
  - DB: `generate_ticket_number()` trigger
  - App: `database_service.dart` → `createTicket()`

## 🔍 Common Tasks

### Adding a New Screen
1. Create file in `lib/presentation/screens/[feature]/`
2. Follow naming: `*_screen.dart`
3. Add navigation in appropriate parent screen

### Adding a New Service
1. Create file in `lib/data/services/`
2. Follow naming: `*_service.dart`
3. Add methods to `database_service.dart` if DB operations needed

### Adding a New Model
1. Create file in `lib/data/models/`
2. Follow naming: `*_model.dart`
3. Export in `models.dart`

### Modifying Database Operations
1. Open `lib/data/services/database_service.dart`
2. Search for feature name (e.g., "Lead", "Ticket")
3. Find relevant method and modify

## 📝 Naming Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `*_screen.dart` | `lead_screen.dart` |
| Services | `*_service.dart` | `lead_service.dart` |
| Models | `*_model.dart` | `lead_model.dart` |
| Repositories | `*_repository.dart` | `lead_repository.dart` |
| Widgets | Descriptive | `lead_detail_card.dart` |

## 🗂️ Directory Quick Access

```
lib/
├── main.dart                    # Start here
├── core/                        # Config & constants
├── data/
│   ├── services/               # Business logic ⭐
│   ├── models/                 # Data models
│   └── repositories/           # Data access
├── presentation/
│   ├── pages/                  # Routing
│   └── screens/                # UI screens
└── shared/                     # Utilities
```

## 🚨 Important Notes

1. **Always check `database_service.dart` first** for database operations
2. **Use models from `models.dart`** for type safety
3. **Follow feature-based organization** when adding files
4. **Keep business logic in services**, not UI
5. **ID prefixes**: TIG (leads), TIC (customers), TIK (tickets)

## 📚 Documentation

- **Architecture Guide**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Project Overview**: [README.md](README.md)

---

**Quick Tip**: Use your IDE's "Go to Definition" (F12) or "Find Usages" to navigate between related files!

