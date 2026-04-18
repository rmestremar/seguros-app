-- Tabla para guardar el histórico de ratios (valor % y puntos %) por seguro
-- Cada vez que el usuario modifica y aplica ratios se inserta una nueva fila
-- con la fecha desde la que son válidos.
-- Para obtener el ratio activo en una fecha X:
--   SELECT * FROM seguros_ratios
--   WHERE usuario_id = ? AND clave = ? AND COALESCE(nivel,'') = COALESCE(?,'')
--         AND vigente_desde <= 'X'
--   ORDER BY vigente_desde DESC LIMIT 1

CREATE TABLE IF NOT EXISTS seguros_ratios (
    id            BIGSERIAL PRIMARY KEY,
    usuario_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    clave         TEXT        NOT NULL,
    nombre        TEXT        NOT NULL,
    categoria     TEXT        NOT NULL,
    tiene_niveles BOOLEAN     NOT NULL DEFAULT FALSE,
    nivel         TEXT        DEFAULT NULL,   -- NULL para tipos simples
    valor         NUMERIC(10,4) NOT NULL DEFAULT 0,
    puntos        NUMERIC(10,4) NOT NULL DEFAULT 0,
    vigente_desde DATE        NOT NULL DEFAULT CURRENT_DATE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_seguros_ratios_lookup
    ON seguros_ratios (usuario_id, clave, nivel, vigente_desde DESC);

ALTER TABLE seguros_ratios ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usuarios_propios_ratios" ON seguros_ratios
    FOR ALL USING (auth.uid() = usuario_id);
