# Tigger Real Estate Management System - Database Documentation

## Overview

This document provides comprehensive documentation for the Tigger Real Estate Management System database. The database is designed to support a complete real estate management workflow including lead management, customer tracking, project management, site visits, bookings, and support tickets.

## Database Architecture

### Technology Stack
- **Database**: PostgreSQL 12+
- **Extensions**: uuid-ossp, pgcrypto
- **Primary Keys**: UUID (Universally Unique Identifiers)
- **Data Types**: JSONB for flexible data storage
- **Indexing**: Comprehensive indexing for performance optimization

### Design Principles
1. **Normalization**: Proper 3NF normalization to avoid data redundancy
2. **Referential Integrity**: Foreign key constraints ensure data consistency
3. **Audit Trail**: Timestamps and user tracking for all records
4. **Flexibility**: JSONB fields for custom data and metadata
5. **Performance**: Strategic indexing for common query patterns
6. **Scalability**: UUID primary keys support distributed systems

## Table Structure

### Core Tables

#### 1. Users Table
**Purpose**: System users including admins, managers, sales executives, and telecallers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Full name |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Email address |
| phone | VARCHAR(20) | NOT NULL | Phone number |
| profile_image_url | TEXT | | Profile image URL |
| role | VARCHAR(50) | NOT NULL | User role |
| designation | VARCHAR(100) | NOT NULL | Job designation |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| last_login_at | TIMESTAMP WITH TIME ZONE | | Last login timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |

**Indexes**:
- `idx_users_email` - Email lookup
- `idx_users_phone` - Phone lookup
- `idx_users_role` - Role-based queries
- `idx_users_is_active` - Active user filtering

#### 2. Developers Table
**Purpose**: Real estate developers with compliance and contact information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Company name |
| website | VARCHAR(255) | | Company website |
| logo_url | TEXT | | Company logo URL |
| address | TEXT | NOT NULL | Company address |
| state | VARCHAR(100) | NOT NULL | State |
| district | VARCHAR(100) | NOT NULL | District |
| city | VARCHAR(100) | NOT NULL | City |
| pincode | VARCHAR(10) | NOT NULL | Postal code |
| country | VARCHAR(100) | DEFAULT 'India' | Country |
| company_type | company_type | NOT NULL | Type of company |
| is_rera_registered | BOOLEAN | NOT NULL | RERA registration status |
| rera_number | VARCHAR(50) | | RERA registration number |
| gstin | VARCHAR(15) | NOT NULL | GST identification number |
| gstin_file_path | TEXT | | GST certificate file path |
| pan | VARCHAR(10) | NOT NULL | PAN number |
| pan_file_path | TEXT | | PAN certificate file path |
| aadhar | VARCHAR(12) | | Aadhar number |
| aadhar_file_path | TEXT | | Aadhar certificate file path |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_developers_name` - Company name lookup
- `idx_developers_city` - City-based queries
- `idx_developers_state` - State-based queries
- `idx_developers_is_active` - Active developer filtering

#### 3. Developer Contacts Table
**Purpose**: Contact persons for developers

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| developer_id | UUID | NOT NULL, FK to developers | Developer reference |
| name | VARCHAR(255) | NOT NULL | Contact person name |
| mobile | VARCHAR(20) | NOT NULL | Mobile number |
| designation | VARCHAR(100) | NOT NULL | Job designation |
| email | VARCHAR(255) | NOT NULL | Email address |
| is_primary | BOOLEAN | DEFAULT false | Primary contact flag |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |

**Indexes**:
- `idx_developer_contacts_developer_id` - Developer lookup
- `idx_developer_contacts_email` - Email lookup
- `idx_developer_contacts_mobile` - Mobile lookup
- `idx_developer_contacts_is_primary` - Primary contact filtering

#### 4. Projects Table
**Purpose**: Real estate projects with pricing, amenities, and specifications

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Project name |
| description | TEXT | | Project description |
| developer_id | UUID | NOT NULL, FK to developers | Developer reference |
| developer_name | VARCHAR(255) | NOT NULL | Developer name |
| type | project_type | NOT NULL | Project type enum |
| status | project_status | NOT NULL | Project status enum |
| address | TEXT | | Project address |
| city | VARCHAR(100) | | City |
| state | VARCHAR(100) | | State |
| pincode | VARCHAR(10) | | Postal code |
| country | VARCHAR(100) | DEFAULT 'India' | Country |
| total_area | DECIMAL(10,2) | | Total project area |
| total_units | INTEGER | | Total number of units |
| available_units | INTEGER | | Available units |
| starting_price | DECIMAL(15,2) | | Starting price |
| max_price | DECIMAL(15,2) | | Maximum price |
| price_unit | VARCHAR(50) | | Price unit (per sq ft, per unit) |
| amenities | TEXT[] | | Array of amenities |
| property_types | TEXT[] | | Array of property types |
| rera_number | VARCHAR(50) | | RERA number |
| launch_date | DATE | | Project launch date |
| possession_date | DATE | | Possession date |
| project_manager | VARCHAR(255) | | Project manager name |
| project_manager_id | UUID | FK to users | Project manager user ID |
| images | TEXT[] | | Array of image URLs |
| brochure_url | TEXT | | Brochure URL |
| floor_plan_url | TEXT | | Floor plan URL |
| location_map_url | TEXT | | Location map URL |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_projects_developer_id` - Developer lookup
- `idx_projects_name` - Project name lookup
- `idx_projects_city` - City-based queries
- `idx_projects_state` - State-based queries
- `idx_projects_type` - Project type filtering
- `idx_projects_status` - Project status filtering
- `idx_projects_is_active` - Active project filtering

#### 5. Customers Table
**Purpose**: Customer information and preferences

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Customer name |
| email | VARCHAR(255) | NOT NULL | Email address |
| phone | VARCHAR(20) | NOT NULL | Phone number |
| alternate_phone | VARCHAR(20) | | Alternate phone |
| address | TEXT | | Address |
| city | VARCHAR(100) | | City |
| state | VARCHAR(100) | | State |
| pincode | VARCHAR(10) | | Postal code |
| country | VARCHAR(100) | | Country |
| assigned_to | UUID | NOT NULL, FK to users | Assigned user ID |
| assigned_to_name | VARCHAR(255) | NOT NULL | Assigned user name |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| project_type | VARCHAR(50) | | Preferred project type |
| project_id | UUID | FK to projects | Associated project |
| project_name | VARCHAR(255) | | Project name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| last_contact_date | TIMESTAMP WITH TIME ZONE | | Last contact date |
| lead_count | INTEGER | DEFAULT 0 | Number of leads |
| booking_count | INTEGER | DEFAULT 0 | Number of bookings |
| site_visit_count | INTEGER | DEFAULT 0 | Number of site visits |
| is_active | BOOLEAN | DEFAULT true | Active status |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_customers_email` - Email lookup
- `idx_customers_phone` - Phone lookup
- `idx_customers_assigned_to` - Assigned user lookup
- `idx_customers_city` - City-based queries
- `idx_customers_state` - State-based queries
- `idx_customers_is_active` - Active customer filtering

#### 6. Leads Table
**Purpose**: Lead tracking and management with follow-up scheduling

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| lead_id | VARCHAR(50) | UNIQUE, NOT NULL | Display ID (LD-1001) |
| customer_name | VARCHAR(255) | NOT NULL | Customer name |
| email | VARCHAR(255) | NOT NULL | Email address |
| phone | VARCHAR(20) | NOT NULL | Phone number |
| alternate_phone | VARCHAR(20) | | Alternate phone |
| address | TEXT | | Address |
| city | VARCHAR(100) | | City |
| state | VARCHAR(100) | | State |
| pincode | VARCHAR(10) | | Postal code |
| status | lead_status | NOT NULL | Lead status enum |
| sub_status | lead_sub_status | NOT NULL | Lead sub-status enum |
| source | lead_source | NOT NULL | Lead source enum |
| property_type | property_type | NOT NULL | Property type enum |
| category_type | category_type | NOT NULL | Category type enum |
| project_id | UUID | FK to projects | Associated project |
| project_name | VARCHAR(255) | | Project name |
| budget_range | VARCHAR(100) | | Budget range |
| requirements | TEXT | | Customer requirements |
| notes | TEXT | | Additional notes |
| assigned_to | UUID | NOT NULL, FK to users | Assigned user ID |
| assigned_to_name | VARCHAR(255) | NOT NULL | Assigned user name |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| last_follow_up_date | TIMESTAMP WITH TIME ZONE | | Last follow-up date |
| next_follow_up_date | TIMESTAMP WITH TIME ZONE | | Next follow-up date |
| has_site_visit | BOOLEAN | DEFAULT false | Site visit flag |
| follow_up_count | INTEGER | DEFAULT 0 | Follow-up count |
| site_visit_count | INTEGER | DEFAULT 0 | Site visit count |
| is_duplicate | BOOLEAN | DEFAULT false | Duplicate flag |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_leads_lead_id` - Lead ID lookup
- `idx_leads_email` - Email lookup
- `idx_leads_phone` - Phone lookup
- `idx_leads_status` - Status filtering
- `idx_leads_sub_status` - Sub-status filtering
- `idx_leads_source` - Source filtering
- `idx_leads_assigned_to` - Assigned user lookup
- `idx_leads_project_id` - Project lookup
- `idx_leads_created_at` - Creation date queries
- `idx_leads_next_follow_up_date` - Follow-up scheduling

#### 7. Site Visits Table
**Purpose**: Site visit scheduling and completion tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| sr_no | VARCHAR(50) | UNIQUE, NOT NULL | Serial number (SV-1001) |
| lead_id | UUID | NOT NULL, FK to leads | Lead reference |
| customer_id | UUID | NOT NULL, FK to customers | Customer reference |
| customer_name | VARCHAR(255) | NOT NULL | Customer name |
| customer_phone | VARCHAR(20) | NOT NULL | Customer phone |
| project_id | UUID | NOT NULL, FK to projects | Project reference |
| project_name | VARCHAR(255) | NOT NULL | Project name |
| unit_no | VARCHAR(50) | | Unit number |
| visit_mode | visit_mode | NOT NULL | Visit mode enum |
| visit_type | visit_type | NOT NULL | Visit type enum |
| status | site_visit_status | NOT NULL | Visit status enum |
| telecaller_id | UUID | FK to users | Telecaller user ID |
| telecaller_name | VARCHAR(255) | | Telecaller name |
| allocated_at | TIMESTAMP WITH TIME ZONE | | Allocation timestamp |
| allocated_by | UUID | FK to users | Allocator user ID |
| source | VARCHAR(100) | | Source information |
| meeting_from | TIMESTAMP WITH TIME ZONE | | Meeting start time |
| meeting_to | TIMESTAMP WITH TIME ZONE | | Meeting end time |
| purpose | TEXT | | Visit purpose |
| address | TEXT | | Visit address |
| minutes | TEXT | | Meeting minutes |
| attender_id | UUID | FK to users | Attender user ID |
| attender_name | VARCHAR(255) | | Attender name |
| office_meeting_date_time | TIMESTAMP WITH TIME ZONE | | Office meeting time |
| feedback | TEXT | | Visit feedback |
| notes | TEXT | | Additional notes |
| attachments | TEXT[] | | Attachment URLs |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_site_visits_sr_no` - Serial number lookup
- `idx_site_visits_lead_id` - Lead lookup
- `idx_site_visits_customer_id` - Customer lookup
- `idx_site_visits_project_id` - Project lookup
- `idx_site_visits_status` - Status filtering
- `idx_site_visits_telecaller_id` - Telecaller lookup
- `idx_site_visits_meeting_from` - Meeting time queries
- `idx_site_visits_created_at` - Creation date queries

#### 8. Bookings Table
**Purpose**: Property bookings and payment management

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| sr_no | VARCHAR(50) | UNIQUE, NOT NULL | Serial number (BK001) |
| customer_id | UUID | NOT NULL, FK to customers | Customer reference |
| customer_name | VARCHAR(255) | NOT NULL | Customer name |
| customer_email | VARCHAR(255) | NOT NULL | Customer email |
| customer_phone | VARCHAR(20) | NOT NULL | Customer phone |
| lead_id | UUID | NOT NULL, FK to leads | Lead reference |
| project_id | UUID | NOT NULL, FK to projects | Project reference |
| project_name | VARCHAR(255) | NOT NULL | Project name |
| property_type | VARCHAR(100) | NOT NULL | Property type |
| category | VARCHAR(50) | NOT NULL | Category |
| unit_no | VARCHAR(50) | NOT NULL | Unit number |
| unit_details | TEXT | NOT NULL | Unit details |
| booking_amount | DECIMAL(15,2) | NOT NULL | Booking amount |
| advance_amount | DECIMAL(15,2) | | Advance amount |
| balance_amount | DECIMAL(15,2) | | Balance amount |
| payment_mode | payment_mode | NOT NULL | Payment mode enum |
| payment_reference | VARCHAR(255) | | Payment reference |
| sales_executive_id | UUID | NOT NULL, FK to users | Sales executive ID |
| sales_executive_name | VARCHAR(255) | NOT NULL | Sales executive name |
| commission | DECIMAL(10,2) | NOT NULL | Commission amount |
| approved_by | VARCHAR(255) | NOT NULL | Approver name |
| approved_by_id | UUID | FK to users | Approver user ID |
| approved_at | TIMESTAMP WITH TIME ZONE | | Approval timestamp |
| status | booking_status | NOT NULL | Booking status enum |
| booking_date | TIMESTAMP WITH TIME ZONE | NOT NULL | Booking date |
| possession_date | DATE | | Possession date |
| notes | TEXT | | Additional notes |
| terms_and_conditions | TEXT | | Terms and conditions |
| documents | TEXT[] | | Document URLs |
| created_by | UUID | NOT NULL, FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | NOT NULL | Creator name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Last update timestamp |
| custom_fields | JSONB | | Custom data fields |

**Indexes**:
- `idx_bookings_sr_no` - Serial number lookup
- `idx_bookings_customer_id` - Customer lookup
- `idx_bookings_lead_id` - Lead lookup
- `idx_bookings_project_id` - Project lookup
- `idx_bookings_status` - Status filtering
- `idx_bookings_sales_executive_id` - Sales executive lookup
- `idx_bookings_booking_date` - Booking date queries
- `idx_bookings_created_at` - Creation date queries

#### 9. Tasks Table
**Purpose**: Task management and follow-up tracking

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| title | VARCHAR(255) | NOT NULL | Task title |
| description | TEXT | NOT NULL | Task description |
| type | task_type | NOT NULL | Task type enum |
| priority | task_priority | NOT NULL | Task priority enum |
| status | task_status | NOT NULL | Task status enum |
| assigned_to | UUID | FK to users | Assigned user ID |
| assigned_to_name | VARCHAR(255) | | Assigned user name |
| created_by | UUID | FK to users | Creator user ID |
| created_by_name | VARCHAR(255) | | Creator name |
| lead_id | UUID | FK to leads | Associated lead |
| customer_id | UUID | FK to customers | Associated customer |
| project_id | UUID | FK to projects | Associated project |
| site_visit_id | UUID | FK to site_visits | Associated site visit |
| due_date | TIMESTAMP WITH TIME ZONE | | Due date |
| completed_at | TIMESTAMP WITH TIME ZONE | | Completion timestamp |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | | Last update timestamp |
| notes | TEXT | | Additional notes |
| attachments | TEXT[] | | Attachment URLs |
| metadata | JSONB | | Additional metadata |

**Indexes**:
- `idx_tasks_title` - Title search
- `idx_tasks_type` - Type filtering
- `idx_tasks_priority` - Priority filtering
- `idx_tasks_status` - Status filtering
- `idx_tasks_assigned_to` - Assigned user lookup
- `idx_tasks_lead_id` - Lead lookup
- `idx_tasks_customer_id` - Customer lookup
- `idx_tasks_project_id` - Project lookup
- `idx_tasks_due_date` - Due date queries
- `idx_tasks_created_at` - Creation date queries

#### 10. Tickets Table
**Purpose**: Support ticket management system

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| ticket_number | VARCHAR(50) | UNIQUE, NOT NULL | Ticket number (TK-1001) |
| lead_id | UUID | FK to leads | Associated lead |
| customer_id | UUID | FK to customers | Associated customer |
| project_id | UUID | FK to projects | Associated project |
| unit_number | VARCHAR(50) | | Unit number |
| contact_name | VARCHAR(255) | NOT NULL | Contact person name |
| contact_mobile | VARCHAR(20) | NOT NULL | Contact mobile |
| alternate_number | VARCHAR(20) | | Alternate number |
| issue_title | VARCHAR(255) | NOT NULL | Issue title |
| issue_description | TEXT | NOT NULL | Issue description |
| ticket_type | ticket_type | NOT NULL | Ticket type enum |
| service_type | service_type | NOT NULL | Service type enum |
| priority | ticket_priority | NOT NULL | Priority enum |
| status | ticket_status | NOT NULL | Status enum |
| assigned_to | UUID | FK to users | Assigned user ID |
| assigned_to_name | VARCHAR(255) | | Assigned user name |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | | Last update timestamp |
| resolved_at | TIMESTAMP WITH TIME ZONE | | Resolution timestamp |
| closed_at | TIMESTAMP WITH TIME ZONE | | Closure timestamp |
| resolution | TEXT | | Resolution details |
| notes | TEXT | | Additional notes |
| attachments | TEXT[] | | Attachment URLs |
| metadata | JSONB | | Additional metadata |

**Indexes**:
- `idx_tickets_ticket_number` - Ticket number lookup
- `idx_tickets_lead_id` - Lead lookup
- `idx_tickets_customer_id` - Customer lookup
- `idx_tickets_project_id` - Project lookup
- `idx_tickets_ticket_type` - Type filtering
- `idx_tickets_service_type` - Service type filtering
- `idx_tickets_priority` - Priority filtering
- `idx_tickets_status` - Status filtering
- `idx_tickets_assigned_to` - Assigned user lookup
- `idx_tickets_contact_mobile` - Contact mobile lookup
- `idx_tickets_created_at` - Creation date queries

#### 11. Notifications Table
**Purpose**: System notifications and alerts

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| title | VARCHAR(255) | NOT NULL | Notification title |
| message | TEXT | NOT NULL | Notification message |
| type | notification_type | NOT NULL | Notification type enum |
| priority | notification_priority | NOT NULL | Priority enum |
| status | notification_status | NOT NULL | Status enum |
| user_id | UUID | FK to users | Target user ID |
| related_id | UUID | | Related entity ID |
| related_type | VARCHAR(50) | | Related entity type |
| action_url | TEXT | | Action URL |
| data | JSONB | | Additional data |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| read_at | TIMESTAMP WITH TIME ZONE | | Read timestamp |
| archived_at | TIMESTAMP WITH TIME ZONE | | Archive timestamp |
| is_read | BOOLEAN | DEFAULT false | Read status |
| is_archived | BOOLEAN | DEFAULT false | Archive status |

**Indexes**:
- `idx_notifications_user_id` - User lookup
- `idx_notifications_type` - Type filtering
- `idx_notifications_priority` - Priority filtering
- `idx_notifications_status` - Status filtering
- `idx_notifications_related_id` - Related entity lookup
- `idx_notifications_related_type` - Related type filtering
- `idx_notifications_created_at` - Creation date queries
- `idx_notifications_is_read` - Read status filtering

#### 12. Bank Details Table
**Purpose**: Bank account information for payments

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| bank_name | VARCHAR(255) | NOT NULL | Bank name |
| account_number | VARCHAR(50) | NOT NULL | Account number |
| account_holder_name | VARCHAR(255) | NOT NULL | Account holder name |
| ifsc_code | VARCHAR(11) | NOT NULL | IFSC code |
| branch_name | VARCHAR(255) | NOT NULL | Branch name |
| account_type | bank_account_type | NOT NULL | Account type enum |
| bank_category | bank_category | NOT NULL | Bank category enum |
| micr_code | VARCHAR(9) | | MICR code |
| swift_code | VARCHAR(11) | | SWIFT code |
| address | TEXT | | Bank address |
| city | VARCHAR(100) | | City |
| state | VARCHAR(100) | | State |
| pincode | VARCHAR(10) | | Postal code |
| is_primary | BOOLEAN | DEFAULT false | Primary account flag |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_at | TIMESTAMP WITH TIME ZONE | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | | Last update timestamp |
| metadata | JSONB | | Additional metadata |

**Indexes**:
- `idx_bank_details_bank_name` - Bank name lookup
- `idx_bank_details_account_number` - Account number lookup
- `idx_bank_details_ifsc_code` - IFSC code lookup
- `idx_bank_details_is_primary` - Primary account filtering
- `idx_bank_details_is_active` - Active account filtering

## Enumerations

### Lead Enums
- **lead_status**: hot, warm, cold
- **lead_sub_status**: newLead, inProgress, closed
- **lead_source**: portal, walkIn, referral, website, socialMedia, other
- **property_type**: residential, commercial, industrial, land
- **category_type**: a, b, c

### Project Enums
- **project_status**: planning, underConstruction, completed, onHold, cancelled
- **project_type**: residential, commercial, industrial, mixed

### Booking Enums
- **booking_status**: pending, confirmed, cancelled, completed
- **payment_mode**: cash, cheque, online, bankTransfer, upi, other

### Site Visit Enums
- **site_visit_status**: scheduled, completed, cancelled, rescheduled
- **visit_mode**: physical, video, phone, office
- **visit_type**: propertyInspection, siteSurvey, clientMeeting, followUp

### Task Enums
- **task_status**: pending, inProgress, completed, cancelled, onHold
- **task_priority**: low, medium, high, urgent
- **task_type**: followUp, siteVisit, call, meeting, documentation, review, other

### Ticket Enums
- **ticket_status**: open, inProgress, pending, resolved, closed, cancelled
- **ticket_priority**: low, medium, high, urgent
- **ticket_type**: issue, request, complaint, inquiry
- **service_type**: maintenance, repair, cleaning, plumbing, electrical, hvac, security, other

### Notification Enums
- **notification_type**: lead, booking, siteVisit, ticket, system, reminder, alert
- **notification_priority**: low, medium, high, urgent
- **notification_status**: unread, read, archived

### Developer Enums
- **company_type**: pvtLtd, llp, partnership, proprietorship

### Bank Enums
- **bank_account_type**: savings, current, fixedDeposit, recurringDeposit
- **bank_category**: savings, current, fixedDeposit, recurringDeposit

## Functions and Triggers

### Functions

#### 1. update_updated_at_column()
**Purpose**: Updates the updated_at timestamp when a record is modified
**Usage**: Applied as a trigger to all tables with updated_at column

#### 2. generate_lead_id()
**Purpose**: Generates sequential lead IDs in format LD-XXXX
**Usage**: Applied as a trigger to leads table

#### 3. generate_site_visit_sr_no()
**Purpose**: Generates sequential site visit serial numbers in format SV-XXXX
**Usage**: Applied as a trigger to site_visits table

#### 4. generate_booking_sr_no()
**Purpose**: Generates sequential booking serial numbers in format BKXXX
**Usage**: Applied as a trigger to bookings table

#### 5. generate_ticket_number()
**Purpose**: Generates sequential ticket numbers in format TK-XXXX
**Usage**: Applied as a trigger to tickets table

### Triggers

All tables with an `updated_at` column have a trigger that automatically updates the timestamp when the record is modified.

## Views

### 1. dashboard_stats
**Purpose**: Provides dashboard statistics
**Columns**:
- leads_last_30_days: Number of leads created in last 30 days
- hot_leads: Number of hot leads
- warm_leads: Number of warm leads
- cold_leads: Number of cold leads
- bookings_last_30_days: Number of bookings in last 30 days
- site_visits_last_30_days: Number of site visits in last 30 days
- open_tickets: Number of open tickets
- upcoming_tasks: Number of upcoming tasks

### 2. lead_conversion_funnel
**Purpose**: Shows lead conversion funnel statistics
**Columns**:
- stage: Conversion stage name
- count: Number of records at this stage
- percentage: Percentage of total leads

### 3. sales_performance
**Purpose**: Shows sales performance by user
**Columns**:
- user_id: User ID
- user_name: User name
- role: User role
- total_leads: Total leads assigned
- total_site_visits: Total site visits
- total_bookings: Total bookings
- total_booking_value: Total booking value
- avg_commission: Average commission

### 4. project_performance
**Purpose**: Shows project performance statistics
**Columns**:
- project_id: Project ID
- project_name: Project name
- developer_name: Developer name
- city: Project city
- state: Project state
- total_leads: Total leads for project
- total_site_visits: Total site visits for project
- total_bookings: Total bookings for project
- total_booking_value: Total booking value
- total_units: Total units in project
- available_units: Available units
- occupancy_percentage: Occupancy percentage

## Sample Data

The database includes sample data for testing and development:

### Users
- Admin User (admin@tigger.com)
- John Manager (john.manager@tigger.com)
- Sarah Sales (sarah.sales@tigger.com)
- Mike Telecaller (mike.telecaller@tigger.com)

### Developer
- ABC Developers Pvt Ltd with RERA registration and compliance details

### Project
- Green Valley Apartments with pricing and amenities

### Customer
- Amit Patel with contact information

### Lead
- Sample lead for Amit Patel

## Performance Considerations

### Indexing Strategy
1. **Primary Keys**: Automatically indexed
2. **Foreign Keys**: Indexed for join performance
3. **Status Fields**: Indexed for filtering
4. **Date Fields**: Indexed for time-based queries
5. **Email/Phone Fields**: Indexed for lookups
6. **Name Fields**: Indexed for search functionality

### Query Optimization
1. Use provided views for common aggregations
2. Leverage indexes for filtering and sorting
3. Use JSONB operators for custom field queries
4. Consider partitioning for large tables in production

### Maintenance
1. Regular VACUUM and ANALYZE operations
2. Monitor index usage and add new indexes as needed
3. Regular backup and recovery testing
4. Performance monitoring and optimization

## Security Considerations

### Access Control
1. Use application-level user accounts
2. Grant minimal required permissions
3. Implement row-level security if needed
4. Regular security audits

### Data Protection
1. Use SSL connections in production
2. Encrypt sensitive data at application level
3. Implement proper backup and recovery procedures
4. Regular security updates

## Backup and Recovery

### Backup Strategy
1. **Full Backups**: Daily full database backups
2. **Incremental Backups**: Hourly incremental backups
3. **Transaction Log Backups**: Continuous transaction log backups
4. **Point-in-Time Recovery**: Support for point-in-time recovery

### Recovery Procedures
1. **Full Recovery**: Restore from full backup
2. **Incremental Recovery**: Apply incremental backups
3. **Point-in-Time Recovery**: Restore to specific timestamp
4. **Testing**: Regular recovery testing

## Monitoring and Maintenance

### Performance Monitoring
1. **Query Performance**: Monitor slow queries
2. **Index Usage**: Track index utilization
3. **Connection Pooling**: Monitor connection usage
4. **Resource Usage**: Track CPU, memory, and disk usage

### Regular Maintenance
1. **Statistics Updates**: Regular ANALYZE operations
2. **Index Maintenance**: Reindex when needed
3. **Vacuum Operations**: Regular VACUUM operations
4. **Log Management**: Regular log rotation and cleanup

## Troubleshooting

### Common Issues
1. **Permission Denied**: Check user permissions
2. **Extension Not Found**: Install required extensions
3. **Constraint Violations**: Check foreign key references
4. **Performance Issues**: Check index usage and query plans

### Debug Commands
1. **Database Size**: Check database size
2. **Active Connections**: Monitor active connections
3. **Table Statistics**: Check table statistics
4. **Index Usage**: Monitor index usage

## Version History

- **v1.0** - Initial database schema
- **v1.1** - Added comprehensive indexing
- **v1.2** - Added performance views
- **v1.3** - Added sample data and migration script

## Support

For issues or questions:
1. Check the database documentation
2. Review PostgreSQL logs
3. Verify schema integrity
4. Check application logs

## License

This database schema is part of the Tigger Real Estate Management System and follows the same licensing terms.
