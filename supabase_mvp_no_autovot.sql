-- Impedeix que algú voti a si mateix a l'MVP (també si ho intenta saltant-se l'app)
create or replace function public.mvp_no_autovot()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nom text;
begin
  select nom_real into v_nom
  from public.perfils
  where lower(trim(id_jugador)) = lower(trim(new.id_jugador))
  limit 1;

  if v_nom is not null and lower(trim(v_nom)) = lower(trim(new.nominat)) then
    raise exception 'No et pots votar a tu mateix. Una mica de vergonya!';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_mvp_no_autovot on public.vots_mvp;
create trigger trg_mvp_no_autovot
before insert or update on public.vots_mvp
for each row execute function public.mvp_no_autovot();

-- OPCIONAL: veure els auto-vots que ja hi ha (no s'esborra res)
-- select v.id, v.jornada, v.id_jugador, v.nominat
-- from public.vots_mvp v
-- join public.perfils p
--   on lower(trim(p.id_jugador)) = lower(trim(v.id_jugador))
--  and lower(trim(p.nom_real)) = lower(trim(v.nominat));
