create or replace view surface_history_cleaner2 as
select DISTINCT 
--t.qp_mdt_uid,t.qp_mdt_fk,
cast(substr(x.actl_dt,1,4)as number) as Year_,
case when t.qp_route like 'I-90' then 'C000090E'
     when t.qp_route like 'I-15' then 'C000015N'
     when t.qp_route like 'I-94' then 'C000094E'
       else r.corridor_rb
            end as CORRIDOR,
c.prim_prj_nbr as projectnumber,
t.qp_projectnumber as Project_Name,
t.qp_projectname as Description_,
c.mix_id as Mix_ID,
y.qc_contractnumber as Contract_ID,
case when p.BEG_TERMINI like '%RP%' or p.BEG_TERMINI like '%+%'
  then cast(regexp_replace(p.BEG_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else p.BEG_TERMINI
      end as PROJECT_START,
case when p.END_TERMINI like '%RP%' or p.END_TERMINI like '%+%'
  then cast(regexp_replace(p.END_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else p.END_TERMINI
      end as PROJECT_END,
cast(t.qp_controlnumber as varchar(4)) as Control_Number,
c.esals_nbr as ESALS,
c.opt_ac_pct_tot_wt as As_Built_AC,
case when c.matl_cd = '401.03.01.01' then '3/4"'
  when c.matl_cd = '401.03.01.02' then '1/2"'
  when c.matl_cd = '401.03.01.06' then '3/8"' 
    else null end as As_Built_Aggregate_Size,
c.air_voids_p as As_Built_Hamburg_Voids,
c.vma_p as As_Built_VMA,
c.vfa_p as As_Built_VFA,
case when trim(c.BULK_SPC_GR_M) is not null then
  case when c.BULK_SPC_GR_M > 120 and c.BULK_SPC_GR_M < 180
      then round(c.BULK_SPC_GR_M/62.4,3)
        when c.BULK_SPC_GR_M > 2.25 and c.BULK_SPC_GR_M < 3.00
          then round(c.BULK_SPC_GR_M,3)
            when c.BULK_SPC_GR_M > 1000 
               then round(c.BULK_SPC_GR_M/1000,3) 
                 when c.BULK_SPC_GR_M > 180 and c.BULK_SPC_GR_M < 1000 then null end
  else null
      end as As_Built_Bulk_Gravity,
case when trim(c.BULK_SPC_GR_M) is not null then
  case when c.BULK_SPC_GR_M > 120 and c.BULK_SPC_GR_M < 180
      then round(c.BULK_SPC_GR_M*27.00,3)
        when c.BULK_SPC_GR_M > 2.25 and c.BULK_SPC_GR_M < 3.00
           then round((c.BULK_SPC_GR_M*62.4)*27.00,3)
             when c.BULK_SPC_GR_M > 180 and c.BULK_SPC_GR_M < 1000 then null end
  else null
      end as As_Built_Comp_LBS_Per_CY,
c.asph_cem_t as As_Built_Mix_Type,
f.qdp_designasphalttype as design_mix_type,
ROUND(f.qdp_designpercasphalt ,1) as Design_AC,  
h.qag_name as design_plant_mix,
f.qdp_designhydlimetype as design_additive,
f.qdp_designpercadditive1 as design_perc_additive,
f.qdp_designpercvoids as Design_Hamburg_Voids,
f.qdp_designvfa as Design_VFA,  
case when f.qdp_designdensity is not null and f.qdp_designdensity > 1000
  then round(f.qdp_designdensity/1000,3)  
        when f.qdp_designdensity is not null 
          and f.qdp_designdensity > 2.25 and f.qdp_designdensity < 3.00 
          then round(f.qdp_designdensity,3)
            when f.qdp_designdensity is not null 
              and f.qdp_designdensity > 120 and f.qdp_designdensity < 180
              then round(f.qdp_designdensity/62.4,3)
  else null
    end as Design_Bulk_Gravity,
case when f.qdp_designdensity is not null and f.qdp_designdensity > 1000
  then round(((f.qdp_designdensity/1000)*62.4)*27.00,0)
        when f.qdp_designdensity is not null 
          and f.qdp_designdensity > 2.25 and f.qdp_designdensity < 3.00 
          then round(((f.qdp_designdensity*62.4))*27.00)
            when f.qdp_designdensity is not null 
              and f.qdp_designdensity > 120 and f.qdp_designdensity < 180
              then round(f.qdp_designdensity*27.00,0)
  else null
    end as Design_Comp_LBS_Per_CY,  
ROUND(f.qdp_designrice,3) as Design_Rice

from QAS.QA_PROJECT t inner join QAS.QA_PERSON s on t.qp_mdt_uid = s.qp_mdt_fk
left join QAS.QA_PLNT_MX_RPT_MATERIAL_INFO f on f.qdp_mdt_uid = t.qp_mdt_uid
inner join QAS.QA_CONTRACT y on y.qc_mdt_uid = t.qp_mdt_fk
inner join SMGR.T_CONT_PRJ p 
on trim(p.cont_id) = y.qc_contractnumber and trim(p.prj_nbr) = t.qp_controlnumber 
and trim(p.fed_st_prj_nbr) = t.qp_projectnumber
left join CONT_ID_PRJ_TABLE c 
on c.cont_id = p.cont_id and c.prim_prj_nbr = p.prj_nbr
left join corridors_table r on
r.sliced = cast(regexp_replace(nvl(substr(t.qp_route,0,instr(t.qp_route,',')-1),t.qp_route),'[^0-9]','')as int)
left join QAS.QA_AGGREGATE_SPEC_AGGMI H on h.qag_mdt_uid = t.qp_mdt_uid
inner join CONT_CRIT_DT_TABLE x on x.cont_id = p.cont_id

where t.qp_route <> 'local' 
and t.qp_route not like 'X%'
and t.qp_route not like 'L%'
and cast(regexp_replace(nvl(substr(t.qp_route,0,instr(t.qp_route,',')-1),t.qp_route),'[^0-9]','')as int) is not null
and p.beg_termini not like '%..%'
and p.beg_termini is not null
and p.end_termini is not null 
and trim(p.beg_termini) is not null
and trim(p.end_termini) is not null
and t.qp_projectnumber not like '%SF%' 
and t.qp_projectnumber not like '%HSIP%'
and t.qp_projectname not like '%BRIDGE%'
and t.qp_projectname not like '%DECK%'
and t.qp_projectname not like '%SIDEWALKS%'
and t.qp_projectname not like '%INTERSECTION%'
and t.qp_projectname not like '%FENCE%'
and c.effdt is not  null

union

select t.year_,
t.corridor,
null as PROJECT_NUMBER,
t.project_ as project_name,
t.description_,
t.mix_id,
t.contract_id,
t.project_start,
t.project_end,
t.control_number,
cast(t.esals_ as number) as esals,
t.as_built_perc_ac as AS_BUILT_AC,
t.aggregate_size as AS_BUILT_AGGREGATE_SIZE,
t.as_built_hamburg_voids,
t.as_built_vma,
t.as_built_vfa,
case when t.as_built_sg is not null and t.as_built_sg > 1000
  then round(t.as_built_sg/1000,3)  
        when t.as_built_sg is not null 
          and t.as_built_sg > 2.25 and t.as_built_sg < 3.00 
          then round(t.as_built_sg,3)
            when t.as_built_sg is not null 
              and t.as_built_sg > 120 and t.as_built_sg < 180
              then round(t.as_built_sg/62.4,3)
  else null
    end as As_Built_Bulk_Gravity,

case when t.as_built_sg is not null and t.as_built_sg > 1000
  then round(((t.as_built_sg/1000)*62.4)*27.00,0)
        when t.as_built_sg is not null 
          and t.as_built_sg > 2.25 and t.as_built_sg < 3.00 
          then round(((t.as_built_sg*62.4))*27.00)
            when t.as_built_sg is not null 
              and t.as_built_sg > 120 and t.as_built_sg < 180
              then round(t.as_built_sg*27.00,0)
  else null
    end as As_Built_Comp_LBS_Per_CY,

cast(t.as_built_mix_type as char(4)) as as_built_mix_type ,
t.design_mix_type,
cast(t.design_ac as number) as design_ac,
t.design_plant_mix,
t.design_additive,
t.design_perc_additive,
t.design_hamburg_voids,
t.design_vfa,
case when t.design_density is not null and t.design_density > 1000
  then round(t.design_density/1000,3)  
        when t.design_density is not null 
          and t.design_density > 2.25 and t.design_density < 3.00 
          then round(t.design_density,3)
            when t.design_density is not null 
              and t.design_density > 120 and t.design_density < 180
              then round(t.design_density/62.4,3)
  else null
    end as Design_Bulk_Gravity,
    
case when t.design_density is not null and t.design_density > 1000
  then round(((t.design_density/1000)*62.4)*27.00,0)
        when t.design_density is not null 
          and t.design_density > 2.25 and t.design_density < 3.00 
          then round(((t.design_density*62.4))*27.00)
            when t.design_density is not null 
              and t.design_density > 120 and t.design_density < 180
              then round(t.design_density*27.00,0)
  else null
    end as Design_Comp_LBS_Per_CY,
t.design_rice
from CHRIS_DATA_IMPORT_091817_4 t
where t.as_built_sg not like '#VALUE!' and t.as_built_sg is not null
and t.year_ > 2007 
and t.project_ not like '%SF%' 
and t.project_ not like '%HSIP%'
and t."DESCRIPTION_" not like '%BRIDGE%'
and t."DESCRIPTION_" not like '%DECK%'
and t."DESCRIPTION_" not like '%SIDEWALKS%'
and t."DESCRIPTION_" not like '%INTERSECTION%'
and t."DESCRIPTION_" not like '%FENCE%'
and t.project_start is not null

;
---------------------------------------***********************************-----------------------------------


create or replace view asphalt_data_corrections2 as
select abs(t.project_end-t.project_start) as LENGTH_,
t.Year_,t.CORRIDOR,      
t.PROJECTNUMBER as PROJECT_NUMBER,
t.project_name as PROJECT_NAME,
t.DESCRIPTION_ as DESCRIPTION_,
t.mix_id as MIX_ID,
t.contract_id as CONTRACT_ID,
cast(t.project_start as numeric(10,1)) as PROJECT_START,
cast(t.project_end as numeric(10,1)) as  PROJECT_END,
t.control_number as CONTROL_NUMBER,
cast(t.esals as number) as ESALS,
case when t.AS_BUILT_AC is null or trim(t.AS_BUILT_AC) is null
  then NULL
    else cast(t.AS_BUILT_AC as numeric(10,2))
      end as AS_BUILT_AC,
t.AS_BUILT_AGGREGATE_SIZE as AS_BUILT_AGGREGATE_SIZE,
t.as_built_hamburg_voids as AS_BUILT_HAMBURG_VOIDS,
t.as_built_vma as AS_BUILT_VMA,
t.as_built_vfa as AS_BUILT_VFA,
cast(t.As_Built_Bulk_Gravity as numeric(10,2)) as AS_BUILT_BULK_GRAVITY,
cast(t.As_Built_Comp_LBS_Per_CY as numeric(10,3)) as AS_BUILT_COMP_LBS_PER_CY,
cast(t.as_built_mix_type as number) as AS_BUILT_MIX_TYPE,
t.design_mix_type as DESIGN_MIX_TYPE,
cast(t.design_ac as numeric(10,1)) as DESIGN_AC,
t.design_plant_mix as DESIGN_PLANT_MIX,
t.design_additive as DESIGN_ADDITIVE,
cast(t.design_perc_additive as numeric(10,2)) as DESIGN_PERCENT_ADDITIVE,
cast(t.design_hamburg_voids as numeric(10,2)) as DESIGN_HAMBURG_VOIDS,
cast(t.design_vfa as numeric(10,1)) as DESIGN_VFA,
cast(t.Design_Bulk_Gravity as numeric(10,3)) as DESIGN_BULK_GRAVITY,
cast(t.Design_Comp_LBS_Per_CY as number) as DESIGN_COMP_LBS_PER_CY,
cast(t.design_rice as numeric(10,3)) as design_rice
from SURFACE_HISTORY_CLEANER2 t /*left join corridors_table s
on cast(regexp_replace(nvl(substr(t.CORRIDOR,0,instr(t.CORRIDOR,',')-1),t.CORRIDOR),'[^0-9]','')as int) = s.sliced

where t.year_ >= (select (max(t.year_)) from SURFACE_HISTORY_CLEANER2 t
                  where t.year_ <= extract(year from sysdate) - 10)
                  
group by abs(t.project_end-t.project_start),
t.year_,t.corridor,t.corridor,t.projectnumber,t.project_name,t.DESCRIPTION_,
t.mix_id,t.contract_id,t.project_start,t.project_end,
t.control_number,t.esals,
t.AS_BUILT_AC,
t.AS_BUILT_AGGREGATE_SIZE,
t.as_built_hamburg_voids,
t.as_built_vma,
t.as_built_vfa,
t.As_Built_Bulk_Gravity,
t.As_Built_Comp_LBS_Per_CY,
t.as_built_mix_type,
t.design_mix_type,
t.design_ac,
t.design_plant_mix,
t.design_additive,
t.design_perc_additive,
t.design_hamburg_voids,
t.design_vfa,
t.Design_Bulk_Gravity,
t.Design_Comp_LBS_Per_CY,
t.design_rice
having abs(t.project_end-t.project_start) > 0 
and abs(t.project_end-t.project_start) <= 20
order by 2 desc

;
---------------------------------------***********************************-----------------------------------

create or replace view ASPHALT_DATA_FINAL_OUTPUT as
select * from asphalt_data_corrections2 s where substr(s.CORRIDOR,8) is not null

;
---------------------------------------***********************************-----------------------------------

create or replace view OFF_SYSTEM_CORRS as
select substr(s.CORRIDOR,1,7) as corridor,
substr(concat(t.nrlg_dept_route,t.nrlg_roadbed),1,8) as corridorRB, t.nrlg_sys_desc
from asphalt_data_corrections s inner join TIS.TIS_NEW_ROADLOG t
on substr(s.CORRIDOR,1,8) = t.nrlg_dept_route
where substr(s.CORRIDOR,8) is null
and t.nrlg_sys_desc in (select t.nrlg_sys_desc from TIS.TIS_NEW_ROADLOG t where t.nrlg_sys_desc like 'OFF')
group by concat(t.nrlg_dept_route,t.nrlg_roadbed),substr(s.CORRIDOR,1,7),t.nrlg_sys_desc

;
---------------------------------------***********************************-----------------------------------

create or replace view OFF_SYSTEM_PROJECTS as
select s.corridorRB,s.nrlg_sys_desc,t.* 
from asphalt_data_corrections t inner join OFF_SYSTEM_CORRS s
on t.CORRIDOR = s.CORRIDOR

