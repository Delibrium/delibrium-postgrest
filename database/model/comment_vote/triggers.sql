drop trigger if exists update_comment_vote_change_at on aula.comment_vote;
create trigger update_comment_vote_change_at before update on aula.comment_vote for each row execute procedure aula.update_changed_column();
