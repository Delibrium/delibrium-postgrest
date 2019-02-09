create trigger update_comment_change_at before update on aula.comment for each row execute procedure aula.update_changed_column();
