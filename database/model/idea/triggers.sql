drop trigger if exists update_idea_change_at on aula.idea;
create trigger update_idea_change_at before update on aula.idea for each row execute procedure aula.update_changed_column();
