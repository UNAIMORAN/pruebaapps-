# 📝 Mis Tareas — App de Lista de Tareas con Supabase

App de ejemplo en **Flutter** para aprender a usar **[Supabase](https://supabase.com)**.
Es una lista de tareas (todo list) donde cada usuario inicia sesión con su email y gestiona
únicamente sus propias tareas.

Este proyecto cubre los pilares de Supabase para principiantes:

- 🔐 **Autenticación** — registro e inicio de sesión con email y contraseña, y login con **Google** (OAuth).
- 🗄️ **Base de datos (Postgres)** — operaciones CRUD sobre una tabla `todos`.
- 🛡️ **Seguridad por fila (RLS)** — cada usuario solo accede a sus propias filas.
- ⚡ **Realtime** — la lista se actualiza sola cuando cambian los datos.

## 📂 Estructura del proyecto

```
lib/
├── main.dart                    # Inicializa Supabase y decide login o lista (AuthGate)
├── supabase_config.dart         # Tus credenciales (NO se sube a git)
├── supabase_config.example.dart # Plantilla de credenciales (sí se sube)
├── scheme_registrar.dart        # Registro del esquema de URL (login Google en escritorio)
├── scheme_registrar_io.dart     # └ versión móvil/escritorio (solo actúa en Windows)
├── scheme_registrar_stub.dart   # └ versión web (no hace nada)
└── pages/
    ├── login_page.dart          # Registro e inicio de sesión (email + Google)
    └── todos_page.dart          # Lista en tiempo real: añadir, completar, borrar
```

## 🧩 Usar este proyecto como plantilla para uno nuevo

Este repo está marcado como **template repository** en GitHub, así que puedes crear
proyectos nuevos a partir de él en segundos.

1. **Crear el repo nuevo**: en GitHub, pulsa **"Use this template" → Create a new repository**.
   Dale un nombre y créalo.
2. **Clónalo** en tu equipo y entra en la carpeta:
   ```bash
   git clone https://github.com/TU-USUARIO/TU-REPO.git
   cd TU-REPO
   ```
3. **Renombrar la app** (nombre, package/bundle ID y esquema de URL). Usamos la
   herramienta estándar [`rename`](https://pub.dev/packages/rename) para el grueso y
   un script propio para el esquema de Google:
   ```bash
   dart pub global activate rename
   dart pub global run rename setAppName  --value "Mi App Nueva"
   dart pub global run rename setBundleId --value com.miempresa.miapp
   ```
   ```powershell
   # En Windows (PowerShell): actualiza el esquema OAuth para que coincida con el bundle ID
   ./tools/cambiar_esquema_oauth.ps1 -NuevoEsquema com.miempresa.miapp
   ```
4. **Nuevo proyecto de Supabase**: sigue los pasos de *"Cómo ejecutarlo"* de abajo
   (crear proyecto, ejecutar el SQL, copiar `supabase_config.example.dart` a
   `supabase_config.dart` con tus nuevas credenciales).
5. **Instalar y ejecutar**:
   ```bash
   flutter pub get
   flutter run
   ```

> 💡 Si vas a usar login con Google, recuerda actualizar también la *Redirect URL* en
> Supabase al nuevo esquema (`com.miempresa.miapp://login-callback/`).

## 🚀 Cómo ejecutarlo

### 1. Requisitos
- [Flutter](https://docs.flutter.dev/get-started/install) instalado.
- Una cuenta gratuita en [supabase.com](https://supabase.com).

### 2. Configurar Supabase
1. Crea un proyecto nuevo en [supabase.com](https://supabase.com).
2. En **Project Settings → API**, copia tu **Project URL** y tu **Publishable key** (`sb_publishable_...`).
3. En **Authentication → Providers → Email**, desactiva *"Confirm email"* para registrarte sin confirmar el correo (solo para desarrollo).
4. En el **SQL Editor**, ejecuta este script para crear la tabla y la seguridad:

   ```sql
   create table public.todos (
     id          bigint generated always as identity primary key,
     user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
     task        text not null,
     is_complete boolean not null default false,
     created_at  timestamptz not null default now()
   );

   alter table public.todos enable row level security;

   create policy "ver"        on public.todos for select using (auth.uid() = user_id);
   create policy "crear"      on public.todos for insert with check (auth.uid() = user_id);
   create policy "actualizar" on public.todos for update using (auth.uid() = user_id);
   create policy "borrar"     on public.todos for delete using (auth.uid() = user_id);
   ```
5. (Opcional, para Realtime) En **Database → Replication** activa la tabla `todos`.

### 3. Configurar las credenciales en la app
1. Copia `lib/supabase_config.example.dart` y renómbralo a `lib/supabase_config.dart`.
2. Pega tu **Project URL** y tu **Publishable key**.

> ⚠️ Usa siempre la clave pública (`sb_publishable_...`), **nunca** la secreta (`sb_secret_...`),
> en una app cliente.

### 4. Instalar dependencias y ejecutar
```bash
flutter pub get
flutter run
```

## 🧪 Cómo probarlo
1. Al arrancar, verás la pantalla de login.
2. Regístrate con un email → entras directo a la lista vacía.
3. Añade una tarea → aparece al instante.
4. Márcala como completada o deslízala para borrarla.
5. En Supabase → **Table Editor → todos** verás tus filas con tu `user_id`.

## 🔑 Login con Google (opcional)

El login con email funciona sin más configuración. Si quieres además el botón
**"Continuar con Google"**, hay que configurar OAuth. **Funciona en web y Android**;
en Windows/escritorio el código está listo pero requiere ajustes adicionales de
Google Cloud (ver nota al final).

1. **Google Cloud Console** → crea un *ID de cliente de OAuth* de tipo **Aplicación web**.
   En *URIs de redireccionamiento autorizados* añade la callback de tu proyecto:
   ```
   https://TU-PROYECTO.supabase.co/auth/v1/callback
   ```
   Copia el **Client ID** y el **Client Secret**.

2. **Supabase → Authentication → Sign In / Providers → Google**: actívalo y pega
   el Client ID y el Client Secret.

3. **Supabase → Authentication → URL Configuration → Redirect URLs**: añade el
   esquema propio de la app (para móvil y escritorio):
   ```
   com.example.pruebaapps://login-callback/
   com.example.pruebaapps://login-callback/**
   ```

4. La configuración por plataforma ya está hecha en el repo:
   - **Android**: `intent-filter` en `android/app/src/main/AndroidManifest.xml`.
   - **iOS**: `CFBundleURLTypes` en `ios/Runner/Info.plist`.
   - **Windows**: registro del esquema (`scheme_registrar_io.dart` con `win32_registry`)
     e instancia única en `windows/runner/main.cpp`.

> **Nota sobre Windows escritorio:** la app recibe correctamente el *deep link* de
> vuelta, pero el flujo completo depende de que la configuración de Google Cloud
> redirija bien al esquema. Si en escritorio el navegador no vuelve a la app tras
> el login, revisa que el Client ID/Secret estén guardados en Supabase y que la URI
> de redirección autorizada sea exactamente la callback de tu proyecto.

## 📦 Dependencias principales
- [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) — cliente oficial de Supabase para Flutter.
- [`win32_registry`](https://pub.dev/packages/win32_registry) — solo en Windows: registra el esquema de URL para el login con Google.
