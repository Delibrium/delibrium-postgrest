create trigger update_user_change_at before update on aula.users for each row execute procedure aula.update_changed_column();
