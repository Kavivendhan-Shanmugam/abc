// Function to parse Railway MySQL URL or use individual env vars
function getDatabaseConfig() {
  // Check if we have a Railway MySQL URL
  const mysqlUrl = process.env.MYSQL_URL || process.env.DATABASE_URL;
  
  if (mysqlUrl) {
    // Parse the MySQL URL format: mysql://user:password@host:port/database
    const url = new URL(mysqlUrl);
    return {
      host: url.hostname,
      port: url.port || 3306,
      user: url.username,
      password: url.password,
      database: url.pathname.slice(1), // Remove the leading '/'
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      timezone: '+00:00',
      ssl: {
        rejectUnauthorized: false // Railway requires SSL
      }
    };
  }
  
  // Fallback to individual environment variables (for local development)
  return {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'cyber_security_leave_portal',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    timezone: '+00:00'
  };
}

export const dbConfig = getDatabaseConfig();

export const jwtSecret = process.env.JWT_SECRET || 'your_super_secret_jwt_key_change_this_in_production';
