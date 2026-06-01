# 🚀 Empezar un proyecto nuevo desde esta plantilla

Guía rápida para arrancar un proyecto nuevo usando este como base.
(Para detalles completos, mira el [README](README.md).)

---

## 0. Una sola vez (en el repo base)
Marca el repo como plantilla: **Settings → General → casilla "Template repository"** ✅.
Eso habilita el botón **"Use this template"**.

## 1. Crear el repo nuevo
En GitHub: botón verde **"Use this template" → Create a new repository** → ponle nombre → crear.

## 2. Clonar
```powershell
git clone https://github.com/TU-USUARIO/TU-REPO.git
cd TU-REPO
```

## 3. Renombrar la app
```powershell
dart pub global activate rename
dart pub global run rename setAppName  --value "Mi App Nueva"
dart pub global run rename setBundleId --value com.miempresa.miapp
```
Y el esquema del login de Google (lo que `rename` no toca):
```powershell
.\tools\cambiar_esquema_oauth.ps1 -NuevoEsquema com.miempresa.miapp
```

## 4. Crear un proyecto nuevo en Supabase
1. [supabase.com](https://supabase.com) → **New project**.
2. **Project Settings → API**: copia **Project URL** y **Publishable key** (`sb_publishable_...`).
3. **Authentication → Providers → Email**: desactiva *"Confirm email"*.
4. **SQL Editor** → pega y ejecuta:
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

## 5. Poner tus credenciales
1. Copia `lib/supabase_config.example.dart` → `lib/supabase_config.dart`.
2. Pega tu **Project URL** y tu **Publishable key**.

> `supabase_config.dart` está en `.gitignore`: tus claves nunca se suben.

## 6. Instalar y ejecutar
```powershell
flutter pub get
flutter run
```
Si renombraste el bundle ID y algo no compila: `flutter clean` y de nuevo `flutter pub get`.

## 7. (Opcional) Login con Google
- Credenciales OAuth en Google Cloud → pégalas en **Supabase → Authentication → Sign In / Providers → Google**.
- **Supabase → Authentication → URL Configuration → Redirect URLs**: añade `com.miempresa.miapp://login-callback/`.
- Detalles en la sección *"🔑 Login con Google"* del [README](README.md).

---

## ⚡ Resumen exprés
1. **Use this template** → clonar.
2. `rename` + `cambiar_esquema_oauth.ps1`.
3. Nuevo Supabase + SQL + `supabase_config.dart`.
4. `flutter pub get && flutter run`.
