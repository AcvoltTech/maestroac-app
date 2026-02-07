# MaestroAC - HVAC Training App 🔧

## App de Certificación HVAC Profesional | Nivel 33

**1,124 preguntas** para EPA 608, NATE, OSHA 30 y más.
Por Maestro Mario - ACVOLT Tech School.

---

## Estructura del Proyecto

```
maestroac-app/
├── index.html          ← App principal (HTML + CSS + JS)
├── sw.js               ← Service Worker (PWA offline)
├── manifest.json       ← Configuración PWA
├── netlify.toml        ← Config de Netlify
├── privacy-policy.html ← Política de privacidad
├── logo.png            ← Logo MaestroAC
├── icons/              ← Íconos PWA (72-512px)
├── sql/
│   └── schema.sql      ← Esquema Supabase
└── README.md           ← Este archivo
```

## Plataformas

| Servicio | URL | Estado |
|----------|-----|--------|
| **Web App** | maestromario.com | ✅ Activa |
| **Netlify** | acvolttecniconivel-33.netlify.app | ✅ Deploy |
| **Supabase** | htklsowiyjwsjnacnvnr.supabase.co | ✅ Configurar |
| **Google Play** | com.nivel33.maestroac | 🧪 Prueba |
| **GitHub** | github.com/AcvoltTech/maestroac-app | ⏳ Crear |

## Niveles de Certificación

1. 🔧 **Principiante** - 51 preguntas
2. 📊 **Intermedio** - 150 preguntas  
3. ⚡ **Avanzado** - 173 preguntas
4. 🏆 **Elite** - 250 preguntas
5. 💎 **Platino** - 500 preguntas

---

## PASO 1: Crear Repositorio en GitHub

1. Ve a github.com/organizations/AcvoltTech
2. Click "New repository"
3. Nombre: `maestroac-app`
4. Descripción: `MaestroAC - App de Certificación HVAC Profesional | Nivel 33`
5. Privado: ✅
6. NO inicializar con README (ya lo tenemos)
7. Click "Create repository"

Luego sube los archivos:
```bash
git init
git add .
git commit -m "Initial commit - MaestroAC HVAC Training App"
git branch -M main
git remote add origin https://github.com/AcvoltTech/maestroac-app.git
git push -u origin main
```

## PASO 2: Configurar Supabase

1. Ve a supabase.com/dashboard/project/htklsowiyjwsjnacnvnr
2. Click en "SQL Editor" (ícono de terminal en la barra lateral)
3. Click "New query"
4. Copia y pega TODO el contenido de `sql/schema.sql`
5. Click "Run" (o Ctrl+Enter)
6. Verifica que todas las tablas se crearon en "Table Editor"

### Tablas que se crearán:

| Tabla | Función |
|-------|---------|
| `users` | Técnicos registrados |
| `user_progress` | Progreso por nivel |
| `certificates` | Certificados obtenidos |
| `quiz_attempts` | Historial de intentos |
| `quiz_partial_progress` | Quiz en progreso (reanudar) |
| `unlocked_levels` | Niveles desbloqueados con Matrix |
| `last_activity` | Última actividad del usuario |
| `video_progress` | Videos completados |
| `admins` | Administradores |
| `memberships` | Membresías |

## PASO 3: Obtener API Keys de Supabase

1. En Supabase, ve a Settings → API
2. Copia:
   - **Project URL**: `https://htklsowiyjwsjnacnvnr.supabase.co`
   - **anon public key**: (la key pública)
3. Estas se agregarán al código de la app

---

## Credenciales Actuales (hardcoded - migrar a Supabase)

- **App**: tecnico33 / AcvoltTecniconivel33$
- **Admin**: admin33 / AdminAcvolt33$
- **Membresía**: nivel33 / MaestroMario2026$

---

## Tecnologías

- HTML5 / CSS3 / JavaScript (Vanilla)
- PWA (Service Worker + Manifest)
- Netlify (Hosting)
- Supabase (Base de datos)
- Google Play (Android via TWA/PWA)

## Licencia

Propiedad de ACVOLT Tech School / Nivel 33
© 2026 Mario Flores Corona
