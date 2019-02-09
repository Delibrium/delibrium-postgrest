create trigger update_idea_space_change_at before update on aula.idea_space for each row execute procedure aula.update_changed_column();
