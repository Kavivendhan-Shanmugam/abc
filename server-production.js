// Production server for Railway deployment
import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { pool, query } from './backend/config/database.js';

const app = express();
app.use(express.json());
app.use(cors({
  origin: ['https://mellifluous-conkies-ca8b7b.netlify.app', 'http://localhost:3000', 'http://localhost:5173'],
  credentials: true
}));

const port = process.env.PORT || 3002;
const jwtSecret = process.env.JWT_SECRET || 'your_super_secret_jwt_key_change_this_in_production';

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Test database connection
app.get('/test-db', async (req, res) => {
  try {
    const result = await query('SELECT COUNT(*) as count FROM users');
    res.json({ 
      success: true, 
      userCount: result.rows[0].count, 
      message: 'Database connection successful' 
    });
  } catch (error) {
    console.error('Database test failed:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Login endpoint
app.post('/auth/login', async (req, res) => {
  try {
    const { identifier, password } = req.body;
    console.log('Login attempt for:', identifier);
    
    let user;
    
    // Check if identifier is email or username
    if (identifier.includes('@')) {
      const result = await query('SELECT * FROM users WHERE email = $1', [identifier]);
      user = result.rows[0];
    } else {
      // Check in staff table for username
      const staffResult = await query('SELECT * FROM staff WHERE username = $1', [identifier]);
      if (staffResult.rows.length > 0) {
        const staffMember = staffResult.rows[0];
        const userResult = await query('SELECT * FROM users WHERE id = $1', [staffMember.id]);
        user = userResult.rows[0];
      }
    }
    
    if (!user) {
      console.log('User not found');
      return res.status(401).json({ error: { message: 'Invalid username or password' } });
    }
    
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      console.log('Invalid password');
      return res.status(401).json({ error: { message: 'Invalid username or password' } });
    }
    
    // Create token
    const token = jwt.sign({ id: user.id }, jwtSecret, { expiresIn: '24h' });
    
    console.log('Login successful for user:', user.email);
    res.json({ 
      token, 
      user: { id: user.id, email: user.email },
      message: 'Login successful!'
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: { message: 'Failed to login' } });
  }
});

// JWT middleware for authentication
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.sendStatus(401);
  }

  jwt.verify(token, jwtSecret, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

// Get user profile
app.get('/profile', authenticateToken, async (req, res) => {
  try {
    const result = await query(
      'SELECT id, email, first_name, last_name, profile_photo, is_admin, is_tutor FROM users WHERE id = $1',
      [req.user.id]
    );
    
    const user = result.rows[0];
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(user);
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

// Get all students
app.get('/students', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM students ORDER BY name');
    res.json(result.rows || []);
  } catch (error) {
    console.error('Students error:', error);
    res.status(500).json({ error: 'Failed to fetch students' });
  }
});

// Get all staff
app.get('/staff', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM staff ORDER BY name');
    res.json(result.rows || []);
  } catch (error) {
    console.error('Staff error:', error);
    res.status(500).json({ error: 'Failed to fetch staff' });
  }
});

// Get leave requests
app.get('/leave-requests', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM leave_requests ORDER BY created_at DESC');
    res.json(result.rows || []);
  } catch (error) {
    console.error('Leave requests error:', error);
    res.status(500).json({ error: 'Failed to fetch leave requests' });
  }
});

// Get OD requests
app.get('/od-requests', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM od_requests ORDER BY created_at DESC');
    res.json(result.rows || []);
  } catch (error) {
    console.error('OD requests error:', error);
    res.status(500).json({ error: 'Failed to fetch OD requests' });
  }
});

// Get profile change requests
app.get('/profile-change-requests', authenticateToken, async (req, res) => {
  try {
    const result = await query('SELECT * FROM profile_change_requests ORDER BY requested_at DESC');
    res.json(result.rows || []);
  } catch (error) {
    console.error('Profile change requests error:', error);
    res.status(500).json({ error: 'Failed to fetch profile change requests' });
  }
});

// Create a new staff member (tutor/admin)
app.post('/staff', authenticateToken, async (req, res) => {
  try {
    const { email, password, name, username, isAdmin, isTutor } = req.body;
    
    console.log('Creating staff member:', { email, name, username, isAdmin, isTutor });
    
    const id = uuidv4();
    const passwordHash = await bcrypt.hash(password, 10);
    
    // Insert into users table first
    await query(
      'INSERT INTO users (id, email, password_hash, first_name, last_name, is_admin, is_tutor) VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [id, email, passwordHash, name.split(' ')[0], name.split(' ').slice(1).join(' '), isAdmin, isTutor]
    );
    
    // Insert into staff table
    await query(
      'INSERT INTO staff (id, name, email, username, is_admin, is_tutor) VALUES ($1, $2, $3, $4, $5, $6)',
      [id, name, email, username, isAdmin, isTutor]
    );
    
    console.log('Staff member created successfully with ID:', id);
    res.status(201).json({ message: 'Staff member created successfully', id });
  } catch (error) {
    console.error('Error creating staff member:', error);
    res.status(500).json({ error: 'Failed to create staff member', details: error.message });
  }
});

// Create a new student
app.post('/students', authenticateToken, async (req, res) => {
  try {
    const { email, password, name, registerNumber, tutorId, batch, semester, mobile } = req.body;
    
    console.log('Creating student:', { email, name, registerNumber, tutorId, batch, semester, mobile });
    
    const id = uuidv4();
    const passwordHash = await bcrypt.hash(password, 10);
    
    // Insert into users table first
    await query(
      'INSERT INTO users (id, email, password_hash, first_name, last_name) VALUES ($1, $2, $3, $4, $5)',
      [id, email, passwordHash, name.split(' ')[0], name.split(' ').slice(1).join(' ')]
    );
    
    // Insert into students table
    const username = email.split('@')[0]; // Generate username from email
    await query(
      'INSERT INTO students (id, name, register_number, tutor_id, batch, semester, email, mobile, username, leave_taken) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)',
      [id, name, registerNumber, tutorId, batch, semester, email, mobile, username, 0]
    );
    
    console.log('Student created successfully with ID:', id);
    res.status(201).json({ message: 'Student created successfully', id });
  } catch (error) {
    console.error('Error creating student:', error);
    res.status(500).json({ error: 'Failed to create student', details: error.message });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Leave Portal Backend API - Production', 
    status: 'OK',
    port: port,
    environment: process.env.NODE_ENV || 'production'
  });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Production server is running on port ${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);
});
