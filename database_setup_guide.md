# Tigger Real Estate Management System - Database Setup Guide

## Overview

This guide explains how to set up the database for the Tigger Real Estate Management System. The database is designed to support a comprehensive real estate management application with lead management, customer tracking, booking management, site visits, and more.

## Prerequisites

- PostgreSQL 12 or higher
- Database user with CREATE privileges
- Access to the target database

## Files Included

1. **`database_schema.sql`** - Complete database schema with all tables, indexes, triggers, and views
2. **`database_migration.sql`** - Step-by-step migration script with error handling
3. **`database_documentation.md`** - Comprehensive database documentation
4. **`database_setup_guide.md`** - This setup guide

## Quick Setup

### Option 1: Complete Schema (Recommended for New Databases)

```bash
# Connect to PostgreSQL
psql -U your_username -d your_database_name

# Run the complete schema
\i database_schema.sql
```

### Option 2: Step-by-Step Migration (Recommended for Existing Databases)

```bash
# Connect to PostgreSQL
psql -U your_username -d your_database_name

# Run the migration script
\i database_migration.sql
```

## Detailed Setup Instructions

### Step 1: Create Database

```sql
-- Create database (if not exists)
CREATE DATABASE tigger_real_estate;

-- Connect to the database
\c tigger_real_estate;
```

### Step 2: Create Database User (Optional)

```sql
-- Create a dedicated user for the application
CREATE USER tigger_app WITH PASSWORD 'your_secure_password';

-- Grant necessary privileges
GRANT CONNECT ON DATABASE tigger_real_estate TO tigger_app;
GRANT USAGE ON SCHEMA public TO tigger_app;
GRANT CREATE ON SCHEMA public TO tigger_app;
```

### Step 3: Run Database Schema

```bash
# Using psql command line
psql -U your_username -d tigger_real_estate -f database_schema.sql

# Or using the migration script
psql -U your_username -d tigger_real_estate -f database_migration.sql
```

### Step 4: Verify Installation

```sql
-- Check if all tables were created
\dt

-- Check if all views were created
\dv

-- Check if all triggers were created
SELECT trigger_name, event_object_table 
FROM information_schema.triggers 
WHERE trigger_schema = 'public';

-- Check if all indexes were created
SELECT indexname, tablename 
FROM pg_indexes 
WHERE schemaname = 'public';
```

## Database Structure

### Core Tables

1. **users** - System users (admins, managers, sales executives, telecallers)
2. **developers** - Real estate developers with compliance details
3. **developer_contacts** - Contact persons for developers
4. **projects** - Real estate projects with pricing and amenities
5. **customers** - Customer information and preferences
6. **leads** - Lead tracking and management
7. **site_visits** - Site visit scheduling and completion
8. **bookings** - Property bookings and payments
9. **tickets** - Support ticket management
10. **tasks** - Task management and follow-ups
11. **notifications** - System notifications
12. **bank_details** - Bank account information

### Key Features

- **UUID Primary Keys**: All tables use UUIDs for primary keys
- **Comprehensive Indexing**: Optimized for common query patterns
- **Data Integrity**: Foreign key constraints and check constraints
- **Audit Trail**: Created/updated timestamps and user tracking
- **Flexibility**: JSONB fields for custom data and metadata
- **Performance Views**: Pre-built views for common statistics

## Sample Data

The database includes sample data for:

- **Users**: Admin, manager, sales executive, and telecaller accounts
- **Developer**: ABC Developers with compliance details
- **Project**: Green Valley Apartments with pricing information

## Configuration

### Environment Variables

Set these environment variables in your application:

```bash
# Database connection
DATABASE_URL=postgresql://username:password@localhost:5432/tigger_real_estate

# Or individual components
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tigger_real_estate
DB_USER=your_username
DB_PASSWORD=your_password
```

### Connection Pool Settings

Recommended connection pool settings:

```yaml
# For production
max_connections: 20
min_connections: 5
connection_timeout: 30
idle_timeout: 600

# For development
max_connections: 10
min_connections: 2
connection_timeout: 30
idle_timeout: 300
```

## Performance Optimization

### Indexing Strategy

The database includes comprehensive indexing for:

- Primary keys (automatic)
- Foreign keys (for join performance)
- Status fields (for filtering)
- Date fields (for time-based queries)
- Email/phone fields (for lookups)
- Name fields (for search functionality)

### Query Optimization

- Use the provided views for common aggregations
- Leverage indexes for filtering and sorting
- Use JSONB operators for custom field queries
- Consider partitioning for large tables in production

## Security Considerations

### Access Control

```sql
-- Grant application user permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tigger_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tigger_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO tigger_app;

-- Revoke unnecessary permissions
REVOKE CREATE ON SCHEMA public FROM tigger_app;
```

### Data Protection

- Use SSL connections in production
- Encrypt sensitive data at application level
- Implement proper backup and recovery procedures
- Regular security updates

## Backup and Recovery

### Backup

```bash
# Full database backup
pg_dump -U your_username -d tigger_real_estate > backup.sql

# Compressed backup
pg_dump -U your_username -d tigger_real_estate | gzip > backup.sql.gz

# Schema only
pg_dump -U your_username -d tigger_real_estate --schema-only > schema_backup.sql
```

### Recovery

```bash
# Restore from backup
psql -U your_username -d tigger_real_estate < backup.sql

# Restore from compressed backup
gunzip -c backup.sql.gz | psql -U your_username -d tigger_real_estate
```

## Monitoring and Maintenance

### Performance Monitoring

```sql
-- Check table sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

### Regular Maintenance

```sql
-- Update table statistics
ANALYZE;

-- Reindex if needed
REINDEX DATABASE tigger_real_estate;

-- Vacuum to reclaim space
VACUUM ANALYZE;
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure user has CREATE privileges
   - Check database ownership
   - Verify schema permissions

2. **Extension Not Found**
   - Install uuid-ossp extension
   - Check PostgreSQL version compatibility

3. **Constraint Violations**
   - Check foreign key references
   - Verify data types match constraints
   - Review check constraint values

4. **Performance Issues**
   - Check index usage
   - Analyze query execution plans
   - Consider additional indexes

### Debug Commands

```sql
-- Check database size
SELECT pg_size_pretty(pg_database_size('tigger_real_estate'));

-- Check active connections
SELECT count(*) FROM pg_stat_activity WHERE datname = 'tigger_real_estate';

-- Check table statistics
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del 
FROM pg_stat_user_tables 
WHERE schemaname = 'public';
```

## Support

For issues or questions:

1. Check the database documentation
2. Review PostgreSQL logs
3. Verify schema integrity
4. Check application logs

## Version History

- **v1.0** - Initial database schema
- **v1.1** - Added comprehensive indexing
- **v1.2** - Added performance views
- **v1.3** - Added sample data and migration script

## License

This database schema is part of the Tigger Real Estate Management System and follows the same licensing terms.
