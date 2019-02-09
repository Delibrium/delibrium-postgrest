create trigger update_category_change_at before update on aula.category for each row execute procedure aula.update_changed_column();
