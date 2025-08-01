// Migration script to export data from MySQL and prepare for PostgreSQL import
import mysql from 'mysql2/promise';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// MySQL connection configuration (update with your current MySQL details)
const mysqlConfig = {
  host: process.env.OLD_DB_HOST || 'localhost',
  user: process.env.OLD_DB_USER || 'root',
  password: process.env.OLD_DB_PASSWORD,
  database: process.env.OLD_DB_NAME || 'cyber_security_leave_portal',
  timezone: '+00:00'
};

// Function to convert MySQL UUID string to PostgreSQL UUID format
function convertUUID(mysqlUuid) {
  if (!mysqlUuid) return null;
  // If it's already in UUID format, return as is
  if (mysqlUuid.includes('-')) return `'${mysqlUuid}'`;
  // If it's a simple string like 'admin-001', generate a consistent UUID
  if (mysqlUuid === 'admin-001') {
    return "'550e8400-e29b-41d4-a716-446655440000'";
  }
  // For other string IDs, you might need to generate UUIDs or handle differently
  return `'${mysqlUuid}'`;
}

// Function to convert MySQL DATETIME to PostgreSQL TIMESTAMP WITH TIME ZONE
function convertDateTime(mysqlDateTime) {
  if (!mysqlDateTime) return 'NULL';
  const date = new Date(mysqlDateTime);
  return `'${date.toISOString()}'`;
}

// Function to convert MySQL BOOLEAN to PostgreSQL BOOLEAN
function convertBoolean(mysqlBoolean) {
  return mysqlBoolean ? 'TRUE' : 'FALSE';
}

// Function to escape SQL strings
function escapeSQLString(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${str.toString().replace(/'/g, "''")}'`;
}

async function exportMySQLData() {
  let connection;
  
  try {
    console.log('Connecting to MySQL database...');
    connection = await mysql.createConnection(mysqlConfig);
    
    const tables = ['users', 'staff', 'students', 'leave_requests', 'od_requests', 'user_sessions'];
    const exportData = {};
    
    for (const table of tables) {
      console.log(`Exporting ${table}...`);
      const [rows] = await connection.execute(`SELECT * FROM ${table}`);
      exportData[table] = rows;
      console.log(`Exported ${rows.length} rows from ${table}`);
    }
    
    // Generate PostgreSQL INSERT statements
    let sqlOutput = '-- PostgreSQL Data Import\n';
    sqlOutput += '-- Generated from MySQL export\n\n';
    
    // Users table
    if (exportData.users && exportData.users.length > 0) {
      sqlOutput += '-- Insert users\n';
      for (const user of exportData.users) {
        const values = [
          convertUUID(user.id),
          escapeSQLString(user.email),
          escapeSQLString(user.password_hash),
          escapeSQLString(user.first_name),
          escapeSQLString(user.last_name),
          escapeSQLString(user.profile_photo),
          convertBoolean(user.is_admin),
          convertBoolean(user.is_tutor),
          convertDateTime(user.created_at),
          convertDateTime(user.updated_at)
        ].join(', ');
        
        sqlOutput += `INSERT INTO users (id, email, password_hash, first_name, last_name, profile_photo, is_admin, is_tutor, created_at, updated_at) VALUES (${values}) ON CONFLICT (email) DO UPDATE SET updated_at = EXCLUDED.updated_at;\n`;
      }
      sqlOutput += '\n';
    }
    
    // Staff table
    if (exportData.staff && exportData.staff.length > 0) {
      sqlOutput += '-- Insert staff\n';
      for (const staff of exportData.staff) {
        const values = [
          convertUUID(staff.id),
          escapeSQLString(staff.name),
          escapeSQLString(staff.email),
          escapeSQLString(staff.username),
          convertBoolean(staff.is_admin),
          convertBoolean(staff.is_tutor),
          escapeSQLString(staff.profile_photo),
          convertDateTime(staff.created_at),
          convertDateTime(staff.updated_at)
        ].join(', ');
        
        sqlOutput += `INSERT INTO staff (id, name, email, username, is_admin, is_tutor, profile_photo, created_at, updated_at) VALUES (${values}) ON CONFLICT (username) DO UPDATE SET updated_at = EXCLUDED.updated_at;\n`;
      }
      sqlOutput += '\n';
    }
    
    // Students table
    if (exportData.students && exportData.students.length > 0) {
      sqlOutput += '-- Insert students\n';
      for (const student of exportData.students) {
        const values = [
          convertUUID(student.id),
          escapeSQLString(student.name),
          escapeSQLString(student.register_number),
          student.tutor_id ? convertUUID(student.tutor_id) : 'NULL',
          escapeSQLString(student.batch),
          student.semester,
          student.leave_taken,
          escapeSQLString(student.username),
          escapeSQLString(student.profile_photo),
          convertDateTime(student.created_at),
          convertDateTime(student.updated_at)
        ].join(', ');
        
        sqlOutput += `INSERT INTO students (id, name, register_number, tutor_id, batch, semester, leave_taken, username, profile_photo, created_at, updated_at) VALUES (${values}) ON CONFLICT (register_number) DO UPDATE SET updated_at = EXCLUDED.updated_at;\n`;
      }
      sqlOutput += '\n';
    }
    
    // Leave requests table
    if (exportData.leave_requests && exportData.leave_requests.length > 0) {
      sqlOutput += '-- Insert leave_requests\n';
      for (const request of exportData.leave_requests) {
        const values = [
          convertUUID(request.id),
          convertUUID(request.student_id),
          escapeSQLString(request.student_name),
          escapeSQLString(request.student_register_number),
          convertUUID(request.tutor_id),
          escapeSQLString(request.tutor_name),
          `'${request.start_date}'`,
          `'${request.end_date}'`,
          request.total_days,
          request.partial_cancel_start ? `'${request.partial_cancel_start}'` : 'NULL',
          request.partial_cancel_end ? `'${request.partial_cancel_end}'` : 'NULL',
          request.partial_cancel_days || 'NULL',
          escapeSQLString(request.subject),
          escapeSQLString(request.description),
          escapeSQLString(request.status),
          escapeSQLString(request.cancel_reason),
          request.original_status ? escapeSQLString(request.original_status) : 'NULL',
          convertDateTime(request.created_at),
          convertDateTime(request.updated_at)
        ].join(', ');
        
        sqlOutput += `INSERT INTO leave_requests (id, student_id, student_name, student_register_number, tutor_id, tutor_name, start_date, end_date, total_days, partial_cancel_start, partial_cancel_end, partial_cancel_days, subject, description, status, cancel_reason, original_status, created_at, updated_at) VALUES (${values});\n`;
      }
      sqlOutput += '\n';
    }
    
    // OD requests table
    if (exportData.od_requests && exportData.od_requests.length > 0) {
      sqlOutput += '-- Insert od_requests\n';
      for (const request of exportData.od_requests) {
        const values = [
          convertUUID(request.id),
          convertUUID(request.student_id),
          escapeSQLString(request.student_name),
          escapeSQLString(request.student_register_number),
          convertUUID(request.tutor_id),
          escapeSQLString(request.tutor_name),
          `'${request.start_date}'`,
          `'${request.end_date}'`,
          request.total_days,
          escapeSQLString(request.purpose),
          escapeSQLString(request.destination),
          escapeSQLString(request.description),
          escapeSQLString(request.status),
          escapeSQLString(request.cancel_reason),
          escapeSQLString(request.certificate_url),
          request.certificate_status ? escapeSQLString(request.certificate_status) : 'NULL',
          request.upload_deadline ? `'${request.upload_deadline}'` : 'NULL',
          request.last_notification_date ? `'${request.last_notification_date}'` : 'NULL',
          request.original_status ? escapeSQLString(request.original_status) : 'NULL',
          convertDateTime(request.created_at),
          convertDateTime(request.updated_at)
        ].join(', ');
        
        sqlOutput += `INSERT INTO od_requests (id, student_id, student_name, student_register_number, tutor_id, tutor_name, start_date, end_date, total_days, purpose, destination, description, status, cancel_reason, certificate_url, certificate_status, upload_deadline, last_notification_date, original_status, created_at, updated_at) VALUES (${values});\n`;
      }
      sqlOutput += '\n';
    }
    
    // User sessions table
    if (exportData.user_sessions && exportData.user_sessions.length > 0) {
      sqlOutput += '-- Insert user_sessions\n';
      for (const session of exportData.user_sessions) {
        const values = [
          convertUUID(session.id),
          convertUUID(session.user_id),
          escapeSQLString(session.token_hash),
          convertDateTime(session.created_at),
          convertDateTime(session.expires_at),
          convertBoolean(session.is_active)
        ].join(', ');
        
        sqlOutput += `INSERT INTO user_sessions (id, user_id, token_hash, created_at, expires_at, is_active) VALUES (${values});\n`;
      }
      sqlOutput += '\n';
    }
    
    // Write to file
    const outputPath = path.join(__dirname, 'data-export.sql');
    fs.writeFileSync(outputPath, sqlOutput);
    
    console.log(`Data export completed successfully!`);
    console.log(`SQL file saved to: ${outputPath}`);
    console.log(`\nNext steps:`);
    console.log(`1. Set up your Neon database`);
    console.log(`2. Run the schema-postgres.sql file on your Neon database`);
    console.log(`3. Run the data-export.sql file on your Neon database`);
    console.log(`4. Update your application configuration`);
    
  } catch (error) {
    console.error('Error during data export:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

// Check if we have the required environment variables
if (!process.env.OLD_DB_PASSWORD) {
  console.log('Please set the following environment variables:');
  console.log('OLD_DB_HOST (optional, defaults to localhost)');
  console.log('OLD_DB_USER (optional, defaults to root)');
  console.log('OLD_DB_PASSWORD (required)');
  console.log('OLD_DB_NAME (optional, defaults to cyber_security_leave_portal)');
  process.exit(1);
}

// Run the export
exportMySQLData();
