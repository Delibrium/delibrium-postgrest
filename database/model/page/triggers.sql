drop trigger if exists update_page_change_at on aula.page;
create trigger update_page_change_at before update on aula.page for each row execute procedure aula.update_changed_column();
