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

async function setupSchema() {
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

    // Read schema file
    const schemaPath = path.join(__dirname, 'neon-migration', 'schema-postgres.sql');
    console.log('📁 Reading schema file...');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    console.log('🏗️  Setting up database schema...');
    await client.query(schema);
    console.log('✅ Schema setup completed successfully!');

    // Verify tables were created
    console.log('🔍 Verifying tables...');
    const result = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name;
    `);
    
    console.log('📋 Created tables:');
    result.rows.forEach(row => {
      console.log(`   - ${row.table_name}`);
    });

    console.log('🎉 Database setup complete!');
    return true;

  } catch (error) {
    console.error('❌ Error setting up schema:', error.message);
    return false;
  } finally {
    await client.end();
  }
}

setupSchema();
