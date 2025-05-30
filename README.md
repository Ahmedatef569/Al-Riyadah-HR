# Al-Riyadah HR System

A comprehensive HR management system built with HTML, JavaScript, and Supabase.

## Setup

1. Clone the repository
2. Copy `.env.example` to `.env` and fill in your Supabase credentials
3. Run `npm install` to install dependencies
4. Initialize your Supabase database using the schema in `database.sql`
5. Open `index.html` in a web browser or serve it using a local server

## Features

- Employee Management
- Leave Management
- Overtime Tracking
- Excuse Management
- Payroll Management
- Role-based Access Control (Admin, Manager, Employee)

## Security

- Row Level Security (RLS) implemented for all tables
- Role-based access control
- Secure authentication

## Environment Variables

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

## Database Setup

Run the SQL commands in `database.sql` to:
1. Create necessary tables
2. Enable Row Level Security
3. Create access policies
4. Initialize admin account

## Default Admin Account

Username: admin
Password: admin123

**Important**: Change the admin password after first login!
