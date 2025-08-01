# PowerShell script to help set up the migration
Write-Host "=== Neon Migration Setup ===" -ForegroundColor Green

# Check if .env exists
if (!(Test-Path ".env")) {
    Write-Host "Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
}

Write-Host ""
Write-Host "Please follow these steps:" -ForegroundColor Cyan
Write-Host "1. Go to https://neon.tech and create a free account" -ForegroundColor White
Write-Host "2. Create a new project called 'leave-portal'" -ForegroundColor White
Write-Host "3. Copy your connection string (starts with postgresql://...)" -ForegroundColor White
Write-Host ""

# Prompt for connection string
$connectionString = Read-Host "Paste your Neon connection string here"

if ($connectionString) {
    # Update .env file
    $envContent = Get-Content ".env" -Raw
    $envContent = $envContent -replace "MYSQL_URL=.*", "DATABASE_URL=$connectionString"
    $envContent = $envContent -replace "# For Railway deployment, use this:.*", "# Neon PostgreSQL Database"
    Set-Content ".env" $envContent
    Write-Host "✅ Updated .env file with Neon connection string" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Set your MySQL password for migration:" -ForegroundColor White
Write-Host "   `$env:OLD_DB_PASSWORD='your_mysql_password'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Run the schema setup:" -ForegroundColor White
Write-Host "   - Copy contents of neon-migration/schema-postgres.sql" -ForegroundColor Gray
Write-Host "   - Run it in your Neon database console" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Run data migration:" -ForegroundColor White
Write-Host "   node neon-migration/migrate-data.js" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Test your setup:" -ForegroundColor White
Write-Host "   npm run server" -ForegroundColor Gray
Write-Host ""

Write-Host "📖 See MIGRATION_GUIDE.md for detailed instructions" -ForegroundColor Yellow
