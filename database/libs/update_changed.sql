CREATE OR REPLACE FUNCTION aula.update_changed_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.changed_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';
