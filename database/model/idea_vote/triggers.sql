drop trigger if exists update_idea_vote_change_at on aula.idea_vote;
create trigger update_idea_vote_change_at before update on aula.idea_vote for each row execute procedure aula.update_changed_column();

drop trigger if exists delete_idea_vote on aula.idea_vote;
--create trigger delete_idea_vote before
--  delete on aula.idea_vote for each row execute procedure
--    delegation.delete_vote();


