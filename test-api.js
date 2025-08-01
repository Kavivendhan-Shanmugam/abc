// Test API endpoints
import fetch from 'node-fetch';

const API_BASE = 'http://localhost:3002';

async function testLogin() {
  try {
    console.log('Testing login...');
    const response = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ identifier: 'admin', password: 'password123' })
    });
    
    const data = await response.json();
    console.log('Login response:', data);
    
    if (data.token) {
      console.log('✅ Login successful!');
      return data.token;
    } else {
      console.log('❌ Login failed');
      return null;
    }
  } catch (error) {
    console.error('Login error:', error.message);
    return null;
  }
}

async function testProfile(token) {
  try {
    console.log('\nTesting profile...');
    const response = await fetch(`${API_BASE}/profile`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const data = await response.json();
    console.log('Profile response:', data);
    console.log('✅ Profile fetch successful!');
  } catch (error) {
    console.error('Profile error:', error.message);
  }
}

async function testStudents(token) {
  try {
    console.log('\nTesting students...');
    const response = await fetch(`${API_BASE}/students`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const data = await response.json();
    console.log('Students count:', data.length);
    console.log('✅ Students fetch successful!');
  } catch (error) {
    console.error('Students error:', error.message);
  }
}

async function runTests() {
  const token = await testLogin();
  if (token) {
    await testProfile(token);
    await testStudents(token);
  }
}

runTests();
