const SUPABASE_URL = 'https://weicwtambziqoxunajoa.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlaWN3dGFtYnppcW94dW5ham9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzOTQ3MDQsImV4cCI6MjA5MDk3MDcwNH0.hdqrTPuQ6SEDC5wVDdSbSpuI552DFEBnw0TClmlmZE8';

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_KEY);
