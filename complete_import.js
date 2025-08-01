import mysql from 'mysql2/promise';
import fs from 'fs';

const railwayConfig = {
  host: 'switchback.proxy.rlwy.net',
  port: 42329,
  user: 'root',
  password: 'xVkDlxLAAXWbyuGsWwsSOMvViKjLgTzs',
  database: 'railway',
  ssl: {
    rejectUnauthorized: false
  }
};

async function createTables() {
  let connection;
  
  try {
    console.log('Connecting to Railway MySQL database...');
    connection = await mysql.createConnection(railwayConfig);
    console.log('Connected successfully!');
    
    // Create tables in the correct order (respecting foreign key dependencies)
    const tableQueries = [
      // First, create tables without foreign keys
      `CREATE TABLE IF NOT EXISTS users (
        id varchar(36) NOT NULL,
        email varchar(255) NOT NULL,
        password_hash varchar(255) NOT NULL,
        first_name varchar(255) NOT NULL,
        last_name varchar(255) NOT NULL,
        role enum('Student','Staff','Admin') DEFAULT 'Student',
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS staff (
        id varchar(36) NOT NULL,
        user_id varchar(36) DEFAULT NULL,
        staff_id varchar(100) NOT NULL,
        name varchar(255) NOT NULL,
        email varchar(255) NOT NULL,
        phone varchar(20) DEFAULT NULL,
        department varchar(100) DEFAULT NULL,
        designation varchar(100) DEFAULT NULL,
        profile_image_url varchar(500) DEFAULT NULL,
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY staff_id (staff_id),
        KEY user_id (user_id),
        CONSTRAINT staff_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS students (
        id varchar(36) NOT NULL,
        user_id varchar(36) DEFAULT NULL,
        register_number varchar(100) NOT NULL,
        name varchar(255) NOT NULL,
        email varchar(255) NOT NULL,
        semester varchar(10) DEFAULT NULL,
        batch varchar(20) DEFAULT NULL,
        phone varchar(20) DEFAULT NULL,
        tutor_id varchar(36) DEFAULT NULL,
        profile_image_url varchar(500) DEFAULT NULL,
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE KEY register_number (register_number),
        KEY user_id (user_id),
        KEY tutor_id (tutor_id),
        CONSTRAINT students_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL,
        CONSTRAINT students_ibfk_2 FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS user_sessions (
        id varchar(36) NOT NULL,
        user_id varchar(36) NOT NULL,
        token_hash varchar(255) NOT NULL,
        expires_at timestamp NOT NULL,
        is_active tinyint(1) DEFAULT '1',
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY user_id (user_id),
        KEY token_hash (token_hash),
        CONSTRAINT user_sessions_ibfk_1 FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS leave_requests (
        id varchar(36) NOT NULL,
        student_id varchar(36) NOT NULL,
        student_name varchar(255) NOT NULL,
        student_register_number varchar(100) NOT NULL,
        tutor_id varchar(36) NOT NULL,
        tutor_name varchar(255) NOT NULL,
        start_date date NOT NULL,
        end_date date NOT NULL,
        total_days int NOT NULL,
        subject varchar(500) NOT NULL,
        description text,
        status enum('Pending','Approved','Rejected','Forwarded','Cancelled','Cancellation Pending','Retried') DEFAULT 'Pending',
        cancel_reason text,
        partial_cancel_start date DEFAULT NULL,
        partial_cancel_end date DEFAULT NULL,
        partial_cancel_days int DEFAULT NULL,
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY student_id (student_id),
        KEY tutor_id (tutor_id),
        KEY idx_leave_partial_cancellation (status,partial_cancel_start,partial_cancel_end),
        CONSTRAINT leave_requests_ibfk_1 FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        CONSTRAINT leave_requests_ibfk_2 FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS od_requests (
        id varchar(36) NOT NULL,
        student_id varchar(36) NOT NULL,
        student_name varchar(255) NOT NULL,
        student_register_number varchar(100) NOT NULL,
        tutor_id varchar(36) NOT NULL,
        tutor_name varchar(255) NOT NULL,
        date date NOT NULL,
        subject varchar(500) NOT NULL,
        description text,
        certificate_url varchar(500) DEFAULT NULL,
        status enum('Pending','Approved','Rejected','Forwarded') DEFAULT 'Pending',
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY student_id (student_id),
        KEY tutor_id (tutor_id),
        CONSTRAINT od_requests_ibfk_1 FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        CONSTRAINT od_requests_ibfk_2 FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`,
      
      `CREATE TABLE IF NOT EXISTS profile_change_requests (
        id varchar(36) NOT NULL,
        student_id varchar(36) NOT NULL,
        student_name varchar(255) NOT NULL,
        student_register_number varchar(100) NOT NULL,
        tutor_id varchar(36) NOT NULL,
        tutor_name varchar(255) NOT NULL,
        field_name varchar(100) NOT NULL,
        current_value varchar(500) DEFAULT NULL,
        requested_value varchar(500) NOT NULL,
        reason text,
        status enum('Pending','Approved','Rejected') DEFAULT 'Pending',
        created_at timestamp NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        KEY student_id (student_id),
        KEY tutor_id (tutor_id),
        KEY idx_profile_change_status (status),
        CONSTRAINT profile_change_requests_ibfk_1 FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        CONSTRAINT profile_change_requests_ibfk_2 FOREIGN KEY (tutor_id) REFERENCES staff (id) ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`
    ];
    
    console.log('Creating tables in correct order...');
    for (let i = 0; i < tableQueries.length; i++) {
      try {
        await connection.execute(tableQueries[i]);
        console.log(`✓ Table ${i + 1}/${tableQueries.length} created successfully`);
      } catch (error) {
        console.log(`⚠ Table ${i + 1} already exists or error:`, error.message);
      }
    }
    
    console.log('\n✅ Database schema creation completed!');
    
    // Verify all tables
    const [tables] = await connection.execute('SHOW TABLES');
    console.log('\nTables in database:');
    tables.forEach(table => {
      console.log(`- ${Object.values(table)[0]}`);
    });
    
  } catch (error) {
    console.error('❌ Error creating database schema:', error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\nConnection closed.');
    }
  }
}

createTables();
