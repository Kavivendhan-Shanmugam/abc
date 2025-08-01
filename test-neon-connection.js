import pkg from 'pg';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const { Client } = pkg;

async function testConnection() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: {
      rejectUnauthorized: false
    }
  });

  try {
    console.log('🔗 Connecting to Neon database...');
    await client.connect();
    console.log('✅ Successfully connected to Neon!');
    
    // Test query
    const result = await client.query('SELECT version();');
    console.log('📊 Database info:', result.rows[0].version);
    
    return true;
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    return false;
  } finally {
    await client.end();
  }
}

testConnection();
