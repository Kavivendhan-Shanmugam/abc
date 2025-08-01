# Complete Migration Guide: MySQL to Neon PostgreSQL + Netlify Deployment

## Prerequisites
- Node.js installed
- Access to your current MySQL database
- Neon account (free at https://neon.tech)
- Netlify account (free at https://netlify.com)

## Step 1: Set up Neon Database

1. **Create Neon Account**
   - Go to https://neon.tech
   - Sign up for a free account
   - Verify your email

2. **Create New Project**
   - Click "Create Project"
   - Choose a name: `leave-portal`
   - Select region closest to your users
   - Choose PostgreSQL version (latest is fine)

3. **Get Connection String**
   - After project creation, you'll see a connection string like:
   ```
   postgresql://username:password@ep-xxx-xxx.region.aws.neon.tech/neondb?sslmode=require
   ```
   - Copy this entire string

## Step 2: Configure Environment

1. **Create environment file**
   ```bash
   copy .env.example .env
   ```

2. **Update .env file with your Neon details**
   ```env
   # Replace with your actual Neon connection string
   DATABASE_URL=postgresql://username:password@ep-xxx-xxx.region.aws.neon.tech/neondb?sslmode=require
   
   # Generate a strong JWT secret
   JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
   
   # Your old MySQL details (for migration)
   OLD_DB_HOST=localhost
   OLD_DB_USER=root
   OLD_DB_PASSWORD=your_mysql_password
   OLD_DB_NAME=cyber_security_leave_portal
   ```

## Step 3: Run Database Schema Migration

1. **Connect to your Neon database using psql or a GUI tool**
   - Use the connection string from Step 1
   - Or use Neon's built-in SQL editor

2. **Run the schema file**
   - Open `neon-migration/schema-postgres.sql`
   - Copy all contents
   - Execute in your Neon database

## Step 4: Migrate Your Data

1. **Set environment variables for migration**
   ```bash
   $env:OLD_DB_PASSWORD="your_mysql_password"
   $env:OLD_DB_HOST="localhost"
   $env:OLD_DB_USER="root"
   $env:OLD_DB_NAME="cyber_security_leave_portal"
   ```

2. **Run the data migration script**
   ```bash
   node neon-migration/migrate-data.js
   ```

3. **Import the generated data to Neon**
   - The script will create `data-export.sql`
   - Run this file in your Neon database

## Step 5: Test Local Connection

1. **Update your .env file**
   ```bash
   copy neon-migration/.env.neon .env
   ```
   Edit with your actual Neon connection string

2. **Test the connection**
   ```bash
   npm run server
   ```

## Step 6: Deploy to Netlify

1. **Build your project**
   ```bash
   npm run build
   ```

2. **Create Netlify site**
   - Go to https://netlify.com
   - Sign up/login
   - Drag and drop your `dist` folder OR connect to GitHub

3. **Set Environment Variables in Netlify**
   - Go to Site Settings > Environment Variables
   - Add:
     - `DATABASE_URL`: Your Neon connection string
     - `JWT_SECRET`: Your JWT secret
     - `NODE_VERSION`: 18

4. **Configure Build Settings**
   - Build command: `npm run build`
   - Publish directory: `dist`

## Troubleshooting

### Common Issues:
1. **Connection Refused**: Check your Neon connection string
2. **SSL Errors**: Ensure `sslmode=require` is in your connection string
3. **Migration Errors**: Check your MySQL credentials

### Test Commands:
```bash
# Test PostgreSQL connection
node -e "import('pg').then(({default: pg}) => { const client = new pg.Client(process.env.DATABASE_URL); client.connect().then(() => console.log('Connected!')).catch(console.error); })"

# Test build
npm run build

# Test server locally
npm run server
```

## What Gets Updated:
- ✅ Database schema converted to PostgreSQL
- ✅ All data migrated with proper type conversions
- ✅ Application configuration updated for PostgreSQL
- ✅ Netlify deployment configuration ready
- ✅ Environment variables configured

## Next Steps After Migration:
1. Update any hardcoded MySQL queries to PostgreSQL syntax
2. Test all application features
3. Set up monitoring and backups
4. Configure custom domain (if needed)
