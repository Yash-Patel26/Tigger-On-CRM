-- Tigger Real Estate Management System - Database Migration Script
-- PostgreSQL 12+ Compatible
-- This script creates the database step by step with error handling

-- =============================================
-- MIGRATION SCRIPT
-- =============================================

-- Start transaction
BEGIN;

-- Check if we're connected to a database
DO $$
BEGIN
    IF current_database() IS NULL THEN
        RAISE EXCEPTION 'No database selected. Please connect to a database first.';
    END IF;
END $$;

-- =============================================
-- STEP 1: CREATE EXTENSIONS
-- =============================================

-- Enable required extensions
DO $$
BEGIN
    -- Check if uuid-ossp extension exists
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
        CREATE EXTENSION "uuid-ossp";
        RAISE NOTICE 'Created uuid-ossp extension';
    ELSE
        RAISE NOTICE 'uuid-ossp extension already exists';
    END IF;

    -- Check if pgcrypto extension exists
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
        CREATE EXTENSION pgcrypto;
        RAISE NOTICE 'Created pgcrypto extension';
    ELSE
        RAISE NOTICE 'pgcrypto extension already exists';
    END IF;
END $$;

-- =============================================
-- STEP 2: CREATE ENUMS
-- =============================================

-- Lead related enums
DO $$
BEGIN
    -- Lead status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lead_status') THEN
        CREATE TYPE lead_status AS ENUM ('hot', 'warm', 'cold');
        RAISE NOTICE 'Created lead_status enum';
    END IF;

    -- Lead sub status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lead_sub_status') THEN
        CREATE TYPE lead_sub_status AS ENUM ('newLead', 'inProgress', 'closed');
        RAISE NOTICE 'Created lead_sub_status enum';
    END IF;

    -- Lead source enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lead_source') THEN
        CREATE TYPE lead_source AS ENUM ('portal', 'walkIn', 'referral', 'website', 'socialMedia', 'other');
        RAISE NOTICE 'Created lead_source enum';
    END IF;

    -- Property type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'property_type') THEN
        CREATE TYPE property_type AS ENUM ('residential', 'commercial', 'industrial', 'land');
        RAISE NOTICE 'Created property_type enum';
    END IF;

    -- Category type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'category_type') THEN
        CREATE TYPE category_type AS ENUM ('a', 'b', 'c');
        RAISE NOTICE 'Created category_type enum';
    END IF;
END $$;

-- Project related enums
DO $$
BEGIN
    -- Project status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_status') THEN
        CREATE TYPE project_status AS ENUM ('planning', 'underConstruction', 'completed', 'onHold', 'cancelled');
        RAISE NOTICE 'Created project_status enum';
    END IF;

    -- Project type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'project_type') THEN
        CREATE TYPE project_type AS ENUM ('residential', 'commercial', 'industrial', 'mixed');
        RAISE NOTICE 'Created project_type enum';
    END IF;
END $$;

-- Booking related enums
DO $$
BEGIN
    -- Booking status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'booking_status') THEN
        CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
        RAISE NOTICE 'Created booking_status enum';
    END IF;

    -- Payment mode enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_mode') THEN
        CREATE TYPE payment_mode AS ENUM ('cash', 'cheque', 'online', 'bankTransfer', 'upi', 'other');
        RAISE NOTICE 'Created payment_mode enum';
    END IF;
END $$;

-- Site visit related enums
DO $$
BEGIN
    -- Site visit status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'site_visit_status') THEN
        CREATE TYPE site_visit_status AS ENUM ('scheduled', 'completed', 'cancelled', 'rescheduled');
        RAISE NOTICE 'Created site_visit_status enum';
    END IF;

    -- Visit mode enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'visit_mode') THEN
        CREATE TYPE visit_mode AS ENUM ('physical', 'video', 'phone', 'office');
        RAISE NOTICE 'Created visit_mode enum';
    END IF;

    -- Visit type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'visit_type') THEN
        CREATE TYPE visit_type AS ENUM ('propertyInspection', 'siteSurvey', 'clientMeeting', 'followUp');
        RAISE NOTICE 'Created visit_type enum';
    END IF;
END $$;

-- Task related enums
DO $$
BEGIN
    -- Task status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_status') THEN
        CREATE TYPE task_status AS ENUM ('pending', 'inProgress', 'completed', 'cancelled', 'onHold');
        RAISE NOTICE 'Created task_status enum';
    END IF;

    -- Task priority enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_priority') THEN
        CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');
        RAISE NOTICE 'Created task_priority enum';
    END IF;

    -- Task type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_type') THEN
        CREATE TYPE task_type AS ENUM ('followUp', 'siteVisit', 'call', 'meeting', 'documentation', 'review', 'other');
        RAISE NOTICE 'Created task_type enum';
    END IF;
END $$;

-- Ticket related enums
DO $$
BEGIN
    -- Ticket status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_status') THEN
        CREATE TYPE ticket_status AS ENUM ('open', 'inProgress', 'pending', 'resolved', 'closed', 'cancelled');
        RAISE NOTICE 'Created ticket_status enum';
    END IF;

    -- Ticket priority enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_priority') THEN
        CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent');
        RAISE NOTICE 'Created ticket_priority enum';
    END IF;

    -- Ticket type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'ticket_type') THEN
        CREATE TYPE ticket_type AS ENUM ('issue', 'request', 'complaint', 'inquiry');
        RAISE NOTICE 'Created ticket_type enum';
    END IF;

    -- Service type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'service_type') THEN
        CREATE TYPE service_type AS ENUM ('maintenance', 'repair', 'cleaning', 'plumbing', 'electrical', 'hvac', 'security', 'other');
        RAISE NOTICE 'Created service_type enum';
    END IF;
END $$;

-- Notification related enums
DO $$
BEGIN
    -- Notification type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_type') THEN
        CREATE TYPE notification_type AS ENUM ('lead', 'booking', 'siteVisit', 'ticket', 'system', 'reminder', 'alert');
        RAISE NOTICE 'Created notification_type enum';
    END IF;

    -- Notification priority enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_priority') THEN
        CREATE TYPE notification_priority AS ENUM ('low', 'medium', 'high', 'urgent');
        RAISE NOTICE 'Created notification_priority enum';
    END IF;

    -- Notification status enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'notification_status') THEN
        CREATE TYPE notification_status AS ENUM ('unread', 'read', 'archived');
        RAISE NOTICE 'Created notification_status enum';
    END IF;
END $$;

-- Developer related enums
DO $$
BEGIN
    -- Company type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'company_type') THEN
        CREATE TYPE company_type AS ENUM ('pvtLtd', 'llp', 'partnership', 'proprietorship');
        RAISE NOTICE 'Created company_type enum';
    END IF;
END $$;

-- Bank related enums
DO $$
BEGIN
    -- Bank account type enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'bank_account_type') THEN
        CREATE TYPE bank_account_type AS ENUM ('savings', 'current', 'fixedDeposit', 'recurringDeposit');
        RAISE NOTICE 'Created bank_account_type enum';
    END IF;

    -- Bank category enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'bank_category') THEN
        CREATE TYPE bank_category AS ENUM ('savings', 'current', 'fixedDeposit', 'recurringDeposit');
        RAISE NOTICE 'Created bank_category enum';
    END IF;
END $$;

-- =============================================
-- STEP 3: CREATE CORE TABLES
-- =============================================

-- Users table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
        CREATE TABLE users (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) UNIQUE NOT NULL,
            phone VARCHAR(20) NOT NULL,
            profile_image_url TEXT,
            role VARCHAR(50) NOT NULL,
            designation VARCHAR(100) NOT NULL,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_login_at TIMESTAMP WITH TIME ZONE,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created users table';
    ELSE
        RAISE NOTICE 'Users table already exists';
    END IF;
END $$;

-- Developer contacts table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'developer_contacts') THEN
        CREATE TABLE developer_contacts (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            developer_id UUID NOT NULL,
            name VARCHAR(255) NOT NULL,
            mobile VARCHAR(20) NOT NULL,
            designation VARCHAR(100) NOT NULL,
            email VARCHAR(255) NOT NULL,
            is_primary BOOLEAN DEFAULT false,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        RAISE NOTICE 'Created developer_contacts table';
    ELSE
        RAISE NOTICE 'Developer_contacts table already exists';
    END IF;
END $$;

-- Developers table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'developers') THEN
        CREATE TABLE developers (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            name VARCHAR(255) NOT NULL,
            website VARCHAR(255),
            logo_url TEXT,
            address TEXT NOT NULL,
            state VARCHAR(100) NOT NULL,
            district VARCHAR(100) NOT NULL,
            city VARCHAR(100) NOT NULL,
            pincode VARCHAR(10) NOT NULL,
            country VARCHAR(100) DEFAULT 'India',
            company_type company_type NOT NULL,
            is_rera_registered BOOLEAN NOT NULL,
            rera_number VARCHAR(50),
            gstin VARCHAR(15) NOT NULL,
            gstin_file_path TEXT,
            pan VARCHAR(10) NOT NULL,
            pan_file_path TEXT,
            aadhar VARCHAR(12),
            aadhar_file_path TEXT,
            is_active BOOLEAN DEFAULT true,
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            custom_fields JSONB
        );
        RAISE NOTICE 'Created developers table';
    ELSE
        RAISE NOTICE 'Developers table already exists';
    END IF;
END $$;

-- Add foreign key constraint for developer_contacts
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_developer_contacts_developer_id'
    ) THEN
        ALTER TABLE developer_contacts 
        ADD CONSTRAINT fk_developer_contacts_developer_id 
        FOREIGN KEY (developer_id) REFERENCES developers(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added foreign key constraint for developer_contacts';
    END IF;
END $$;

-- Projects table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'projects') THEN
        CREATE TABLE projects (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            name VARCHAR(255) NOT NULL,
            description TEXT,
            developer_id UUID NOT NULL REFERENCES developers(id),
            developer_name VARCHAR(255) NOT NULL,
            type project_type NOT NULL,
            status project_status NOT NULL,
            address TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            country VARCHAR(100) DEFAULT 'India',
            total_area DECIMAL(10,2),
            total_units INTEGER,
            available_units INTEGER,
            starting_price DECIMAL(15,2),
            max_price DECIMAL(15,2),
            price_unit VARCHAR(50),
            amenities TEXT[],
            property_types TEXT[],
            rera_number VARCHAR(50),
            launch_date DATE,
            possession_date DATE,
            project_manager VARCHAR(255),
            project_manager_id UUID REFERENCES users(id),
            images TEXT[],
            brochure_url TEXT,
            floor_plan_url TEXT,
            location_map_url TEXT,
            is_active BOOLEAN DEFAULT true,
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            custom_fields JSONB
        );
        RAISE NOTICE 'Created projects table';
    ELSE
        RAISE NOTICE 'Projects table already exists';
    END IF;
END $$;

-- Customers table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'customers') THEN
        CREATE TABLE customers (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            alternate_phone VARCHAR(20),
            address TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            country VARCHAR(100),
            assigned_to UUID NOT NULL REFERENCES users(id),
            assigned_to_name VARCHAR(255) NOT NULL,
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            project_type VARCHAR(50),
            project_id UUID REFERENCES projects(id),
            project_name VARCHAR(255),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_contact_date TIMESTAMP WITH TIME ZONE,
            lead_count INTEGER DEFAULT 0,
            booking_count INTEGER DEFAULT 0,
            site_visit_count INTEGER DEFAULT 0,
            is_active BOOLEAN DEFAULT true,
            custom_fields JSONB
        );
        RAISE NOTICE 'Created customers table';
    ELSE
        RAISE NOTICE 'Customers table already exists';
    END IF;
END $$;

-- Leads table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'leads') THEN
        CREATE TABLE leads (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            lead_id VARCHAR(50) UNIQUE NOT NULL,
            customer_name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            phone VARCHAR(20) NOT NULL,
            alternate_phone VARCHAR(20),
            address TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            status lead_status NOT NULL,
            sub_status lead_sub_status NOT NULL,
            source lead_source NOT NULL,
            property_type property_type NOT NULL,
            category_type category_type NOT NULL,
            project_id UUID REFERENCES projects(id),
            project_name VARCHAR(255),
            budget_range VARCHAR(100),
            requirements TEXT,
            notes TEXT,
            assigned_to UUID NOT NULL REFERENCES users(id),
            assigned_to_name VARCHAR(255) NOT NULL,
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            last_follow_up_date TIMESTAMP WITH TIME ZONE,
            next_follow_up_date TIMESTAMP WITH TIME ZONE,
            has_site_visit BOOLEAN DEFAULT false,
            follow_up_count INTEGER DEFAULT 0,
            site_visit_count INTEGER DEFAULT 0,
            is_duplicate BOOLEAN DEFAULT false,
            custom_fields JSONB
        );
        RAISE NOTICE 'Created leads table';
    ELSE
        RAISE NOTICE 'Leads table already exists';
    END IF;
END $$;

-- Site visits table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'site_visits') THEN
        CREATE TABLE site_visits (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            sr_no VARCHAR(50) UNIQUE NOT NULL,
            lead_id UUID NOT NULL REFERENCES leads(id),
            customer_id UUID NOT NULL REFERENCES customers(id),
            customer_name VARCHAR(255) NOT NULL,
            customer_phone VARCHAR(20) NOT NULL,
            project_id UUID NOT NULL REFERENCES projects(id),
            project_name VARCHAR(255) NOT NULL,
            unit_no VARCHAR(50),
            visit_mode visit_mode NOT NULL,
            visit_type visit_type NOT NULL,
            status site_visit_status NOT NULL,
            telecaller_id UUID REFERENCES users(id),
            telecaller_name VARCHAR(255),
            allocated_at TIMESTAMP WITH TIME ZONE,
            allocated_by UUID REFERENCES users(id),
            source VARCHAR(100),
            meeting_from TIMESTAMP WITH TIME ZONE,
            meeting_to TIMESTAMP WITH TIME ZONE,
            purpose TEXT,
            address TEXT,
            minutes TEXT,
            attender_id UUID REFERENCES users(id),
            attender_name VARCHAR(255),
            office_meeting_date_time TIMESTAMP WITH TIME ZONE,
            feedback TEXT,
            notes TEXT,
            attachments TEXT[],
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            custom_fields JSONB
        );
        RAISE NOTICE 'Created site_visits table';
    ELSE
        RAISE NOTICE 'Site_visits table already exists';
    END IF;
END $$;

-- Bookings table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN
        CREATE TABLE bookings (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            sr_no VARCHAR(50) UNIQUE NOT NULL,
            customer_id UUID NOT NULL REFERENCES customers(id),
            customer_name VARCHAR(255) NOT NULL,
            customer_email VARCHAR(255) NOT NULL,
            customer_phone VARCHAR(20) NOT NULL,
            lead_id UUID NOT NULL REFERENCES leads(id),
            project_id UUID NOT NULL REFERENCES projects(id),
            project_name VARCHAR(255) NOT NULL,
            property_type VARCHAR(100) NOT NULL,
            category VARCHAR(50) NOT NULL,
            unit_no VARCHAR(50) NOT NULL,
            unit_details TEXT NOT NULL,
            booking_amount DECIMAL(15,2) NOT NULL,
            advance_amount DECIMAL(15,2),
            balance_amount DECIMAL(15,2),
            payment_mode payment_mode NOT NULL,
            payment_reference VARCHAR(255),
            sales_executive_id UUID NOT NULL REFERENCES users(id),
            sales_executive_name VARCHAR(255) NOT NULL,
            commission DECIMAL(10,2) NOT NULL,
            approved_by VARCHAR(255) NOT NULL,
            approved_by_id UUID REFERENCES users(id),
            approved_at TIMESTAMP WITH TIME ZONE,
            status booking_status NOT NULL,
            booking_date TIMESTAMP WITH TIME ZONE NOT NULL,
            possession_date DATE,
            notes TEXT,
            terms_and_conditions TEXT,
            documents TEXT[],
            created_by UUID NOT NULL REFERENCES users(id),
            created_by_name VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            custom_fields JSONB
        );
        RAISE NOTICE 'Created bookings table';
    ELSE
        RAISE NOTICE 'Bookings table already exists';
    END IF;
END $$;

-- Tasks table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tasks') THEN
        CREATE TABLE tasks (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL,
            type task_type NOT NULL,
            priority task_priority NOT NULL,
            status task_status NOT NULL,
            assigned_to UUID REFERENCES users(id),
            assigned_to_name VARCHAR(255),
            created_by UUID REFERENCES users(id),
            created_by_name VARCHAR(255),
            lead_id UUID REFERENCES leads(id),
            customer_id UUID REFERENCES customers(id),
            project_id UUID REFERENCES projects(id),
            site_visit_id UUID REFERENCES site_visits(id),
            due_date TIMESTAMP WITH TIME ZONE,
            completed_at TIMESTAMP WITH TIME ZONE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE,
            notes TEXT,
            attachments TEXT[],
            metadata JSONB
        );
        RAISE NOTICE 'Created tasks table';
    ELSE
        RAISE NOTICE 'Tasks table already exists';
    END IF;
END $$;

-- Tickets table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tickets') THEN
        CREATE TABLE tickets (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            ticket_number VARCHAR(50) UNIQUE NOT NULL,
            lead_id UUID REFERENCES leads(id),
            customer_id UUID REFERENCES customers(id),
            project_id UUID REFERENCES projects(id),
            unit_number VARCHAR(50),
            contact_name VARCHAR(255) NOT NULL,
            contact_mobile VARCHAR(20) NOT NULL,
            alternate_number VARCHAR(20),
            issue_title VARCHAR(255) NOT NULL,
            issue_description TEXT NOT NULL,
            ticket_type ticket_type NOT NULL,
            service_type service_type NOT NULL,
            priority ticket_priority NOT NULL,
            status ticket_status NOT NULL,
            assigned_to UUID REFERENCES users(id),
            assigned_to_name VARCHAR(255),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE,
            resolved_at TIMESTAMP WITH TIME ZONE,
            closed_at TIMESTAMP WITH TIME ZONE,
            resolution TEXT,
            notes TEXT,
            attachments TEXT[],
            metadata JSONB
        );
        RAISE NOTICE 'Created tickets table';
    ELSE
        RAISE NOTICE 'Tickets table already exists';
    END IF;
END $$;

-- Notifications table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notifications') THEN
        CREATE TABLE notifications (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            type notification_type NOT NULL,
            priority notification_priority NOT NULL,
            status notification_status NOT NULL,
            user_id UUID REFERENCES users(id),
            related_id UUID,
            related_type VARCHAR(50),
            action_url TEXT,
            data JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            read_at TIMESTAMP WITH TIME ZONE,
            archived_at TIMESTAMP WITH TIME ZONE,
            is_read BOOLEAN DEFAULT false,
            is_archived BOOLEAN DEFAULT false
        );
        RAISE NOTICE 'Created notifications table';
    ELSE
        RAISE NOTICE 'Notifications table already exists';
    END IF;
END $$;

-- Bank details table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bank_details') THEN
        CREATE TABLE bank_details (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            bank_name VARCHAR(255) NOT NULL,
            account_number VARCHAR(50) NOT NULL,
            account_holder_name VARCHAR(255) NOT NULL,
            ifsc_code VARCHAR(11) NOT NULL,
            branch_name VARCHAR(255) NOT NULL,
            account_type bank_account_type NOT NULL,
            bank_category bank_category NOT NULL,
            micr_code VARCHAR(9),
            swift_code VARCHAR(11),
            address TEXT,
            city VARCHAR(100),
            state VARCHAR(100),
            pincode VARCHAR(10),
            is_primary BOOLEAN DEFAULT false,
            is_active BOOLEAN DEFAULT true,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE,
            metadata JSONB
        );
        RAISE NOTICE 'Created bank_details table';
    ELSE
        RAISE NOTICE 'Bank_details table already exists';
    END IF;
END $$;

-- =============================================
-- STEP 4: CREATE INDEXES
-- =============================================

-- Users indexes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_email') THEN
        CREATE INDEX idx_users_email ON users(email);
        RAISE NOTICE 'Created idx_users_email index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_phone') THEN
        CREATE INDEX idx_users_phone ON users(phone);
        RAISE NOTICE 'Created idx_users_phone index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role') THEN
        CREATE INDEX idx_users_role ON users(role);
        RAISE NOTICE 'Created idx_users_role index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_is_active') THEN
        CREATE INDEX idx_users_is_active ON users(is_active);
        RAISE NOTICE 'Created idx_users_is_active index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_created_at') THEN
        CREATE INDEX idx_users_created_at ON users(created_at);
        RAISE NOTICE 'Created idx_users_created_at index';
    END IF;
END $$;

-- Leads indexes
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_lead_id') THEN
        CREATE INDEX idx_leads_lead_id ON leads(lead_id);
        RAISE NOTICE 'Created idx_leads_lead_id index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_email') THEN
        CREATE INDEX idx_leads_email ON leads(email);
        RAISE NOTICE 'Created idx_leads_email index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_phone') THEN
        CREATE INDEX idx_leads_phone ON leads(phone);
        RAISE NOTICE 'Created idx_leads_phone index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_status') THEN
        CREATE INDEX idx_leads_status ON leads(status);
        RAISE NOTICE 'Created idx_leads_status index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_assigned_to') THEN
        CREATE INDEX idx_leads_assigned_to ON leads(assigned_to);
        RAISE NOTICE 'Created idx_leads_assigned_to index';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_created_at') THEN
        CREATE INDEX idx_leads_created_at ON leads(created_at);
        RAISE NOTICE 'Created idx_leads_created_at index';
    END IF;
END $$;

-- Add more indexes for other tables as needed...

-- =============================================
-- STEP 5: CREATE FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        RAISE NOTICE 'Created update_updated_at_column function';
    END IF;
END $$;

-- Function to generate lead ID
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'generate_lead_id') THEN
        CREATE OR REPLACE FUNCTION generate_lead_id()
        RETURNS TRIGGER AS $$
        DECLARE
            next_number INTEGER;
        BEGIN
            SELECT COALESCE(MAX(CAST(SUBSTRING(lead_id FROM 4) AS INTEGER)), 0) + 1
            INTO next_number
            FROM leads
            WHERE lead_id LIKE 'LD-%';
            
            NEW.lead_id := 'LD-' || LPAD(next_number::TEXT, 4, '0');
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        RAISE NOTICE 'Created generate_lead_id function';
    END IF;
END $$;

-- Apply triggers
DO $$
BEGIN
    -- Updated at triggers
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_users_updated_at') THEN
        CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE 'Created update_users_updated_at trigger';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_leads_updated_at') THEN
        CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE 'Created update_leads_updated_at trigger';
    END IF;
    
    -- Lead ID generation trigger
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'generate_lead_id_trigger') THEN
        CREATE TRIGGER generate_lead_id_trigger
            BEFORE INSERT ON leads
            FOR EACH ROW
            WHEN (NEW.lead_id IS NULL OR NEW.lead_id = '')
            EXECUTE FUNCTION generate_lead_id();
        RAISE NOTICE 'Created generate_lead_id_trigger';
    END IF;
END $$;

-- =============================================
-- STEP 6: CREATE VIEWS
-- =============================================

-- Dashboard statistics view
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'dashboard_stats') THEN
        CREATE VIEW dashboard_stats AS
        SELECT 
            (SELECT COUNT(*) FROM leads WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as leads_last_30_days,
            (SELECT COUNT(*) FROM leads WHERE status = 'hot') as hot_leads,
            (SELECT COUNT(*) FROM leads WHERE status = 'warm') as warm_leads,
            (SELECT COUNT(*) FROM leads WHERE status = 'cold') as cold_leads,
            (SELECT COUNT(*) FROM bookings WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as bookings_last_30_days,
            (SELECT COUNT(*) FROM site_visits WHERE created_at >= CURRENT_DATE - INTERVAL '30 days') as site_visits_last_30_days,
            (SELECT COUNT(*) FROM tickets WHERE status IN ('open', 'inProgress', 'pending')) as open_tickets,
            (SELECT COUNT(*) FROM tasks WHERE status IN ('pending', 'inProgress') AND due_date <= CURRENT_DATE + INTERVAL '7 days') as upcoming_tasks;
        RAISE NOTICE 'Created dashboard_stats view';
    END IF;
END $$;

-- =============================================
-- STEP 7: INSERT SAMPLE DATA
-- =============================================

-- Insert sample users
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@tigger.com') THEN
        INSERT INTO users (id, name, email, phone, role, designation, is_active) VALUES
        ('550e8400-e29b-41d4-a716-446655440001', 'Admin User', 'admin@tigger.com', '+919876543210', 'admin', 'System Administrator', true),
        ('550e8400-e29b-41d4-a716-446655440002', 'John Manager', 'john.manager@tigger.com', '+919876543211', 'manager', 'Sales Manager', true),
        ('550e8400-e29b-41d4-a716-446655440003', 'Sarah Sales', 'sarah.sales@tigger.com', '+919876543212', 'sales_executive', 'Sales Executive', true),
        ('550e8400-e29b-41d4-a716-446655440004', 'Mike Telecaller', 'mike.telecaller@tigger.com', '+919876543213', 'telecaller', 'Telecaller', true);
        RAISE NOTICE 'Inserted sample users';
    END IF;
END $$;

-- Insert sample developer
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM developers WHERE name = 'ABC Developers Pvt Ltd') THEN
        INSERT INTO developers (id, name, address, state, district, city, pincode, company_type, is_rera_registered, rera_number, gstin, pan, is_active, created_by, created_by_name) VALUES
        ('650e8400-e29b-41d4-a716-446655440001', 'ABC Developers Pvt Ltd', '123 Business Park, Sector 5', 'Maharashtra', 'Mumbai', 'Mumbai', '400001', 'pvtLtd', true, 'RERA/MAH/123/2023', '27ABCDE1234F1Z5', 'ABCDE1234F', true, '550e8400-e29b-41d4-a716-446655440001', 'Admin User');
        RAISE NOTICE 'Inserted sample developer';
    END IF;
END $$;

-- Insert sample project
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM projects WHERE name = 'Green Valley Apartments') THEN
        INSERT INTO projects (id, name, description, developer_id, developer_name, type, status, address, city, state, pincode, total_area, total_units, available_units, starting_price, max_price, price_unit, amenities, property_types, rera_number, launch_date, possession_date, is_active, created_by, created_by_name) VALUES
        ('750e8400-e29b-41d4-a716-446655440001', 'Green Valley Apartments', 'Premium residential project with modern amenities', '650e8400-e29b-41d4-a716-446655440001', 'ABC Developers Pvt Ltd', 'residential', 'underConstruction', '456 Green Valley, Sector 10', 'Mumbai', 'Maharashtra', '400002', 50000.00, 200, 150, 5000000.00, 15000000.00, 'per_unit', ARRAY['Swimming Pool', 'Gym', 'Park', 'Security'], ARRAY['1BHK', '2BHK', '3BHK'], 'RERA/MAH/123/2023', '2023-01-01', '2025-12-31', true, '550e8400-e29b-41d4-a716-446655440001', 'Admin User');
        RAISE NOTICE 'Inserted sample project';
    END IF;
END $$;

-- =============================================
-- SAMPLE NOTIFICATIONS
-- =============================================

-- Insert sample notifications for testing
DO $$
BEGIN
    -- Check if notifications already exist
    IF NOT EXISTS (SELECT 1 FROM notifications WHERE title = 'Welcome to TiggerOn CRM') THEN
        INSERT INTO notifications (id, title, message, type, priority, status, user_id, related_id, related_type, action_url, data, created_at, is_read, is_archived) VALUES
        ('850e8400-e29b-41d4-a716-446655440001', 'Welcome to TiggerOn CRM', 'Welcome to the TiggerOn Real Estate Management System! Start by exploring the dashboard and creating your first lead.', 'system', 'medium', 'unread', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, '/dashboard', '{"welcome": true}', NOW() - INTERVAL '2 hours', false, false),
        ('850e8400-e29b-41d4-a716-446655440002', 'New Lead Assignment', 'You have been assigned a new lead: Green Valley Apartments Inquiry', 'lead', 'high', 'unread', '550e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', 'lead', '/leads/650e8400-e29b-41d4-a716-446655440001', '{"lead_id": "650e8400-e29b-41d4-a716-446655440001", "lead_title": "Green Valley Apartments Inquiry"}', NOW() - INTERVAL '1 hour', false, false),
        ('850e8400-e29b-41d4-a716-446655440003', 'Site Visit Scheduled', 'Site visit scheduled for Green Valley Apartments with customer John Doe', 'siteVisit', 'high', 'unread', '550e8400-e29b-41d4-a716-446655440001', '750e8400-e29b-41d4-a716-446655440001', 'site_visit', '/site-visits/750e8400-e29b-41d4-a716-446655440001', '{"site_visit_id": "750e8400-e29b-41d4-a716-446655440001", "customer_name": "John Doe", "project_name": "Green Valley Apartments"}', NOW() - INTERVAL '30 minutes', false, false),
        ('850e8400-e29b-41d4-a716-446655440004', 'Booking Confirmed', 'Booking confirmed for Green Valley Apartments - Unit 101', 'booking', 'urgent', 'read', '550e8400-e29b-41d4-a716-446655440001', '850e8400-e29b-41d4-a716-446655440004', 'booking', '/bookings/850e8400-e29b-41d4-a716-446655440004', '{"booking_id": "850e8400-e29b-41d4-a716-446655440004", "unit": "101", "project_name": "Green Valley Apartments"}', NOW() - INTERVAL '15 minutes', true, false),
        ('850e8400-e29b-41d4-a716-446655440005', 'System Maintenance', 'Scheduled system maintenance will occur tonight from 11 PM to 1 AM', 'system', 'low', 'unread', '550e8400-e29b-41d4-a716-446655440001', NULL, NULL, '/maintenance', '{"maintenance_window": "11 PM - 1 AM"}', NOW() - INTERVAL '5 minutes', false, false);
        
        RAISE NOTICE 'Inserted sample notifications';
    END IF;
END $$;

-- =============================================
-- COMMIT TRANSACTION
-- =============================================

COMMIT;

-- =============================================
-- VERIFICATION
-- =============================================

-- Display summary
DO $$
DECLARE
    table_count INTEGER;
    view_count INTEGER;
    function_count INTEGER;
    trigger_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count FROM information_schema.tables WHERE table_schema = 'public';
    SELECT COUNT(*) INTO view_count FROM information_schema.views WHERE table_schema = 'public';
    SELECT COUNT(*) INTO function_count FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';
    SELECT COUNT(*) INTO trigger_count FROM information_schema.triggers WHERE trigger_schema = 'public';
    
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'MIGRATION COMPLETED SUCCESSFULLY!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Tables created: %', table_count;
    RAISE NOTICE 'Views created: %', view_count;
    RAISE NOTICE 'Functions created: %', function_count;
    RAISE NOTICE 'Triggers created: %', trigger_count;
    RAISE NOTICE '=============================================';
END $$;
