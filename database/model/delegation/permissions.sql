alter table aula.delegation enable row level security;

-- Delegation
drop policy if exists school_select_delegation on aula.delegation;
create policy school_select_delegation on aula.delegation for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_delegation on aula.delegation;
create policy school_create_delegation on aula.delegation for insert with check (aula.is_admin(school_id) or (aula.is_owner(created_by) and (aula.from_school(school_id)) and (from_user = request.user_id()) and (to_user != request.user_id())));

drop policy if exists school_update_delegation on aula.delegation;
create policy school_update_delegation on aula.delegation
  for update
    using
    (aula.is_admin(school_id) or
      (aula.is_owner(created_by)
      and (aula.from_school(school_id))
      and (from_user = request.user_id())
      and (to_user != request.user_id())))
    with check
    (aula.is_admin(school_id)
      or (aula.is_owner(created_by)
        and (aula.from_school(school_id))
        and (from_user = request.user_id())
        and (to_user != request.user_id())));

drop policy if exists school_delete_delegation on aula.delegation;
create policy school_delete_delegation on aula.delegation
  for delete
    using
    (aula.is_admin(school_id)
      or (from_user = request.user_id())
      and (aula.is_owner(created_by)));


