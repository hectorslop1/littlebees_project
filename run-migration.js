const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const client = new Client({
  host: '216.250.125.239',
  port: 5437,
  user: 'littlebees_user',
  password: 'LittleBees2024!Secure',
  database: 'littlebees_db',
  ssl: false,
});

async function runMigration() {
  try {
    console.log('🔌 Conectando a la base de datos...');
    await client.connect();
    console.log('✓ Conectado exitosamente\n');

    const sqlFile = path.join(__dirname, 'add-phase3-fields.sql');
    const sql = fs.readFileSync(sqlFile, 'utf8');

    console.log('📝 Ejecutando migración SQL...');
    console.log('━'.repeat(50));
    
    await client.query(sql);
    
    console.log('✓ Migración ejecutada exitosamente\n');

    // Verificar que los campos se agregaron
    console.log('🔍 Verificando cambios...');
    const checkColumns = await client.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'attendance_records' 
      AND column_name IN ('check_in_photo_url', 'check_out_photo_url')
      ORDER BY column_name;
    `);
    
    console.log('✓ Campos agregados a attendance_records:');
    checkColumns.rows.forEach(row => {
      console.log(`  - ${row.column_name}: ${row.data_type}`);
    });

    const checkTable = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_name = 'day_schedule_templates';
    `);
    
    if (checkTable.rows.length > 0) {
      console.log('✓ Tabla day_schedule_templates creada exitosamente');
    }

    console.log('\n🎉 Migración Fase 3 completada exitosamente');

  } catch (error) {
    console.error('❌ Error ejecutando migración:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

runMigration();
