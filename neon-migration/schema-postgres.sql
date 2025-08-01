-- PostgreSQL Schema for Neon Database
-- Converted from MySQL schema for cyber_security_leave_portal

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table for authentication
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  profile_photo TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  is_tutor BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create function for updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger for users table
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Staff table
CREATE TABLE IF NOT EXISTS staff (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  is_tutor BOOLEAN NOT NULL DEFAULT FALSE,
  profile_photo TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id) REFERENCES users (id) ON DELETE CASCADE
);

-- Add trigger for staff table
CREATE TRIGGER update_staff_updated_at 
    BEFORE UPDATE ON staff 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Students table
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  register_number VARCHAR(50) NOT NULL UNIQUE,
  tutor_id UUID,
  batch VARCHAR(4) NOT NULL,
  semester SMALLINT NOT NULL DEFAULT 1,
  leave_taken INTEGER NOT NULL DEFAULT 0,
  username VARCHAR(50) NOT NULL UNIQUE,
  profile_photo TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE SET NULL
);

-- Add index for students batch/semester
CREATE INDEX IF NOT EXISTS idx_students_batch_semester ON students (batch, semester);

-- Add trigger for students table
CREATE TRIGGER update_students_updated_at 
    BEFORE UPDATE ON students 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Leave requests table
CREATE TYPE leave_status AS ENUM ('Pending', 'Approved', 'Rejected', 'Forwarded', 'Cancelled', 'Cancellation Pending', 'Retried');

CREATE TABLE IF NOT EXISTS leave_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL,
  student_name VARCHAR(255) NOT NULL,
  student_register_number VARCHAR(50) NOT NULL,
  tutor_id UUID NOT NULL,
  tutor_name VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_days INTEGER NOT NULL,
  partial_cancel_start DATE DEFAULT NULL,
  partial_cancel_end DATE DEFAULT NULL,
  partial_cancel_days INTEGER DEFAULT NULL,
  subject VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status leave_status NOT NULL DEFAULT 'Pending',
  cancel_reason TEXT,
  original_status leave_status,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE CASCADE
);

-- Add index for partial cancellation fields
CREATE INDEX IF NOT EXISTS idx_leave_partial_cancellation ON leave_requests (status, partial_cancel_start, partial_cancel_end);

-- Add trigger for leave_requests table
CREATE TRIGGER update_leave_requests_updated_at 
    BEFORE UPDATE ON leave_requests 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- OD requests table
CREATE TYPE certificate_status AS ENUM ('Pending Upload', 'Pending Verification', 'Approved', 'Rejected', 'Overdue');

CREATE TABLE IF NOT EXISTS od_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID NOT NULL,
  student_name VARCHAR(255) NOT NULL,
  student_register_number VARCHAR(50) NOT NULL,
  tutor_id UUID NOT NULL,
  tutor_name VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_days INTEGER NOT NULL,
  purpose VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  status leave_status NOT NULL DEFAULT 'Pending',
  cancel_reason TEXT,
  certificate_url TEXT,
  certificate_status certificate_status,
  upload_deadline DATE,
  last_notification_date DATE DEFAULT NULL,
  original_status leave_status,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE CASCADE
);

-- Add index for OD certificate reminders performance
CREATE INDEX IF NOT EXISTS idx_od_certificate_reminders 
ON od_requests (status, certificate_status, end_date, last_notification_date);

-- Add trigger for od_requests table
CREATE TRIGGER update_od_requests_updated_at 
    BEFORE UPDATE ON od_requests 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Sessions table for single session management
CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- Create indexes for user_sessions
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token_hash ON user_sessions (token_hash);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions (expires_at);

-- Add trigger for user_sessions table
CREATE TRIGGER update_user_sessions_updated_at 
    BEFORE UPDATE ON user_sessions 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (using fixed UUID for consistency)
INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) 
VALUES ('550e8400-e29b-41d4-a716-446655440000'::UUID, 'admin@college.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Admin', 'User', TRUE, TRUE)
ON CONFLICT (email) DO NOTHING;

INSERT INTO staff (id, name, email, username, is_admin, is_tutor) 
VALUES ('550e8400-e29b-41d4-a716-446655440000'::UUID, 'Admin User', 'admin@college.portal', 'admin', TRUE, TRUE)
ON CONFLICT (username) DO NOTHING;
