create trigger update_feasible_change_at before update on aula.feasible for each row execute procedure aula.update_changed_column();
