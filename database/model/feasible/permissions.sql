alter table aula.feasible enable row level security;

-- Idea Feasibility
drop policy if exists school_select_feasible on aula.feasible;
create policy school_select_feasible on aula.feasible for select using (aula.is_admin(school_id) or (aula.from_school(school_id)));

drop policy if exists school_create_feasible on aula.feasible;
create policy school_create_feasible on aula.feasible for insert with check (aula.is_admin(school_id) or aula.is_principal(school_id));

drop policy if exists school_update_feasible on aula.feasible;
create policy school_update_feasible on aula.feasible for update using (aula.is_admin(school_id) or aula.is_principal(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id))) with check (aula.is_admin(school_id) or (aula.is_owner(created_by)) or (aula.is_moderator(school_id)));

drop policy if exists school_delete_feasible on aula.feasible;
create policy school_delete_feasible on aula.feasible for delete using (aula.is_admin(school_id) or aula.is_principal(school_id));

