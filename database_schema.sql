-- Tigger Real Estate Management System - Database Schema
-- PostgreSQL 12+ Compatible
-- Created: 2024

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- ENUMS
-- =============================================

-- Lead related enums
CREATE TYPE lead_status AS ENUM ('hot', 'warm', 'cold');
CREATE TYPE lead_sub_status AS ENUM ('newLead', 'inProgress', 'closed');
CREATE TYPE lead_source AS ENUM ('portal', 'walkIn', 'referral', 'website', 'socialMedia', 'other');
CREATE TYPE property_type AS ENUM ('residential', 'commercial', 'industrial', 'land');
CREATE TYPE category_type AS ENUM ('a', 'b', 'c');

-- Project related enums
CREATE TYPE project_status AS ENUM ('planning', 'underConstruction', 'completed', 'onHold', 'cancelled');
CREATE TYPE project_type AS ENUM ('residential', 'commercial', 'industrial', 'mixed');

-- Booking related enums
CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');
CREATE TYPE payment_mode AS ENUM ('cash', 'cheque', 'online', 'bankTransfer', 'upi', 'other');

-- Site visit related enums
CREATE TYPE site_visit_status AS ENUM ('scheduled', 'completed', 'cancelled', 'rescheduled');
CREATE TYPE visit_mode AS ENUM ('physical', 'video', 'phone', 'office');
CREATE TYPE visit_type AS ENUM ('propertyInspection', 'siteSurvey', 'clientMeeting', 'followUp');

-- Task related enums
CREATE TYPE task_status AS ENUM ('pending', 'inProgress', 'completed', 'cancelled', 'onHold');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE task_type AS ENUM ('followUp', 'siteVisit', 'call', 'meeting', 'documentation', 'review', 'other');

-- Ticket related enums
CREATE TYPE ticket_status AS ENUM ('open', 'inProgress', 'pending', 'resolved', 'closed', 'cancelled');
CREATE TYPE ticket_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE ticket_type AS ENUM ('issue', 'request', 'complaint', 'inquiry');
CREATE TYPE service_type AS ENUM ('maintenance', 'repair', 'cleaning', 'plumbing', 'electrical', 'hvac', 'security', 'other');

-- Notification related enums
CREATE TYPE notification_type AS ENUM ('lead', 'booking', 'siteVisit', 'ticket', 'system', 'reminder', 'alert');
CREATE TYPE notification_priority AS ENUM ('low', 'medium', 'high', 'urgent');
CREATE TYPE notification_status AS ENUM ('unread', 'read', 'archived');

-- Developer related enums
CREATE TYPE company_type AS ENUM ('pvtLtd', 'llp', 'partnership', 'proprietorship');

-- Bank related enums
CREATE TYPE bank_account_type AS ENUM ('savings', 'current', 'fixedDeposit', 'recurringDeposit');
CREATE TYPE bank_category AS ENUM ('savings', 'current', 'fixedDeposit', 'recurringDeposit');

-- =============================================
-- CORE TABLES
-- =============================================

-- Users table (extends Supabase auth.users)
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

-- Developer contacts table
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

-- Developers table
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

-- Projects table
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

-- Customers table
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

-- Leads table
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lead_id VARCHAR(50) UNIQUE NOT NULL, -- Display ID like LD-1001
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

-- Site visits table
CREATE TABLE site_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sr_no VARCHAR(50) UNIQUE NOT NULL, -- Serial number like SV-1001
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

-- Bookings table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sr_no VARCHAR(50) UNIQUE NOT NULL, -- Serial number like BK001
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

-- Tasks table
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

-- Tickets table
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

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL,
    priority notification_priority NOT NULL,
    status notification_status NOT NULL,
    user_id UUID REFERENCES users(id),
    related_id UUID, -- ID of related entity (lead, booking, etc.)
    related_type VARCHAR(50), -- Type of related entity
    action_url TEXT, -- Deep link or action URL
    data JSONB, -- Additional data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE,
    archived_at TIMESTAMP WITH TIME ZONE,
    is_read BOOLEAN DEFAULT false,
    is_archived BOOLEAN DEFAULT false
);

-- Bank details table
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

-- =============================================
-- INDEXES
-- =============================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Developers indexes
CREATE INDEX idx_developers_name ON developers(name);
CREATE INDEX idx_developers_city ON developers(city);
CREATE INDEX idx_developers_state ON developers(state);
CREATE INDEX idx_developers_is_active ON developers(is_active);
CREATE INDEX idx_developers_created_at ON developers(created_at);

-- Developer contacts indexes
CREATE INDEX idx_developer_contacts_developer_id ON developer_contacts(developer_id);
CREATE INDEX idx_developer_contacts_email ON developer_contacts(email);
CREATE INDEX idx_developer_contacts_mobile ON developer_contacts(mobile);
CREATE INDEX idx_developer_contacts_is_primary ON developer_contacts(is_primary);

-- Projects indexes
CREATE INDEX idx_projects_developer_id ON projects(developer_id);
CREATE INDEX idx_projects_name ON projects(name);
CREATE INDEX idx_projects_city ON projects(city);
CREATE INDEX idx_projects_state ON projects(state);
CREATE INDEX idx_projects_type ON projects(type);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_is_active ON projects(is_active);
CREATE INDEX idx_projects_created_at ON projects(created_at);

-- Customers indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_assigned_to ON customers(assigned_to);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_customers_state ON customers(state);
CREATE INDEX idx_customers_is_active ON customers(is_active);
CREATE INDEX idx_customers_created_at ON customers(created_at);

-- Leads indexes
CREATE INDEX idx_leads_lead_id ON leads(lead_id);
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_phone ON leads(phone);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_sub_status ON leads(sub_status);
CREATE INDEX idx_leads_source ON leads(source);
CREATE INDEX idx_leads_assigned_to ON leads(assigned_to);
CREATE INDEX idx_leads_project_id ON leads(project_id);
CREATE INDEX idx_leads_created_at ON leads(created_at);
CREATE INDEX idx_leads_next_follow_up_date ON leads(next_follow_up_date);

-- Site visits indexes
CREATE INDEX idx_site_visits_sr_no ON site_visits(sr_no);
CREATE INDEX idx_site_visits_lead_id ON site_visits(lead_id);
CREATE INDEX idx_site_visits_customer_id ON site_visits(customer_id);
CREATE INDEX idx_site_visits_project_id ON site_visits(project_id);
CREATE INDEX idx_site_visits_status ON site_visits(status);
CREATE INDEX idx_site_visits_telecaller_id ON site_visits(telecaller_id);
CREATE INDEX idx_site_visits_meeting_from ON site_visits(meeting_from);
CREATE INDEX idx_site_visits_created_at ON site_visits(created_at);

-- Bookings indexes
CREATE INDEX idx_bookings_sr_no ON bookings(sr_no);
CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX idx_bookings_lead_id ON bookings(lead_id);
CREATE INDEX idx_bookings_project_id ON bookings(project_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_sales_executive_id ON bookings(sales_executive_id);
CREATE INDEX idx_bookings_booking_date ON bookings(booking_date);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);

-- Tasks indexes
CREATE INDEX idx_tasks_title ON tasks(title);
CREATE INDEX idx_tasks_type ON tasks(type);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_lead_id ON tasks(lead_id);
CREATE INDEX idx_tasks_customer_id ON tasks(customer_id);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);

-- Tickets indexes
CREATE INDEX idx_tickets_ticket_number ON tickets(ticket_number);
CREATE INDEX idx_tickets_lead_id ON tickets(lead_id);
CREATE INDEX idx_tickets_customer_id ON tickets(customer_id);
CREATE INDEX idx_tickets_project_id ON tickets(project_id);
CREATE INDEX idx_tickets_ticket_type ON tickets(ticket_type);
CREATE INDEX idx_tickets_service_type ON tickets(service_type);
CREATE INDEX idx_tickets_priority ON tickets(priority);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_assigned_to ON tickets(assigned_to);
CREATE INDEX idx_tickets_contact_mobile ON tickets(contact_mobile);
CREATE INDEX idx_tickets_created_at ON tickets(created_at);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_priority ON notifications(priority);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_related_id ON notifications(related_id);
CREATE INDEX idx_notifications_related_type ON notifications(related_type);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Bank details indexes
CREATE INDEX idx_bank_details_bank_name ON bank_details(bank_name);
CREATE INDEX idx_bank_details_account_number ON bank_details(account_number);
CREATE INDEX idx_bank_details_ifsc_code ON bank_details(ifsc_code);
CREATE INDEX idx_bank_details_is_primary ON bank_details(is_primary);
CREATE INDEX idx_bank_details_is_active ON bank_details(is_active);

-- =============================================
-- TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_developers_updated_at BEFORE UPDATE ON developers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_developer_contacts_updated_at BEFORE UPDATE ON developer_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leads_updated_at BEFORE UPDATE ON leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_site_visits_updated_at BEFORE UPDATE ON site_visits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tickets_updated_at BEFORE UPDATE ON tickets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bank_details_updated_at BEFORE UPDATE ON bank_details FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate lead ID
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

-- Apply lead ID generation trigger
CREATE TRIGGER generate_lead_id_trigger
    BEFORE INSERT ON leads
    FOR EACH ROW
    WHEN (NEW.lead_id IS NULL OR NEW.lead_id = '')
    EXECUTE FUNCTION generate_lead_id();

-- Function to generate site visit serial number
CREATE OR REPLACE FUNCTION generate_site_visit_sr_no()
RETURNS TRIGGER AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(sr_no FROM 4) AS INTEGER)), 0) + 1
    INTO next_number
    FROM site_visits
    WHERE sr_no LIKE 'SV-%';
    
    NEW.sr_no := 'SV-' || LPAD(next_number::TEXT, 4, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply site visit serial number generation trigger
CREATE TRIGGER generate_site_visit_sr_no_trigger
    BEFORE INSERT ON site_visits
    FOR EACH ROW
    WHEN (NEW.sr_no IS NULL OR NEW.sr_no = '')
    EXECUTE FUNCTION generate_site_visit_sr_no();

-- Function to generate booking serial number
CREATE OR REPLACE FUNCTION generate_booking_sr_no()
RETURNS TRIGGER AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(sr_no FROM 3) AS INTEGER)), 0) + 1
    INTO next_number
    FROM bookings
    WHERE sr_no LIKE 'BK%';
    
    NEW.sr_no := 'BK' || LPAD(next_number::TEXT, 3, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply booking serial number generation trigger
CREATE TRIGGER generate_booking_sr_no_trigger
    BEFORE INSERT ON bookings
    FOR EACH ROW
    WHEN (NEW.sr_no IS NULL OR NEW.sr_no = '')
    EXECUTE FUNCTION generate_booking_sr_no();

-- Function to generate ticket number
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TRIGGER AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(ticket_number FROM 4) AS INTEGER)), 0) + 1
    INTO next_number
    FROM tickets
    WHERE ticket_number LIKE 'TK-%';
    
    NEW.ticket_number := 'TK-' || LPAD(next_number::TEXT, 4, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply ticket number generation trigger
CREATE TRIGGER generate_ticket_number_trigger
    BEFORE INSERT ON tickets
    FOR EACH ROW
    WHEN (NEW.ticket_number IS NULL OR NEW.ticket_number = '')
    EXECUTE FUNCTION generate_ticket_number();

-- =============================================
-- VIEWS
-- =============================================

-- Dashboard statistics view
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

-- Lead conversion funnel view
CREATE VIEW lead_conversion_funnel AS
SELECT 
    'Total Leads' as stage,
    COUNT(*) as count,
    100.0 as percentage
FROM leads
UNION ALL
SELECT 
    'Site Visits' as stage,
    COUNT(*) as count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM leads)) * 100, 2) as percentage
FROM leads l
WHERE l.has_site_visit = true
UNION ALL
SELECT 
    'Bookings' as stage,
    COUNT(*) as count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM leads)) * 100, 2) as percentage
FROM bookings b
JOIN leads l ON b.lead_id = l.id;

-- Sales performance view
CREATE VIEW sales_performance AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.role,
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT sv.id) as total_site_visits,
    COUNT(DISTINCT b.id) as total_bookings,
    COALESCE(SUM(b.booking_amount), 0) as total_booking_value,
    COALESCE(AVG(b.commission), 0) as avg_commission
FROM users u
LEFT JOIN leads l ON u.id = l.assigned_to
LEFT JOIN site_visits sv ON u.id = sv.telecaller_id
LEFT JOIN bookings b ON u.id = b.sales_executive_id
WHERE u.role IN ('sales_executive', 'manager', 'admin')
GROUP BY u.id, u.name, u.role;

-- Project performance view
CREATE VIEW project_performance AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    p.developer_name,
    p.city,
    p.state,
    COUNT(DISTINCT l.id) as total_leads,
    COUNT(DISTINCT sv.id) as total_site_visits,
    COUNT(DISTINCT b.id) as total_bookings,
    COALESCE(SUM(b.booking_amount), 0) as total_booking_value,
    p.total_units,
    p.available_units,
    CASE 
        WHEN p.total_units > 0 THEN ROUND(((p.total_units - COALESCE(p.available_units, p.total_units))::DECIMAL / p.total_units) * 100, 2)
        ELSE 0
    END as occupancy_percentage
FROM projects p
LEFT JOIN leads l ON p.id = l.project_id
LEFT JOIN site_visits sv ON p.id = sv.project_id
LEFT JOIN bookings b ON p.id = b.project_id
GROUP BY p.id, p.name, p.developer_name, p.city, p.state, p.total_units, p.available_units;

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Insert sample users
INSERT INTO users (id, name, email, phone, role, designation, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Admin User', 'admin@tigger.com', '+919876543210', 'admin', 'System Administrator', true),
('550e8400-e29b-41d4-a716-446655440002', 'John Manager', 'john.manager@tigger.com', '+919876543211', 'manager', 'Sales Manager', true),
('550e8400-e29b-41d4-a716-446655440003', 'Sarah Sales', 'sarah.sales@tigger.com', '+919876543212', 'sales_executive', 'Sales Executive', true),
('550e8400-e29b-41d4-a716-446655440004', 'Mike Telecaller', 'mike.telecaller@tigger.com', '+919876543213', 'telecaller', 'Telecaller', true);

-- Insert sample developer
INSERT INTO developers (id, name, address, state, district, city, pincode, company_type, is_rera_registered, rera_number, gstin, pan, is_active, created_by, created_by_name) VALUES
('650e8400-e29b-41d4-a716-446655440001', 'ABC Developers Pvt Ltd', '123 Business Park, Sector 5', 'Maharashtra', 'Mumbai', 'Mumbai', '400001', 'pvtLtd', true, 'RERA/MAH/123/2023', '27ABCDE1234F1Z5', 'ABCDE1234F', true, '550e8400-e29b-41d4-a716-446655440001', 'Admin User');

-- Insert sample developer contacts
INSERT INTO developer_contacts (developer_id, name, mobile, designation, email, is_primary) VALUES
('650e8400-e29b-41d4-a716-446655440001', 'Rajesh Kumar', '+919876543220', 'Managing Director', 'rajesh@abcdevelopers.com', true),
('650e8400-e29b-41d4-a716-446655440001', 'Priya Sharma', '+919876543221', 'Sales Head', 'priya@abcdevelopers.com', false);

-- Insert sample project
INSERT INTO projects (id, name, description, developer_id, developer_name, type, status, address, city, state, pincode, total_area, total_units, available_units, starting_price, max_price, price_unit, amenities, property_types, rera_number, launch_date, possession_date, is_active, created_by, created_by_name) VALUES
('750e8400-e29b-41d4-a716-446655440001', 'Green Valley Apartments', 'Premium residential project with modern amenities', '650e8400-e29b-41d4-a716-446655440001', 'ABC Developers Pvt Ltd', 'residential', 'underConstruction', '456 Green Valley, Sector 10', 'Mumbai', 'Maharashtra', '400002', 50000.00, 200, 150, 5000000.00, 15000000.00, 'per_unit', ARRAY['Swimming Pool', 'Gym', 'Park', 'Security'], ARRAY['1BHK', '2BHK', '3BHK'], 'RERA/MAH/123/2023', '2023-01-01', '2025-12-31', true, '550e8400-e29b-41d4-a716-446655440001', 'Admin User');

-- Insert sample customer
INSERT INTO customers (id, name, email, phone, address, city, state, pincode, assigned_to, assigned_to_name, created_by, created_by_name, project_type, project_id, project_name, is_active) VALUES
('850e8400-e29b-41d4-a716-446655440001', 'Amit Patel', 'amit.patel@email.com', '+919876543230', '789 Residential Area, Andheri', 'Mumbai', 'Maharashtra', '400058', '550e8400-e29b-41d4-a716-446655440003', 'Sarah Sales', '550e8400-e29b-41d4-a716-446655440001', 'Admin User', 'residential', '750e8400-e29b-41d4-a716-446655440001', 'Green Valley Apartments', true);

-- Insert sample lead
INSERT INTO leads (id, customer_name, email, phone, address, city, state, pincode, status, sub_status, source, property_type, category_type, project_id, project_name, budget_range, requirements, assigned_to, assigned_to_name, created_by, created_by_name) VALUES
('950e8400-e29b-41d4-a716-446655440001', 'Amit Patel', 'amit.patel@email.com', '+919876543230', '789 Residential Area, Andheri', 'Mumbai', 'Maharashtra', '400058', 'hot', 'newLead', 'website', 'residential', 'b', '750e8400-e29b-41d4-a716-446655440001', 'Green Valley Apartments', '50L-1Cr', 'Looking for 2BHK apartment', '550e8400-e29b-41d4-a716-446655440003', 'Sarah Sales', '550e8400-e29b-41d4-a716-446655440001', 'Admin User');

-- =============================================
-- GRANTS
-- =============================================

-- Grant permissions to application user (adjust username as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tigger_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tigger_app;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO tigger_app;

-- =============================================
-- COMMENTS
-- =============================================

COMMENT ON DATABASE tigger_real_estate IS 'Tigger Real Estate Management System Database';
COMMENT ON TABLE users IS 'System users including admins, managers, sales executives, and telecallers';
COMMENT ON TABLE developers IS 'Real estate developers with compliance and contact information';
COMMENT ON TABLE projects IS 'Real estate projects with pricing, amenities, and specifications';
COMMENT ON TABLE customers IS 'Customer information and preferences';
COMMENT ON TABLE leads IS 'Lead tracking and management with follow-up scheduling';
COMMENT ON TABLE site_visits IS 'Site visit scheduling and completion tracking';
COMMENT ON TABLE bookings IS 'Property bookings and payment management';
COMMENT ON TABLE tasks IS 'Task management and follow-up tracking';
COMMENT ON TABLE tickets IS 'Support ticket management system';
COMMENT ON TABLE notifications IS 'System notifications and alerts';
COMMENT ON TABLE bank_details IS 'Bank account information for payments';

-- =============================================
-- END OF SCHEMA
-- =============================================
