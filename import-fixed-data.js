import pkg from 'pg';
import dotenv from 'dotenv';
import { v4 as uuidv4 } from 'uuid';
import bcrypt from 'bcryptjs';

// Load environment variables
dotenv.config();

const { Client } = pkg;

async function importFixedData() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    console.log('🔗 Connecting to Neon database...');
    await client.connect();
    console.log('✅ Connected successfully!');

    // Clear existing data first
    console.log('🧹 Clearing existing data...');
    await client.query('DELETE FROM user_sessions');
    await client.query('DELETE FROM leave_requests');
    await client.query('DELETE FROM od_requests');
    await client.query('DELETE FROM students');
    await client.query('DELETE FROM staff');
    await client.query('DELETE FROM users');

    // Create the default admin user with proper UUID
    console.log('👤 Creating admin user...');
    const adminId = '550e8400-e29b-41d4-a716-446655440000'; // Fixed UUID for admin
    const adminPasswordHash = await bcrypt.hash('admin123', 10);
    
    await client.query(`
      INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) 
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [adminId, 'admin@college.portal', adminPasswordHash, 'Admin', 'User', true, true]);

    await client.query(`
      INSERT INTO staff (id, name, email, username, is_admin, is_tutor) 
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [adminId, 'Admin User', 'admin@college.portal', 'admin', true, true]);

    // Create a test tutor
    console.log('👨‍🏫 Creating test tutor...');
    const tutorId = uuidv4();
    const tutorPasswordHash = await bcrypt.hash('tutor123', 10);
    
    await client.query(`
      INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) 
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [tutorId, 'tutor@college.portal', tutorPasswordHash, 'Test', 'Tutor', false, true]);

    await client.query(`
      INSERT INTO staff (id, name, email, username, is_admin, is_tutor) 
      VALUES ($1, $2, $3, $4, $5, $6)
    `, [tutorId, 'Test Tutor', 'tutor@college.portal', 'tutor', false, true]);

    // Create a test student
    console.log('🎓 Creating test student...');
    const studentId = uuidv4();
    const studentPasswordHash = await bcrypt.hash('student123', 10);
    
    await client.query(`
      INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) 
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [studentId, 'student@college.portal', studentPasswordHash, 'Test', 'Student', false, false]);

    await client.query(`
      INSERT INTO students (id, name, register_number, tutor_id, batch, semester, leave_taken, username) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    `, [studentId, 'Test Student', 'STU001', tutorId, '2024', 3, 0, 'student']);

    console.log('🎉 Sample data created successfully!');
    
    // Verify the import
    console.log('🔍 Verifying created data...');
    const userCount = await client.query('SELECT COUNT(*) as count FROM users');
    const staffCount = await client.query('SELECT COUNT(*) as count FROM staff');
    const studentCount = await client.query('SELECT COUNT(*) as count FROM students');
    
    console.log(`📊 Database summary:`);
    console.log(`   - Users: ${userCount.rows[0].count}`);
    console.log(`   - Staff: ${staffCount.rows[0].count}`);
    console.log(`   - Students: ${studentCount.rows[0].count}`);
    
    console.log(`\n🔑 Test accounts created:`);
    console.log(`   Admin: admin@college.portal / admin123`);
    console.log(`   Tutor: tutor@college.portal / tutor123`);
    console.log(`   Student: student@college.portal / student123`);
    
    return true;

  } catch (error) {
    console.error('❌ Error importing data:', error.message);
    return false;
  } finally {
    await client.end();
  }
}

importFixedData();
