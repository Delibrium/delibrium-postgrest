create trigger update_idea_like_change_at before update on aula.idea_like for each row execute procedure aula.update_changed_column();
