create trigger update_school_change_at before update on aula.school for each row execute procedure aula.update_changed_column();
