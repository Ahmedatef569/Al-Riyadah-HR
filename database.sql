-- Create users table for simple authentication
create table users (
    id uuid default uuid_generate_v4() primary key,
    username text unique not null,
    password text not null,
    role text check (role in ('admin', 'manager', 'employee')) not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create employees table
create table employees (
    id uuid default uuid_generate_v4() primary key,
    code text unique not null,
    first_name text not null,
    last_name text not null,
    department text not null,
    position text not null,
    hire_date date not null,
    status text check (status in ('Active', 'Inactive')) default 'Active',
    email text unique not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create leaves table
create table leaves (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    start_date date not null,
    end_date date not null,
    type text check (type in ('Annual', 'Sick', 'Unpaid', 'Other')) not null,
    status text check (status in ('Pending', 'Approved', 'Rejected')) default 'Pending',
    reason text,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create excuses table
create table excuses (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    date date not null,
    time_from time not null,
    time_to time not null,
    reason text not null,
    status text check (status in ('Pending', 'Approved', 'Rejected')) default 'Pending',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create overtime table
create table overtime (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    date date not null,
    hours numeric(4,2) not null,
    reason text not null,
    status text check (status in ('Pending', 'Approved', 'Rejected')) default 'Pending',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create penalties table
create table penalties (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    date date not null,
    type text not null,
    description text not null,
    amount numeric(10,2),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create salary table
create table salaries (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    base_salary numeric(10,2) not null,
    housing_allowance numeric(10,2) default 0,
    transport_allowance numeric(10,2) default 0,
    other_allowances numeric(10,2) default 0,
    effective_date date not null,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Create payroll table
create table payroll (
    id uuid default uuid_generate_v4() primary key,
    employee_id uuid references employees not null,
    period_start date not null,
    period_end date not null,
    base_salary numeric(10,2) not null,
    total_allowances numeric(10,2) not null,
    overtime_pay numeric(10,2) default 0,
    deductions numeric(10,2) default 0,
    net_salary numeric(10,2) not null,
    status text check (status in ('Draft', 'Approved', 'Paid')) default 'Draft',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaves ENABLE ROW LEVEL SECURITY;
ALTER TABLE excuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE overtime ENABLE ROW LEVEL SECURITY;
ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;
ALTER TABLE salaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY users_admin_all ON users 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

-- Create policies for employees table
CREATE POLICY employees_admin_all ON employees 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY employees_manager_read ON employees 
    FOR SELECT 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND department IN (
            SELECT department FROM employees WHERE id = auth.uid()
        )
    );

CREATE POLICY employees_self_read ON employees 
    FOR SELECT 
    TO authenticated 
    USING (id = auth.uid());

-- Create policies for leaves table
CREATE POLICY leaves_admin_all ON leaves 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY leaves_manager_dept ON leaves 
    FOR ALL 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY leaves_employee_self ON leaves 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

CREATE POLICY leaves_employee_insert ON leaves 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (employee_id = auth.uid());

-- Create policies for excuses table
CREATE POLICY excuses_admin_all ON excuses 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY excuses_manager_dept ON excuses 
    FOR ALL 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY excuses_employee_self ON excuses 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

CREATE POLICY excuses_employee_insert ON excuses 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (employee_id = auth.uid());

-- Create policies for overtime table
CREATE POLICY overtime_admin_all ON overtime 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY overtime_manager_dept ON overtime 
    FOR ALL 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY overtime_employee_self ON overtime 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

CREATE POLICY overtime_employee_insert ON overtime 
    FOR INSERT 
    TO authenticated 
    WITH CHECK (employee_id = auth.uid());

-- Create policies for penalties table
CREATE POLICY penalties_admin_all ON penalties 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY penalties_manager_dept ON penalties 
    FOR ALL 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY penalties_employee_self ON penalties 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

-- Create policies for salaries table
CREATE POLICY salaries_admin_all ON salaries 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY salaries_manager_read_dept ON salaries 
    FOR SELECT 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY salaries_employee_self ON salaries 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

-- Create policies for payroll table
CREATE POLICY payroll_admin_all ON payroll 
    FOR ALL 
    TO authenticated 
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY payroll_manager_read_dept ON payroll 
    FOR SELECT 
    TO authenticated 
    USING (
        auth.jwt() ->> 'role' = 'manager' 
        AND employee_id IN (
            SELECT id FROM employees 
            WHERE department IN (
                SELECT department FROM employees WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY payroll_employee_self ON payroll 
    FOR SELECT 
    TO authenticated 
    USING (employee_id = auth.uid());

-- Create function to initialize tables
create or replace function init_hr_tables()
returns void
language plpgsql
as $$
begin
    -- Create admin user if it doesn't exist
    INSERT INTO users (username, password, role)
    VALUES ('admin', 'admin123', 'admin')
    ON CONFLICT (username) DO NOTHING;
    return;
end;
$$;
