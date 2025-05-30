// Database schema setup for Supabase
import { supabase } from './supabase.js';

// Create Users Table
async function createUsersTable() {
    const { data, error } = await supabase
        .rpc('create_users_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS users (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    username TEXT UNIQUE NOT NULL,
                    password TEXT NOT NULL,
                    role TEXT NOT NULL CHECK (role IN ('admin', 'manager', 'employee')),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating users table:', error);
    else console.log('Users table created successfully');
}

// Create Employees Table
async function createEmployeesTable() {
    const { data, error } = await supabase
        .rpc('create_employees_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS employees (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    employee_code TEXT UNIQUE NOT NULL,
                    first_name TEXT NOT NULL,
                    last_name TEXT NOT NULL,
                    email TEXT UNIQUE NOT NULL,
                    department TEXT NOT NULL,
                    position TEXT NOT NULL,
                    hire_date DATE NOT NULL,
                    status TEXT DEFAULT 'Active',
                    annual_leave_balance INTEGER DEFAULT 21,
                    manager_id UUID REFERENCES employees(id),
                    user_id UUID REFERENCES users(id),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating employees table:', error);
    else console.log('Employees table created successfully');
}

// Create Leaves Table
async function createLeavesTable() {
    const { data, error } = await supabase
        .rpc('create_leaves_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS leaves (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    employee_id UUID REFERENCES employees(id),
                    start_date DATE NOT NULL,
                    end_date DATE NOT NULL,
                    days DECIMAL(4,1) NOT NULL,
                    type TEXT NOT NULL,
                    reason TEXT,
                    status TEXT DEFAULT 'Pending',
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating leaves table:', error);
    else console.log('Leaves table created successfully');
}

// Create Excuses Table
async function createExcusesTable() {
    const { data, error } = await supabase
        .rpc('create_excuses_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS excuses (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    employee_id UUID REFERENCES employees(id),
                    date DATE NOT NULL,
                    time_from TIME NOT NULL,
                    time_to TIME NOT NULL,
                    reason TEXT NOT NULL,
                    status TEXT DEFAULT 'Pending',
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating excuses table:', error);
    else console.log('Excuses table created successfully');
}

// Create Overtime Table
async function createOvertimeTable() {
    const { data, error } = await supabase
        .rpc('create_overtime_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS overtime (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    employee_id UUID REFERENCES employees(id),
                    date DATE NOT NULL,
                    hours DECIMAL(4,1) NOT NULL,
                    reason TEXT NOT NULL,
                    status TEXT DEFAULT 'Pending',
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating overtime table:', error);
    else console.log('Overtime table created successfully');
}

// Create Salary Table
async function createSalaryTable() {
    const { data, error } = await supabase
        .rpc('create_salary_table', {
            sql: `
                CREATE TABLE IF NOT EXISTS salary (
                    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
                    employee_id UUID REFERENCES employees(id),
                    basic_salary DECIMAL(10,2) NOT NULL,
                    housing_allowance DECIMAL(10,2) DEFAULT 0,
                    transportation_allowance DECIMAL(10,2) DEFAULT 0,
                    other_allowances DECIMAL(10,2) DEFAULT 0,
                    effective_date DATE NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
                );
            `
        });
    if (error) console.error('Error creating salary table:', error);
    else console.log('Salary table created successfully');
}

// Initialize all tables
async function initializeTables() {
    await createUsersTable();
    await createEmployeesTable();
    await createLeavesTable();
    await createExcusesTable();
    await createOvertimeTable();
    await createSalaryTable();
    
    // Initialize admin account
    const { error } = await supabase.rpc('init_hr_tables');
    if (error) console.error('Error initializing admin account:', error);
    else console.log('Admin account initialized successfully');
}

// Export the initialization function
export { initializeTables };
