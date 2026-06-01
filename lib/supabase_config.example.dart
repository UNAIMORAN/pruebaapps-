// PLANTILLA de credenciales de Supabase.
//
// Este archivo SÍ se sube a git como ejemplo. El archivo real con tus claves
// (lib/supabase_config.dart) está en .gitignore y NO se sube.
//
// Para configurar el proyecto tras clonarlo:
//   1. Copia este archivo y renómbralo a "supabase_config.dart".
//   2. Entra a https://supabase.com -> tu proyecto -> Project Settings -> API.
//   3. Pega tu Project URL y tu Publishable key (sb_publishable_...) abajo.
//
// Importante: usa SIEMPRE la clave pública (sb_publishable_...), nunca la
// secreta (sb_secret_...), en una app cliente.
const String supabaseUrl = 'https://TU-PROYECTO.supabase.co';
const String supabaseAnonKey = 'TU-CLAVE-sb_publishable_...';
