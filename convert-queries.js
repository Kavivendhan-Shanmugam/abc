import fs from 'fs';
import path from 'path';

// Convert MySQL ? placeholders to PostgreSQL $1, $2, etc.
function convertQueryPlaceholders(content) {
  let paramCounter = 0;
  
  return content.replace(/\?/g, () => {
    paramCounter++;
    return `$${paramCounter}`;
  }).replace(/'/g, (match, offset, string) => {
    // Reset counter for each new query
    if (string.slice(Math.max(0, offset - 10), offset).includes('query(') || 
        string.slice(Math.max(0, offset - 10), offset).includes('await query(')) {
      paramCounter = 0;
    }
    return match;
  });
}

// Read the server file
const serverPath = path.join(process.cwd(), 'backend', 'server.js');
let serverContent = fs.readFileSync(serverPath, 'utf8');

console.log('Converting MySQL queries to PostgreSQL format...');

// Convert specific MySQL functions to PostgreSQL
serverContent = serverContent.replace(/NOW\(\)/g, 'CURRENT_TIMESTAMP');
serverContent = serverContent.replace(/CURDATE\(\)/g, 'CURRENT_DATE');
serverContent = serverContent.replace(/DATE_ADD\(([^,]+),\s*INTERVAL\s+(\d+)\s+DAY\)/g, '($1 + INTERVAL \'$2 days\')');

// Fix the test-db endpoint query
serverContent = serverContent.replace(
  /const \[result\] = await query\('SELECT COUNT\(\*\) as count FROM users'\);/,
  'const result = await query(\'SELECT COUNT(*) as count FROM users\');'
);

// Fix array destructuring for PostgreSQL results
serverContent = serverContent.replace(/const \[([^\]]+)\] = await query\(/g, 'const result = await query(');
serverContent = serverContent.replace(/if \(!([^)]+)\) {/g, (match, varName) => {
  if (varName.includes('result')) {
    return `if (!result.rows[0]) {\n    const ${varName} = result.rows[0];`;
  }
  return match;
});

// Convert ? placeholders to $1, $2, etc. in a more sophisticated way
const lines = serverContent.split('\n');
const convertedLines = lines.map(line => {
  if (line.includes('await query(') || line.includes('query(')) {
    let paramCounter = 1;
    return line.replace(/\?/g, () => `$${paramCounter++}`);
  }
  return line;
});

serverContent = convertedLines.join('\n');

// Write the converted file
fs.writeFileSync(serverPath, serverContent);

console.log('✅ Conversion completed! Server.js has been updated for PostgreSQL.');
console.log('⚠️  Note: Some complex queries may need manual adjustment.');

export {};
