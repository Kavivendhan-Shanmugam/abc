import mysql from 'mysql2/promise';
import fs from 'fs';

// Railway MySQL connection details (from the MYSQL_PUBLIC_URL)
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

async function importDatabase() {
  let connection;
  
  try {
    console.log('Connecting to Railway MySQL database...');
    connection = await mysql.createConnection(railwayConfig);
    console.log('Connected successfully!');
    
    // Read the SQL file
    console.log('Reading cloneschema.sql...');
    const sqlContent = fs.readFileSync('cloneschema.sql', 'utf8');
    
    // Split the SQL file into individual statements
    const statements = sqlContent
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt && !stmt.startsWith('--') && stmt !== 'COMMIT');
    
    console.log(`Found ${statements.length} SQL statements to execute`);
    
    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      if (statement) {
        try {
          // Skip certain statements that might not work in Railway
          if (statement.includes('CREATE DATABASE') || 
              statement.includes('USE `cyber_security_leave_portal`')) {
            console.log(`Skipping statement ${i + 1}: Database creation/use`);
            continue;
          }
          
          console.log(`Executing statement ${i + 1}/${statements.length}`);
          await connection.execute(statement);
        } catch (error) {
          console.warn(`Warning: Statement ${i + 1} failed:`, error.message);
          // Continue with other statements
        }
      }
    }
    
    console.log('\nDatabase import completed!');
    console.log('Verifying tables were created...');
    
    // Verify tables were created
    const [tables] = await connection.execute('SHOW TABLES');
    console.log('Tables in database:');
    tables.forEach(table => {
      console.log(`- ${Object.values(table)[0]}`);
    });
    
  } catch (error) {
    console.error('Error importing database:', error);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('Connection closed.');
    }
  }
}

// Run the import
importDatabase();
