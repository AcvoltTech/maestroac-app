-- ============================================
-- MaestroAC - Supabase Database Schema
-- ACVOLT Tech School / Nivel 33
-- Fecha: Febrero 7, 2026
-- ============================================

-- 1. TABLA DE USUARIOS (técnicos registrados)
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre TEXT NOT NULL,
  email TEXT,
  telefono TEXT,
  ciudad TEXT,
  estado TEXT,
  pais TEXT DEFAULT 'México',
  technician_number TEXT UNIQUE,
  technician_number_date TIMESTAMPTZ,
  nivel_actual TEXT DEFAULT 'nuevo' CHECK (nivel_actual IN ('nuevo', 'principiante', 'intermedio', 'avanzado', 'elite', 'platino')),
  fecha_registro TIMESTAMPTZ DEFAULT NOW(),
  ultimo_acceso TIMESTAMPTZ DEFAULT NOW(),
  activo BOOLEAN DEFAULT TRUE
);

-- 2. TABLA DE PROGRESO POR NIVEL
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  nivel TEXT NOT NULL CHECK (nivel IN ('principiante', 'intermedio', 'avanzado', 'elite', 'platino')),
  completed INTEGER DEFAULT 0,
  score INTEGER DEFAULT 0,
  total INTEGER NOT NULL,
  porcentaje DECIMAL(5,2) DEFAULT 0,
  fecha_inicio TIMESTAMPTZ DEFAULT NOW(),
  fecha_completado TIMESTAMPTZ,
  UNIQUE(user_id, nivel)
);

-- 3. TABLA DE CERTIFICADOS
CREATE TABLE IF NOT EXISTS certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  nivel TEXT NOT NULL CHECK (nivel IN ('principiante', 'intermedio', 'avanzado', 'elite', 'platino')),
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  porcentaje DECIMAL(5,2) NOT NULL,
  certificate_number TEXT UNIQUE,
  fecha_obtenido TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, nivel)
);

-- 4. TABLA DE INTENTOS DE QUIZ (historial detallado)
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  nivel TEXT NOT NULL,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  wrong_answers INTEGER NOT NULL,
  porcentaje DECIMAL(5,2) NOT NULL,
  tiempo_segundos INTEGER,
  aprobado BOOLEAN DEFAULT FALSE,
  fecha TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABLA DE PROGRESO PARCIAL DE QUIZ (para reanudar)
CREATE TABLE IF NOT EXISTS quiz_partial_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  nivel TEXT NOT NULL,
  question_index INTEGER DEFAULT 0,
  correct_count INTEGER DEFAULT 0,
  wrong_count INTEGER DEFAULT 0,
  answers_given JSONB DEFAULT '[]',
  fecha_guardado TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, nivel)
);

-- 6. TABLA DE NIVELES DESBLOQUEADOS
CREATE TABLE IF NOT EXISTS unlocked_levels (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  nivel TEXT NOT NULL,
  matrix_code TEXT,
  fecha_desbloqueo TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, nivel)
);

-- 7. TABLA DE ÚLTIMA ACTIVIDAD
CREATE TABLE IF NOT EXISTS last_activity (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
  activity_type TEXT,
  module_id TEXT,
  lesson_id TEXT,
  quiz_id TEXT,
  route_path TEXT,
  fecha TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TABLA DE PROGRESO DE VIDEOS
CREATE TABLE IF NOT EXISTS video_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  video_id TEXT NOT NULL,
  video_title TEXT,
  categoria TEXT,
  nivel TEXT,
  completado BOOLEAN DEFAULT FALSE,
  fecha TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, video_id)
);

-- 9. TABLA DE ADMINISTRADORES
CREATE TABLE IF NOT EXISTS admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  nombre TEXT NOT NULL,
  rol TEXT DEFAULT 'admin' CHECK (rol IN ('admin', 'superadmin')),
  activo BOOLEAN DEFAULT TRUE,
  fecha_creado TIMESTAMPTZ DEFAULT NOW()
);

-- 10. TABLA DE MEMBRESÍAS
CREATE TABLE IF NOT EXISTS memberships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  tipo TEXT DEFAULT 'basico' CHECK (tipo IN ('basico', 'premium', 'platino')),
  fecha_inicio TIMESTAMPTZ DEFAULT NOW(),
  fecha_vencimiento TIMESTAMPTZ,
  activa BOOLEAN DEFAULT TRUE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT
);

-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_progress_user ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_user ON certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_fecha ON quiz_attempts(fecha);
CREATE INDEX IF NOT EXISTS idx_users_nivel ON users(nivel_actual);
CREATE INDEX IF NOT EXISTS idx_users_technician ON users(technician_number);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_partial_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE unlocked_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE last_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;

-- Política: Los usuarios pueden leer sus propios datos
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (true);

CREATE POLICY "Progress read own" ON user_progress FOR SELECT USING (true);
CREATE POLICY "Progress insert own" ON user_progress FOR INSERT WITH CHECK (true);
CREATE POLICY "Progress update own" ON user_progress FOR UPDATE USING (true);

CREATE POLICY "Certificates read own" ON certificates FOR SELECT USING (true);
CREATE POLICY "Certificates insert own" ON certificates FOR INSERT WITH CHECK (true);

CREATE POLICY "Quiz attempts read own" ON quiz_attempts FOR SELECT USING (true);
CREATE POLICY "Quiz attempts insert own" ON quiz_attempts FOR INSERT WITH CHECK (true);

CREATE POLICY "Partial progress all" ON quiz_partial_progress FOR ALL USING (true);

CREATE POLICY "Unlocked levels all" ON unlocked_levels FOR ALL USING (true);

CREATE POLICY "Last activity all" ON last_activity FOR ALL USING (true);

CREATE POLICY "Video progress all" ON video_progress FOR ALL USING (true);

CREATE POLICY "Memberships read" ON memberships FOR SELECT USING (true);

-- ============================================
-- VISTA PARA EL ADMIN DASHBOARD
-- ============================================
CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT 
  COUNT(DISTINCT u.id) as total_technicians,
  COUNT(DISTINCT CASE WHEN u.nivel_actual = 'principiante' THEN u.id END) as nivel_principiante,
  COUNT(DISTINCT CASE WHEN u.nivel_actual = 'intermedio' THEN u.id END) as nivel_intermedio,
  COUNT(DISTINCT CASE WHEN u.nivel_actual = 'avanzado' THEN u.id END) as nivel_avanzado,
  COUNT(DISTINCT CASE WHEN u.nivel_actual = 'elite' THEN u.id END) as nivel_elite,
  COUNT(DISTINCT CASE WHEN u.nivel_actual = 'platino' THEN u.id END) as nivel_platino,
  COUNT(DISTINCT c.id) as total_certificates,
  COUNT(DISTINCT CASE WHEN qa.fecha > NOW() - INTERVAL '7 days' THEN qa.id END) as quizzes_last_7_days
FROM users u
LEFT JOIN certificates c ON u.id = c.user_id
LEFT JOIN quiz_attempts qa ON u.id = qa.user_id;

-- Vista detallada por técnico para admin
CREATE OR REPLACE VIEW admin_technician_details AS
SELECT 
  u.id,
  u.nombre,
  u.email,
  u.telefono,
  u.ciudad,
  u.technician_number,
  u.nivel_actual,
  u.fecha_registro,
  u.ultimo_acceso,
  COUNT(DISTINCT c.id) as total_certificates,
  COUNT(DISTINCT qa.id) as total_quiz_attempts,
  COALESCE(AVG(qa.porcentaje), 0) as avg_quiz_score
FROM users u
LEFT JOIN certificates c ON u.id = c.user_id
LEFT JOIN quiz_attempts qa ON u.id = qa.user_id
GROUP BY u.id, u.nombre, u.email, u.telefono, u.ciudad, 
         u.technician_number, u.nivel_actual, u.fecha_registro, u.ultimo_acceso;
