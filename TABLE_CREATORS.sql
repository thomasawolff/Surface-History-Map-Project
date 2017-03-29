
create table corridors_table as
select (t.nrlg_dept_route||t.nrlg_dept_roadbed) as Corridor_RB,t.nrlg_dept_route,
cast(regexp_replace(nvl(substr(t.nrlg_dept_route,0,
instr(t.nrlg_dept_route,'')-1),t.nrlg_dept_route),'[^0-9]','')as int) as sliced
from TIS.TIS_NEW_ROADLOG t
where t.nrlg_sys_desc not like 'OFF'
and t.nrlg_sys_desc not like 'CLO'
and t.nrlg_sys_desc not like 'OUT'
and t.nrlg_dept_route not like 'C000090'
and t.nrlg_dept_route not like 'C000094'
and t.nrlg_dept_route not like 'C000015'
and t.nrlg_dept_route not like 'C000315'
and t.nrlg_dept_route not like 'C000115'
group by t.nrlg_dept_route,(t.nrlg_dept_route||t.nrlg_dept_roadbed)
order by (t.nrlg_dept_route||t.nrlg_dept_roadbed)
;
alter table corridors_table add primary key(sliced)
;
create table project_numbers_miles_table as
select t.CONT_ID,t.FED_ST_PRJ_NBR,
cast(regexp_replace(nvl(substr(ROUTE_NBR,0,instr(ROUTE_NBR,',')-1),ROUTE_NBR),'[^0-9]','')as int) as sliced,
t.ROUTE_NBR,t.BEG_TERMINI,t.END_TERMINI
from SMGR.T_CONT t
where cast(regexp_replace(nvl(substr(ROUTE_NBR,0,instr(ROUTE_NBR,',')-1),ROUTE_NBR),'[^0-9]','')as int) is not null
and trim(t.beg_termini) is not null and substr(t.route_nbr,0,1) not like 'L'
and substr(regexp_replace(ROUTE_NBR,'[0-9,A-Z,a-z]',''),0,1)like '-'
group by t.CONT_ID,t.FED_ST_PRJ_NBR,t.ROUTE_NBR,
t.BEG_TERMINI,t.END_TERMINI
order by t.FED_ST_PRJ_NBR
;
alter table project_numbers_miles_table add primary key(cont_id)
;
create table as_built_table as
select t.mix_id from SMGR.T_CONT_MIX_DSN t
group by t.mix_id
;
alter table as_built_table add primary key(mix_id)
;
create table cont_ID_miles_table as 
select t.CONT_ID from MILES_TO_FLOAT t
group by t.CONT_ID
;
alter table cont_id_miles_table add primary key(cont_id)
