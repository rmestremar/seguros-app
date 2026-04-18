-- Añadir columnas de objetivo mensual a la tabla perfiles existente
ALTER TABLE perfiles
    ADD COLUMN IF NOT EXISTS meta_valor  NUMERIC(10,2) DEFAULT 0,
    ADD COLUMN IF NOT EXISTS meta_puntos NUMERIC(10,2) DEFAULT 0;
