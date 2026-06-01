# 📝 Mis Tareas — App de Lista de Tareas con Supabase

App de ejemplo en **Flutter** para aprender a usar **[Supabase](https://supabase.com)**.
Es una lista de tareas (todo list) donde cada usuario inicia sesión con su email y gestiona
únicamente sus propias tareas.

Este proyecto cubre los pilares de Supabase para principiantes:

- 🔐 **Autenticación** — registro e inicio de sesión con email y contraseña.
- 🗄️ **Base de datos (Postgres)** — operaciones CRUD sobre una tabla `todos`.
- 🛡️ **Seguridad por fila (RLS)** — cada usuario solo accede a sus propias filas.
- ⚡ **Realtime** — la lista se actualiza sola cuando cambian los datos.

## 📂 Estructura del proyecto

```
lib/
├── main.dart                    # Inicializa Supabase y decide login o lista (AuthGate)
├── supabase_config.dart         # Tus credenciales (NO se sube a git)
├── supabase_config.example.dart # Plantilla de credenciales (sí se sube)
└── pages/
    ├── login_page.dart          # Registro e inicio de sesión
    └── todos_page.dart          # Lista en tiempo real: añadir, completar, borrar
```

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

## 📦 Dependencias principales
- [`supabase_flutter`](https://pub.dev/packages/supabase_flutter) — cliente oficial de Supabase para Flutter.
