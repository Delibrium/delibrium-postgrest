CREATE OR REPLACE FUNCTION aula.update_delegation()
RETURNS TRIGGER AS $$
declare
  idearec record;
  usr record;
BEGIN
  delete from aula.idea_vote where user_id = request.user_id() or user_id in (select delegation.delegated(request.user_id(), idea));
  for idearec in select idea,val from aula.idea_vote where user_id = NEW.to_user
    loop
     insert into aula.idea_vote (school_id, idea, user_id, val) values (request.school_id(), idearec.idea, request.user_id(), idearec.val);
     for usr in select delegation.delegated(request.user_id(), idearec.idea)
      loop
        insert into aula.idea_vote (school_id, idea, user_id, val) values (request.school_id(), idearec.idea, usr.id, idearec.val);
      end loop;
    end loop;
  RETURN NEW;
END;
$$ language 'plpgsql';

drop trigger if exists update_delegation_change_at on aula.delegation;
create trigger update_delegation_change_at before
  update of to_user on aula.delegation for each row execute procedure
    aula.update_delegation();

drop trigger if exists update_delegation_change_delegate on aula.delegation;
create trigger update_delegation_change_delegate before
  update on aula.delegation for each row execute procedure
    aula.update_changed_column();
