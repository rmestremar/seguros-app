-- Migración: perfiles (CEO/Gestor/Mánager/Admin), equipos y validación de ventas
-- Aplicada el 2026-11-24. Transaccional: si algo falla, no se aplica nada.
-- CEO = Comercial Externo por Objetivos.

-- === perfiles: roles nuevos + relación de equipo (primero, las funciones dependen de manager_id) ===
ALTER TABLE perfiles DROP CONSTRAINT IF EXISTS perfiles_rol_check;
ALTER TABLE perfiles ADD CONSTRAINT perfiles_rol_check
  CHECK (rol = ANY (ARRAY['admin','manager','comercial','ceo']));
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS manager_id uuid REFERENCES perfiles(id) ON DELETE SET NULL;

-- === Funciones auxiliares (SECURITY DEFINER: evitan recursión de RLS en perfiles) ===
CREATE OR REPLACE FUNCTION public.mi_rol() RETURNS text
  LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public AS
$$ SELECT rol FROM perfiles WHERE id = auth.uid() $$;

CREATE OR REPLACE FUNCTION public.es_mi_subordinado(uid uuid) RETURNS boolean
  LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public AS
$$ SELECT EXISTS (SELECT 1 FROM perfiles WHERE id = uid AND manager_id = auth.uid()) $$;

GRANT EXECUTE ON FUNCTION public.mi_rol() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.es_mi_subordinado(uuid) TO authenticated, anon;

-- === Objetivos por perfil (valores por defecto del rol) ===
CREATE TABLE IF NOT EXISTS roles_objetivos (
  rol         text PRIMARY KEY CHECK (rol = ANY (ARRAY['admin','manager','comercial','ceo'])),
  meta_valor  numeric(10,2) NOT NULL DEFAULT 0,
  meta_puntos numeric(10,2) NOT NULL DEFAULT 0
);
INSERT INTO roles_objetivos (rol, meta_valor, meta_puntos) VALUES
  ('comercial', 5700, 4000),
  ('ceo',       3200, 3200),
  ('manager',      0,    0),
  ('admin',        0,    0)
ON CONFLICT (rol) DO NOTHING;
ALTER TABLE roles_objetivos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ver objetivos rol" ON roles_objetivos FOR SELECT USING (true);
CREATE POLICY "admin edita objetivos rol" ON roles_objetivos FOR ALL
  USING (public.mi_rol() = 'admin') WITH CHECK (public.mi_rol() = 'admin');

-- === ventas: estado de validación ===
-- Default 'validada': las ventas existentes y las creadas por la app antigua quedan validadas.
-- La app nueva marca 'pendiente' explícitamente cuando un comercial/CEO con mánager registra una venta.
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS estado text NOT NULL DEFAULT 'validada'
  CHECK (estado = ANY (ARRAY['pendiente','validada','rechazada']));
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS validada_por uuid REFERENCES perfiles(id) ON DELETE SET NULL;
ALTER TABLE ventas ADD COLUMN IF NOT EXISTS validada_en timestamptz;

-- === RLS perfiles ===
DROP POLICY IF EXISTS "editar propio perfil" ON perfiles;  -- objetivos ahora los gestiona el admin
CREATE POLICY "admin gestiona perfiles" ON perfiles FOR ALL
  USING (public.mi_rol() = 'admin') WITH CHECK (public.mi_rol() = 'admin');
CREATE POLICY "manager ve su equipo" ON perfiles FOR SELECT
  USING (manager_id = auth.uid());

-- === RLS ventas (manager sobre su equipo) ===
CREATE POLICY "manager ve ventas equipo" ON ventas FOR SELECT
  USING (public.es_mi_subordinado(usuario_id));
CREATE POLICY "manager edita ventas equipo" ON ventas FOR UPDATE
  USING (public.es_mi_subordinado(usuario_id)) WITH CHECK (public.es_mi_subordinado(usuario_id));
