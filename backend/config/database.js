import pkg from 'pg';
const { Pool } = pkg;

function getDatabaseConfig() {
  const postgresUrl = process.env.DATABASE_URL || process.env.POSTGRES_URL;
  
  console.log('Database URL from env:', postgresUrl ? 'Found' : 'Not found');
  console.log('All environment variables:', Object.keys(process.env).filter(key => key.includes('DATABASE')));
  
  if (postgresUrl) {
    console.log('Using PostgreSQL connection string');
    return {
      connectionString: postgresUrl,
      ssl: {
        rejectUnauthorized: false
      },
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 10000,
    };
  }
  
  console.log('Falling back to localhost configuration (this should not happen!)');
  console.log('DATABASE_URL env var:', process.env.DATABASE_URL);
  
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

const dbConfig = getDatabaseConfig();
const pool = new Pool(dbConfig);

// Handle pool errors
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Export the pool and query function
export { pool };
export const query = (text, params) => pool.query(text, params);
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
