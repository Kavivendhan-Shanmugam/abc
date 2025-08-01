-- ACE CSS Leave Portal Database Schema
-- Compatible with MySQL 8.0+
-- This schema creates all required tables with proper relationships and constraints

-- Create database (uncomment if needed)
-- CREATE DATABASE IF NOT EXISTS cyber_security_leave_portal;
-- USE cyber_security_leave_portal;

-- Drop existing tables in correct order (handles foreign key constraints)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS profile_change_requests;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS leave_requests;
DROP TABLE IF EXISTS od_requests;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- Users table - Base user authentication and information
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_photo VARCHAR(500),
    is_admin TINYINT(1) DEFAULT 0,
    is_tutor TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_is_admin (is_admin),
    INDEX idx_is_tutor (is_tutor)
);

-- Staff table - For tutors and administrators
CREATE TABLE staff (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    profile_photo VARCHAR(500),
    is_admin TINYINT(1) DEFAULT 0,
    is_tutor TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_staff_email (email),
    INDEX idx_staff_username (username),
    INDEX idx_staff_is_admin (is_admin),
    INDEX idx_staff_is_tutor (is_tutor)
);

-- Students table - Student information and academic details
CREATE TABLE students (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    register_number VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    mobile VARCHAR(20) NOT NULL,
    tutor_id VARCHAR(36),
    batch VARCHAR(4) NOT NULL DEFAULT '2024',
    semester TINYINT(1) NOT NULL DEFAULT 1,
    username VARCHAR(50) NOT NULL UNIQUE DEFAULT '',
    profile_photo TEXT,
    leave_taken INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tutor_id) REFERENCES staff(id) ON DELETE SET NULL,
    INDEX idx_student_email (email),
    INDEX idx_student_register (register_number),
    INDEX idx_student_username (username),
    INDEX idx_student_tutor (tutor_id),
    INDEX idx_student_batch (batch),
    INDEX idx_student_semester (semester)
);

-- User sessions table - For JWT session management
CREATE TABLE user_sessions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_session_user (user_id),
    INDEX idx_session_token (token_hash),
    INDEX idx_session_active (is_active),
    INDEX idx_session_expires (expires_at)
);

-- Leave requests table - Student leave applications
CREATE TABLE leave_requests (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    student_register_number VARCHAR(100) NOT NULL,
    tutor_id VARCHAR(36) NOT NULL,
    tutor_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL,
    subject VARCHAR(500) NOT NULL,
    description TEXT,
    status ENUM('Pending', 'Approved', 'Rejected', 'Forwarded', 'Cancelled', 'Cancellation Pending', 'Retried') DEFAULT 'Pending',
    cancel_reason TEXT,
    partial_cancel_start DATE,
    partial_cancel_end DATE,
    partial_cancel_days INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (tutor_id) REFERENCES staff(id) ON DELETE RESTRICT,
    INDEX idx_leave_student (student_id),
    INDEX idx_leave_tutor (tutor_id),
    INDEX idx_leave_status (status),
    INDEX idx_leave_dates (start_date, end_date),
    INDEX idx_leave_created (created_at)
);

-- OD (Official Duty) requests table - Student official duty applications
CREATE TABLE od_requests (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    student_register_number VARCHAR(100) NOT NULL,
    tutor_id VARCHAR(36) NOT NULL,
    tutor_name VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT NOT NULL,
    purpose VARCHAR(500) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('Pending', 'Approved', 'Rejected', 'Forwarded', 'Cancelled', 'Cancellation Pending', 'Retried') DEFAULT 'Pending',
    cancel_reason TEXT,
    certificate_url VARCHAR(500),
    certificate_status ENUM('Pending Upload', 'Pending Verification', 'Approved', 'Rejected', 'Overdue'),
    upload_deadline TIMESTAMP,
    last_notification_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (tutor_id) REFERENCES staff(id) ON DELETE RESTRICT,
    INDEX idx_od_student (student_id),
    INDEX idx_od_tutor (tutor_id),
    INDEX idx_od_status (status),
    INDEX idx_od_cert_status (certificate_status),
    INDEX idx_od_dates (start_date, end_date),
    INDEX idx_od_deadline (upload_deadline),
    INDEX idx_od_created (created_at)
);

-- Profile change requests table - For handling profile modification requests
CREATE TABLE profile_change_requests (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(36) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    student_register_number VARCHAR(50) NOT NULL,
    tutor_id VARCHAR(36) NOT NULL,
    tutor_name VARCHAR(255) NOT NULL,
    change_type ENUM('email', 'mobile', 'password') NOT NULL,
    current_value TEXT,
    requested_value TEXT NOT NULL,
    reason TEXT,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    admin_comments TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    reviewed_by VARCHAR(36),
    reviewer_name VARCHAR(255),
    
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (tutor_id) REFERENCES staff(id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_profile_change_student (student_id),
    INDEX idx_profile_change_tutor (tutor_id),
    INDEX idx_profile_change_type (change_type),
    INDEX idx_profile_change_status (status),
    INDEX idx_profile_change_requested (requested_at)
);

-- Insert default admin user (optional - can be created via application)
-- Uncomment the following lines to create a default admin user
/*
SET @admin_id = 'admin-default-001';
SET @admin_email = 'admin@college.portal';
SET @admin_password_hash = '$2a$10$CwTycUXWue0Thq9StjUM0uB4K.XAUoytKZNBJ6XQzNRXqOo4OC99G'; -- admin123

INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) 
VALUES (@admin_id, @admin_email, @admin_password_hash, 'System', 'Administrator', 1, 0);

INSERT INTO staff (id, name, email, username, is_admin, is_tutor) 
VALUES (@admin_id, 'System Administrator', @admin_email, 'admin', 1, 0);
*/

-- Create indexes for performance optimization
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_staff_created_at ON staff(created_at);
CREATE INDEX idx_students_created_at ON students(created_at);
CREATE INDEX idx_students_leave_taken ON students(leave_taken);

-- Add triggers for automatic cleanup (optional)
DELIMITER //

-- Trigger to cleanup expired sessions daily
CREATE EVENT IF NOT EXISTS cleanup_expired_sessions
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE user_sessions 
    SET is_active = 0 
    WHERE expires_at <= NOW() AND is_active = 1;
END //

-- Trigger to update certificate status based on deadline
CREATE EVENT IF NOT EXISTS update_overdue_certificates
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE od_requests 
    SET certificate_status = 'Overdue' 
    WHERE certificate_status = 'Pending Upload' 
    AND upload_deadline <= NOW() 
    AND upload_deadline IS NOT NULL;
END //

DELIMITER ;

-- Enable event scheduler (required for above events)
SET GLOBAL event_scheduler = ON;

-- Show success message
SELECT 'ACE CSS Leave Portal Database Schema Created Successfully!' as STATUS,
       'All tables, indexes, and constraints have been set up.' as MESSAGE,
       'You can now run your application.' as NEXT_STEP;
