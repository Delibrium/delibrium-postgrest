drop trigger if exists update_topic_change_at on aula.topic;
create trigger update_topic_change_at before update on aula.topic for each row execute procedure aula.update_changed_column();
