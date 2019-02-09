create trigger update_delegation_change_at before update on aula.delegation for each row execute procedure aula.update_changed_column();
