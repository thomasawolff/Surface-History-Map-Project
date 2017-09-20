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
create table PROJECT_NUMBERS_MILES_TABLE_2 as
select t.CONT_ID,t.prj_nbr,t.FED_ST_PRJ_NBR,
cast(regexp_replace(nvl(substr(ROUTE_NBR,0,instr(ROUTE_NBR,',')-1),ROUTE_NBR),'[^0-9]','')as int) as sliced,
t.ROUTE_NBR,t.BEG_TERMINI,t.END_TERMINI
from SMGR.T_CONT_PRJ t
where cast(regexp_replace(nvl(substr(ROUTE_NBR,0,instr(ROUTE_NBR,',')-1),ROUTE_NBR),'[^0-9]','')as int) is not null
and trim(t.beg_termini) is not null and substr(t.route_nbr,0,1) not like 'L'
and substr(regexp_replace(ROUTE_NBR,'[0-9,A-Z,a-z]',''),0,1)like '-'
group by t.CONT_ID,t.prj_nbr,t.FED_ST_PRJ_NBR,t.ROUTE_NBR,
t.BEG_TERMINI,t.END_TERMINI
order by t.FED_ST_PRJ_NBR
;
alter table PROJECT_NUMBERS_MILES_TABLE_2 add primary key(CONT_ID,prj_nbr)
;

create table cont_id_prj_table as
select distinct d.cont_id,x.prim_prj_nbr,t.MIX_ID,
t.effdt,t.matl_cd,t.AIR_VOIDS_P,t.VMA_P,t.VFA_P,
t.BULK_SPC_GR_M,t.ASPH_CEM_T,t.OPT_AC_PCT_TOT_WT,t.ESALS_NBR
from SMGR.T_SUPERPAVE t
inner join SMGR.T_CONT_MIX_DSN d
on d.mix_id = t.mix_id
inner join SMGR.T_CONT x
on d.cont_id = x.cont_id
order by 1
;
alter table as_built_mix add primary key(cont_id,prim_prj_nbr,MIX_ID)
;



