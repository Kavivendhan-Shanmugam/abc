// Updated database configuration for Neon PostgreSQL
import pkg from 'pg';
const { Pool } = pkg;

// Function to parse Neon PostgreSQL URL or use individual env vars
function getDatabaseConfig() {
  // Check if we have a Neon PostgreSQL URL
  const postgresUrl = process.env.DATABASE_URL || process.env.POSTGRES_URL;
  
  if (postgresUrl) {
    // Neon provides the connection URL directly
    return {
      connectionString: postgresUrl,
      ssl: {
        rejectUnauthorized: false // Neon requires SSL
      },
      max: 10, // maximum number of clients in the pool
      idleTimeoutMillis: 30000, // how long a client is allowed to remain idle
      connectionTimeoutMillis: 2000, // how long to wait for a connection
    };
  }
  
  // Fallback to individual environment variables (for local development)
  return {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'cyber_security_leave_portal',
    ssl: process.env.DB_SSL === 'true' ? {
      rejectUnauthorized: false
    } : false,
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  };
}

// Create connection pool
const dbConfig = getDatabaseConfig();
const pool = new Pool(dbConfig);

// Handle pool errors
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Export the pool and query function
export { pool };

// Helper function for queries
export const query = (text, params) => pool.query(text, params);

// JWT Secret
export const jwtSecret = process.env.JWT_SECRET || 'your_super_secret_jwt_key_change_this_in_production';

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('Received SIGINT. Graceful shutdown...');
  pool.end(() => {
    console.log('Pool has ended');
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  console.log('Received SIGTERM. Graceful shutdown...');
  pool.end(() => {
    console.log('Pool has ended');
    process.exit(0);
  });
});
