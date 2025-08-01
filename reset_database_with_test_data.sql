-- Reset Database and Create Test Data
-- Run this script to completely reset the database with test users and data

USE `cyber_security_leave_portal`;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Clear all existing data
TRUNCATE TABLE `user_sessions`;
TRUNCATE TABLE `od_requests`;
TRUNCATE TABLE `leave_requests`;
TRUNCATE TABLE `students`;
TRUNCATE TABLE `staff`;
TRUNCATE TABLE `users`;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Insert Users (password is 'password123' for all users, hashed with bcrypt)
INSERT INTO `users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `is_admin`, `is_tutor`) VALUES
-- Admin User
('admin-001', 'admin@college.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Admin', 'User', 1, 1),

-- Staff/Tutors
('tutor-001', 'tutor1@college.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Dr. Sarah', 'Johnson', 0, 1),
('tutor-002', 'tutor2@college.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Prof. Michael', 'Brown', 0, 1),
('tutor-003', 'tutor3@college.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Dr. Emily', 'Davis', 0, 1),

-- Students
('student-001', 'john.doe@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'John', 'Doe', 0, 0),
('student-002', 'jane.smith@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Jane', 'Smith', 0, 0),
('student-003', 'bob.wilson@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Bob', 'Wilson', 0, 0),
('student-004', 'alice.johnson@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Alice', 'Johnson', 0, 0),
('student-005', 'charlie.brown@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Charlie', 'Brown', 0, 0),
('student-006', 'diana.prince@student.portal', '$2a$10$UwsYHYb6JC71lEoN2WMHt.raWi5NdYkU53GHtOmHkOFnCdxkVvzei', 'Diana', 'Prince', 0, 0);

-- Insert Staff members
INSERT INTO `staff` (`id`, `name`, `email`, `username`, `is_admin`, `is_tutor`) VALUES
('admin-001', 'Admin User', 'admin@college.portal', 'admin', 1, 1),
('tutor-001', 'Dr. Sarah Johnson', 'tutor1@college.portal', 'sarah.johnson', 0, 1),
('tutor-002', 'Prof. Michael Brown', 'tutor2@college.portal', 'michael.brown', 0, 1),
('tutor-003', 'Dr. Emily Davis', 'tutor3@college.portal', 'emily.davis', 0, 1);

-- Insert Students with different batches and semesters
INSERT INTO `students` (`id`, `name`, `register_number`, `email`, `mobile`, `tutor_id`, `batch`, `semester`, `leave_taken`, `username`, `profile_photo`) VALUES
('student-001', 'John Doe', 'CS2024001', 'john.doe@student.portal', '1234567890', 'tutor-001', '2024', 1, 0, 'john.doe', NULL),
('student-002', 'Jane Smith', 'CS2024002', 'jane.smith@student.portal', '2345678901', 'tutor-001', '2024', 1, 2, 'jane.smith', NULL),
('student-003', 'Bob Wilson', 'CS2023001', 'bob.wilson@student.portal', '3456789012', 'tutor-002', '2023', 3, 5, 'bob.wilson', NULL),
('student-004', 'Alice Johnson', 'CS2023002', 'alice.johnson@student.portal', '4567890123', 'tutor-002', '2023', 3, 1, 'alice.johnson', NULL),
('student-005', 'Charlie Brown', 'CS2022001', 'charlie.brown@student.portal', '5678901234', 'tutor-003', '2022', 5, 8, 'charlie.brown', NULL),
('student-006', 'Diana Prince', 'CS2022002', 'diana.prince@student.portal', '6789012345', 'tutor-003', '2022', 5, 3, 'diana.prince', NULL);

-- Insert sample Leave Requests with various statuses
INSERT INTO `leave_requests` (`id`, `student_id`, `student_name`, `student_register_number`, `tutor_id`, `tutor_name`, `start_date`, `end_date`, `total_days`, `subject`, `description`, `status`, `created_at`) VALUES
('leave-001', 'student-001', 'John Doe', 'CS2024001', 'tutor-001', 'Dr. Sarah Johnson', '2025-08-05', '2025-08-07', 3, 'Medical Leave', 'Doctor appointment and recovery', 'Pending', NOW()),
('leave-002', 'student-002', 'Jane Smith', 'CS2024002', 'tutor-001', 'Dr. Sarah Johnson', '2025-07-28', '2025-07-30', 3, 'Personal Leave', 'Family function', 'Approved', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('leave-003', 'student-003', 'Bob Wilson', 'CS2023001', 'tutor-002', 'Prof. Michael Brown', '2025-08-01', '2025-08-01', 1, 'Emergency Leave', 'Personal emergency', 'Rejected', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('leave-004', 'student-004', 'Alice Johnson', 'CS2023002', 'tutor-002', 'Prof. Michael Brown', '2025-08-10', '2025-08-12', 3, 'Academic Leave', 'Conference attendance', 'Forwarded', DATE_SUB(NOW(), INTERVAL 2 DAY)),
('leave-005', 'student-005', 'Charlie Brown', 'CS2022001', 'tutor-003', 'Dr. Emily Davis', '2025-07-25', '2025-07-29', 5, 'Medical Leave', 'Surgery and recovery', 'Approved', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('leave-006', 'student-006', 'Diana Prince', 'CS2022002', 'tutor-003', 'Dr. Emily Davis', '2025-08-15', '2025-08-17', 3, 'Personal Leave', 'Wedding ceremony', 'Cancellation Pending', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('leave-007', 'student-001', 'John Doe', 'CS2024001', 'tutor-001', 'Dr. Sarah Johnson', '2025-07-20', '2025-07-22', 3, 'Personal Leave', 'Family visit', 'Cancelled', DATE_SUB(NOW(), INTERVAL 10 DAY));

-- Insert sample OD Requests with various statuses and certificate statuses
INSERT INTO `od_requests` (`id`, `student_id`, `student_name`, `student_register_number`, `tutor_id`, `tutor_name`, `start_date`, `end_date`, `total_days`, `purpose`, `destination`, `description`, `status`, `certificate_status`, `upload_deadline`, `created_at`) VALUES
('od-001', 'student-001', 'John Doe', 'CS2024001', 'tutor-001', 'Dr. Sarah Johnson', '2025-08-08', '2025-08-08', 1, 'Technical Workshop', 'Tech Park Conference Hall', 'AI and Machine Learning Workshop', 'Pending', 'Pending Upload', '2025-08-15', NOW()),
('od-002', 'student-002', 'Jane Smith', 'CS2024002', 'tutor-001', 'Dr. Sarah Johnson', '2025-07-26', '2025-07-26', 1, 'Industry Visit', 'Software Company Ltd', 'Learning industry practices', 'Approved', 'Pending Upload', '2025-08-02', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('od-003', 'student-003', 'Bob Wilson', 'CS2023001', 'tutor-002', 'Prof. Michael Brown', '2025-07-22', '2025-07-23', 2, 'Research Conference', 'University Auditorium', 'Computer Science Research Symposium', 'Approved', 'Pending Verification', '2025-07-30', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('od-004', 'student-004', 'Alice Johnson', 'CS2023002', 'tutor-002', 'Prof. Michael Brown', '2025-07-15', '2025-07-16', 2, 'Hackathon', 'Innovation Center', '48-hour coding competition', 'Approved', 'Approved', '2025-07-23', DATE_SUB(NOW(), INTERVAL 17 DAY)),
('od-005', 'student-005', 'Charlie Brown', 'CS2022001', 'tutor-003', 'Dr. Emily Davis', '2025-08-20', '2025-08-21', 2, 'Internship Interview', 'Corporate Office', 'Summer internship selection', 'Rejected', 'Pending Upload', '2025-08-28', DATE_SUB(NOW(), INTERVAL 1 DAY)),
('od-006', 'student-006', 'Diana Prince', 'CS2022002', 'tutor-003', 'Dr. Emily Davis', '2025-07-10', '2025-07-10', 1, 'Certification Exam', 'Testing Center', 'Professional certification', 'Approved', 'Overdue', '2025-07-17', DATE_SUB(NOW(), INTERVAL 22 DAY));

-- Display summary of created data
SELECT 'USERS CREATED:' as Info;
SELECT COUNT(*) as total_users, 
       SUM(is_admin) as admins, 
       SUM(is_tutor AND NOT is_admin) as tutors, 
       SUM(NOT is_admin AND NOT is_tutor) as students 
FROM users;

SELECT 'STAFF CREATED:' as Info;
SELECT COUNT(*) as total_staff FROM staff;

SELECT 'STUDENTS CREATED:' as Info;
SELECT COUNT(*) as total_students, 
       COUNT(DISTINCT batch) as unique_batches,
       COUNT(DISTINCT tutor_id) as tutors_assigned
FROM students;

SELECT 'LEAVE REQUESTS CREATED:' as Info;
SELECT COUNT(*) as total_requests,
       SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending,
       SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) as approved,
       SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) as rejected,
       SUM(CASE WHEN status = 'Forwarded' THEN 1 ELSE 0 END) as forwarded,
       SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled,
       SUM(CASE WHEN status = 'Cancellation Pending' THEN 1 ELSE 0 END) as cancellation_pending
FROM leave_requests;

SELECT 'OD REQUESTS CREATED:' as Info;
SELECT COUNT(*) as total_requests,
       SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) as pending,
       SUM(CASE WHEN status = 'Approved' THEN 1 ELSE 0 END) as approved,
       SUM(CASE WHEN status = 'Rejected' THEN 1 ELSE 0 END) as rejected
FROM od_requests;

SELECT 'CERTIFICATE STATUS SUMMARY:' as Info;
SELECT certificate_status, COUNT(*) as count
FROM od_requests 
GROUP BY certificate_status;

-- Show test user credentials
SELECT '=== TEST USER CREDENTIALS ===' as Info;
SELECT 'All passwords are: password123' as Password_Info;
SELECT 'ADMIN USERS:' as User_Type;
SELECT CONCAT(u.first_name, ' ', u.last_name) as Name, u.email, 'admin' as username, 'Admin Dashboard' as Access_Level
FROM users u JOIN staff s ON u.id = s.id 
WHERE u.is_admin = 1;

SELECT 'TUTOR USERS:' as User_Type;
SELECT CONCAT(u.first_name, ' ', u.last_name) as Name, u.email, s.username, 'Tutor Dashboard' as Access_Level
FROM users u JOIN staff s ON u.id = s.id 
WHERE u.is_tutor = 1 AND u.is_admin = 0;

SELECT 'STUDENT USERS:' as User_Type;
SELECT CONCAT(u.first_name, ' ', u.last_name) as Name, u.email, st.username, CONCAT('Student Dashboard (Batch: ', st.batch, ', Semester: ', st.semester, ')') as Access_Level
FROM users u JOIN students st ON u.id = st.id;
