create trigger update_user_group_change_at before update on aula.user_group for each row execute procedure aula.update_changed_column();
