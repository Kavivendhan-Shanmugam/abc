# ACE CSS Leave Portal - Complete Setup Guide

This is a comprehensive leave management system built with React (frontend) and Node.js/Express (backend) with MySQL database.

## 🏗️ Project Structure

```
ace_css_leave_portal/
├── backend/
│   ├── config/database.js       # Database configuration
│   ├── uploads/                 # File uploads (profile photos, certificates)
│   └── server.js               # Main backend server
├── src/                        # React frontend source
├── public/                     # Static assets
├── package.json               # Dependencies and scripts
├── schema.sql                 # Database schema
├── requirements.txt           # All npm dependencies
└── reset_database_with_test_data.sql  # Test data
```

## 📋 Prerequisites

- **Node.js** (v18.0 or higher)
- **MySQL** (v8.0 or higher)
- **npm** (comes with Node.js)

## 🚀 Quick Setup (New Machine)

### 1. Clone/Download Project Files
```bash
# If using git
git clone <repository-url>
cd ace_css_leave_portal

# Or download and extract the project files
```

### 2. Install Dependencies
```bash
# Initialize npm if package.json doesn't exist
npm init -y

# Install all dependencies at once
npm install express@^4.18.2 mysql2@^3.6.5 cors@^2.8.5 bcryptjs@^2.4.3 jsonwebtoken@^9.0.2 uuid@^9.0.1 node-cron@^4.2.1 multer@^2.0.2 sharp@^0.34.3 react@^18.3.1 react-dom@^18.3.1 react-router-dom@^6.26.2 react-hook-form@^7.53.0 @hookform/resolvers@^3.9.0 @radix-ui/react-accordion@^1.2.0 @radix-ui/react-alert-dialog@^1.1.1 @radix-ui/react-aspect-ratio@^1.1.0 @radix-ui/react-avatar@^1.1.0 @radix-ui/react-checkbox@^1.1.1 @radix-ui/react-collapsible@^1.1.0 @radix-ui/react-context-menu@^2.2.1 @radix-ui/react-dialog@^1.1.2 @radix-ui/react-dropdown-menu@^2.1.1 @radix-ui/react-hover-card@^1.1.1 @radix-ui/react-label@^2.1.0 @radix-ui/react-menubar@^1.1.1 @radix-ui/react-navigation-menu@^1.2.0 @radix-ui/react-popover@^1.1.1 @radix-ui/react-progress@^1.1.0 @radix-ui/react-radio-group@^1.2.0 @radix-ui/react-scroll-area@^1.1.0 @radix-ui/react-select@^2.1.1 @radix-ui/react-separator@^1.1.0 @radix-ui/react-slider@^1.2.0 @radix-ui/react-slot@^1.1.0 @radix-ui/react-switch@^1.1.0 @radix-ui/react-tabs@^1.1.0 @radix-ui/react-toast@^1.2.1 @radix-ui/react-toggle@^1.1.0 @radix-ui/react-toggle-group@^1.1.0 @radix-ui/react-tooltip@^1.1.4 @tanstack/react-query@^5.56.2 axios@^1.6.0 class-variance-authority@^0.7.1 clsx@^2.1.1 cmdk@^1.0.0 date-fns@^3.6.0 embla-carousel-react@^8.3.0 form-data@^4.0.4 input-otp@^1.2.4 jszip@^3.10.1 lucide-react@^0.462.0 next-themes@^0.3.0 node-fetch@^3.3.2 papaparse@^5.5.3 react-day-picker@^8.10.1 react-resizable-panels@^2.1.3 recharts@^2.12.7 sonner@^1.5.0 tailwind-merge@^2.5.2 tailwindcss-animate@^1.0.7 vaul@^0.9.3 xlsx@^0.18.5 zod@^3.23.8 @types/multer@^2.0.0 @types/node@^22.5.5 @types/react@^18.3.3 @types/react-dom@^18.3.0

# Install dev dependencies
npm install --save-dev @dyad-sh/react-vite-component-tagger@^0.8.0 @eslint/js@^9.9.0 @tailwindcss/typography@^0.5.15 @vitejs/plugin-react-swc@^3.9.0 autoprefixer@^10.4.20 concurrently@^8.2.2 eslint@^9.9.0 eslint-plugin-react-hooks@^5.1.0-rc.0 eslint-plugin-react-refresh@^0.4.9 globals@^15.9.0 nodemon@^3.0.2 postcss@^8.4.47 tailwindcss@^3.4.11 typescript@^5.5.3 typescript-eslint@^8.0.1 vite@^6.3.4

# Alternative: Use requirements.txt (copy individual lines)
# See requirements.txt for detailed package installation
```

### 3. Database Setup

#### Create Database
```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE IF NOT EXISTS cyber_security_leave_portal;
USE cyber_security_leave_portal;

# Exit MySQL
exit
```

#### Import Schema
```bash
# Import the schema
mysql -u root -p cyber_security_leave_portal < schema.sql

# Optional: Import test data
mysql -u root -p cyber_security_leave_portal < reset_database_with_test_data.sql
```

### 4. Configure Database Connection

Create/Edit `backend/config/database.js`:
```javascript
export const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'your_mysql_password',
  database: process.env.DB_NAME || 'cyber_security_leave_portal',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: '+00:00'
};

export const jwtSecret = process.env.JWT_SECRET || 'your_super_secret_jwt_key_change_this_in_production';
```

### 5. Create Required Directories
```bash
mkdir -p backend/uploads/profile-photos backend/uploads/certificates
```

## 🏃‍♂️ Running the Application

### Development Mode (Both servers)
```bash
npm run dev-full
```
This starts both:
- Backend server: http://localhost:3002
- Frontend server: http://localhost:5173 (or 8080)

### Individual Servers
```bash
# Backend only
npm run server

# Frontend only  
npm run dev
```

### Production Build
```bash
npm run build
npm run preview
```

## 🔐 Default Admin Account

After running the test data script or creating manually:

- **Email**: `admin@test.com`
- **Username**: `admin` 
- **Password**: `admin123`

## 📚 API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout

### Users & Profiles
- `GET /students` - Get all students
- `GET /staff` - Get all staff
- `POST /students` - Create student
- `POST /staff` - Create staff member
- `PUT /students/:id` - Update student
- `PUT /staff/:id` - Update staff

### Leave Management
- `GET /leave-requests` - Get leave requests
- `POST /leave-requests` - Create leave request
- `PUT /leave-requests/:id/status` - Update leave status

### OD Management
- `GET /od-requests` - Get OD requests
- `POST /od-requests` - Create OD request
- `PUT /od-requests/:id/status` - Update OD status
- `POST /od-requests/:id/certificate` - Upload certificate

### File Uploads
- `POST /upload/profile-photo` - Upload profile photo
- `DELETE /upload/profile-photo` - Remove profile photo

## 🗂️ Database Schema

The system uses 7 main tables:

1. **users** - Base authentication
2. **staff** - Tutors and administrators  
3. **students** - Student information
4. **user_sessions** - JWT session management
5. **leave_requests** - Leave applications
6. **od_requests** - Official duty requests
7. **profile_change_requests** - Profile modification requests

## 🔧 Configuration Options

### Environment Variables
Create `.env` file:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=cyber_security_leave_portal
JWT_SECRET=your_jwt_secret_key
PORT=3002
```

### Database Configuration
Edit `backend/config/database.js` for custom database settings.

## 🚀 Deployment

### Production Checklist
1. **Security**: Change JWT secret and database passwords
2. **Database**: Use production MySQL instance
3. **Environment**: Set NODE_ENV=production
4. **Build**: Run `npm run build`
5. **Process Manager**: Use PM2 or similar for process management
6. **Reverse Proxy**: Configure Nginx/Apache for production
7. **SSL**: Enable HTTPS certificates
8. **Backups**: Set up database backup strategy

### PM2 Deployment
```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save
pm2 startup
```

## 🛠️ Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check MySQL service is running
   - Verify credentials in `backend/config/database.js`
   - Ensure database exists

2. **Port Already in Use**
   - Kill existing Node processes: `pkill node`
   - Change ports in configuration

3. **Module Not Found Errors**
   - Run `npm install` to install missing dependencies
   - Clear npm cache: `npm cache clean --force`

4. **Frontend Build Issues**
   - Check Node.js version (needs v18+)
   - Clear node_modules and reinstall: `rm -rf node_modules && npm install`

### Logs and Debugging
```bash
# Check backend logs
npm run server

# Check database connection
npm run test-db

# Verbose logging
DEBUG=* npm run server
```

## 📞 Support

For issues and questions:

1. Check this README
2. Review error logs
3. Verify database schema matches current version
4. Ensure all dependencies are installed correctly

## 🔄 Updates and Maintenance

### Database Migrations
When updating schema:
1. Backup existing database
2. Run new schema.sql
3. Migrate existing data if needed

### Dependency Updates
```bash
# Check outdated packages
npm outdated

# Update packages
npm update

# Update package.json versions
npx npm-check-updates -u && npm install
```

---

**Version**: 1.0.0  
**Last Updated**: January 2025  
**Node.js**: v18.0+  
**MySQL**: v8.0+
