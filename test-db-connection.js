const { Client } = require('pg');

const client = new Client({
  host: 'database-nest-demo.ck3yiciost9r.us-east-1.rds.amazonaws.com',
  port: 5432,
  user: 'postgres',
  password: 'Postgres123',
  database: 'postgres',
  connectionTimeoutMillis: 10000,
  ssl: {
    rejectUnauthorized: false, // AWS RDS 需要 SSL 连接
  },
});

async function testConnection() {
  try {
    console.log('🔄 Connecting to database...');
    await client.connect();
    console.log('✅ Successfully connected to PostgreSQL!');

    const res = await client.query('SELECT version()');
    console.log('📊 PostgreSQL version:', res.rows[0].version);

    await client.end();
    console.log('✅ Connection closed');
  } catch (error) {
    console.error('❌ Connection failed:');
    console.error('Error code:', error.code);
    console.error('Error message:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  }
}

testConnection();
