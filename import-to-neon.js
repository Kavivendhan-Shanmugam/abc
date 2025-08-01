import pkg from 'pg';
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config();

const { Client } = pkg;

async function importDataToNeon() {
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

    // Read the exported data file
    const dataPath = path.join(__dirname, 'neon-migration', 'data-export.sql');
    console.log('📁 Reading data export file...');
    
    if (!fs.existsSync(dataPath)) {
      throw new Error('Data export file not found. Please run the migration script first.');
    }
    
    const sqlData = fs.readFileSync(dataPath, 'utf8');
    
    console.log('📊 Importing data to Neon...');
    
    // Split the SQL into individual statements and execute them
    const statements = sqlData.split(';\n').filter(stmt => stmt.trim() && !stmt.trim().startsWith('--'));
    
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i].trim();
      if (statement) {
        try {
          await client.query(statement);
          console.log(`✅ Executed statement ${i + 1}/${statements.length}`);
        } catch (error) {
          console.warn(`⚠️  Warning on statement ${i + 1}: ${error.message}`);
          // Continue with other statements even if one fails
        }
      }
    }
    
    console.log('🎉 Data import completed!');
    
    // Verify the import
    console.log('🔍 Verifying imported data...');
    const userCount = await client.query('SELECT COUNT(*) as count FROM users');
    const staffCount = await client.query('SELECT COUNT(*) as count FROM staff');
    const studentCount = await client.query('SELECT COUNT(*) as count FROM students');
    
    console.log(`📊 Import summary:`);
    console.log(`   - Users: ${userCount.rows[0].count}`);
    console.log(`   - Staff: ${staffCount.rows[0].count}`);
    console.log(`   - Students: ${studentCount.rows[0].count}`);
    
    return true;

  } catch (error) {
    console.error('❌ Error importing data:', error.message);
    return false;
  } finally {
    await client.end();
  }
}

importDataToNeon();
