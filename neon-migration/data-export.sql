-- PostgreSQL Data Import
-- Generated from MySQL export

-- Insert users
INSERT INTO users (id, email, password_hash, first_name, last_name, profile_photo, is_admin, is_tutor, created_at, updated_at) VALUES ('52ca326b-e6e2-4f8e-9412-04ce6a2bac99', 'test@gmail.com', '$2a$10$dBwrNrm.1N05yxfUyGtJtOTNcfxew4S2rpxkBBRa7VpyIRMuR/Kku', 'test', '', NULL, FALSE, FALSE, '2025-08-01T09:35:01.000Z', '2025-08-01T09:35:01.000Z') ON CONFLICT (email) DO UPDATE SET updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, email, password_hash, first_name, last_name, profile_photo, is_admin, is_tutor, created_at, updated_at) VALUES ('922af2c0-458b-465b-92c7-d0d7985d77c3', 'tester@gmail.com', '$2a$10$ApolAhtIHUpCIxduUwzxiOacIkoffARwz98uMZqaA9R2k2KuCQS5O', 'tester', '', NULL, FALSE, TRUE, '2025-08-01T09:34:03.000Z', '2025-08-01T09:34:03.000Z') ON CONFLICT (email) DO UPDATE SET updated_at = EXCLUDED.updated_at;
INSERT INTO users (id, email, password_hash, first_name, last_name, profile_photo, is_admin, is_tutor, created_at, updated_at) VALUES ('admin-clean-001', 'admin@test.com', '$2a$10$1NGHttL3ALa23.iTBm/0/e62Njc0W6bsjrAgStuI3QfplD8g.hT7C', 'Admin', 'User', NULL, TRUE, FALSE, '2025-08-01T09:29:25.000Z', '2025-08-01T09:29:25.000Z') ON CONFLICT (email) DO UPDATE SET updated_at = EXCLUDED.updated_at;

-- Insert staff
INSERT INTO staff (id, name, email, username, is_admin, is_tutor, profile_photo, created_at, updated_at) VALUES ('922af2c0-458b-465b-92c7-d0d7985d77c3', 'tester', 'tester@gmail.com', 'tester', FALSE, TRUE, NULL, '2025-08-01T09:34:03.000Z', '2025-08-01T09:34:03.000Z') ON CONFLICT (username) DO UPDATE SET updated_at = EXCLUDED.updated_at;
INSERT INTO staff (id, name, email, username, is_admin, is_tutor, profile_photo, created_at, updated_at) VALUES ('admin-clean-001', 'Admin User', 'admin@test.com', 'admin', TRUE, FALSE, NULL, '2025-08-01T09:29:25.000Z', '2025-08-01T09:29:25.000Z') ON CONFLICT (username) DO UPDATE SET updated_at = EXCLUDED.updated_at;

-- Insert students
INSERT INTO students (id, name, register_number, tutor_id, batch, semester, leave_taken, username, profile_photo, created_at, updated_at) VALUES ('52ca326b-e6e2-4f8e-9412-04ce6a2bac99', 'test', '000012', '922af2c0-458b-465b-92c7-d0d7985d77c3', '2024', 3, 0, 'test', NULL, '2025-08-01T09:35:01.000Z', '2025-08-01T09:35:01.000Z') ON CONFLICT (register_number) DO UPDATE SET updated_at = EXCLUDED.updated_at;

-- Insert user_sessions
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('046844d3-3ca9-4e2c-bc52-20b0dee89c2f', '922af2c0-458b-465b-92c7-d0d7985d77c3', '06efdfd100fe37a97ac0605706ce00898bdba531c54738a87b537462f43f95fa', '2025-08-01T09:37:21.000Z', '2025-08-02T04:07:21.000Z', TRUE);
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('0f9d1fc9-c52f-44f6-a9f3-e0f995c5f45c', 'admin-clean-001', '32a4564767c76793b4401faac2fa2bf68cf84547d27784052a6439d400f5e6ba', '2025-08-01T09:29:42.000Z', '2025-08-02T03:59:42.000Z', FALSE);
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('0fda384a-784b-46cb-9fe1-544eee7c53ef', 'admin-clean-001', '083c9b4e32609852a0305be6eb5c13c100865eaeb4df76a8ea6f26fc94be00be', '2025-08-01T09:29:53.000Z', '2025-08-02T03:59:53.000Z', FALSE);
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('6fd9e3f5-9dff-4d00-afd6-39a110cef626', 'admin-clean-001', '6d9d7aeffd2f149c7aac87ea9388d5bebdda7b1e0b70ca707d7055e1f4a7176d', '2025-08-01T09:29:35.000Z', '2025-08-02T03:59:35.000Z', FALSE);
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('7befd4e2-3212-47de-9ac7-2e805d79f417', 'admin-clean-001', 'bae497227439d976fa65886c30a64b7ba96b730ad4b2b9d60df3d5d4e60c314b', '2025-08-01T09:31:23.000Z', '2025-08-02T04:01:23.000Z', TRUE);
INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES ('df6601d4-fec3-490f-bc4e-7549e4c7d084', '52ca326b-e6e2-4f8e-9412-04ce6a2bac99', '2b19390138daec60371e7ef782d443dc5e857d83e3dc99ddf59308a44e035a1b', '2025-08-01T09:38:16.000Z', '2025-08-02T04:08:17.000Z', TRUE);

