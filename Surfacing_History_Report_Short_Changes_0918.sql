create or replace view surface_history_cleaner as
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
--round(cast(t.as_built_sg as number),3) as AS_BUILT_BULK_GRAVITY,
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
--round(cast(t.as_built_unit_weight as number),3) as AS_BUILT_COMP_LBS_PER_CY,

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
and t.year_ > 2007 and t.project_ not like '%SF%' 
and t.project_ not like '%HSIP%'
and t."DESCRIPTION_" not like '%BRIDGE%'
and t."DESCRIPTION_" not like '%DECK%'
and t."DESCRIPTION_" not like '%SIDEWALKS%'
and t."DESCRIPTION_" not like '%INTERSECTION%'
and t.project_start is not null
----------------------------------***********************************************---------------------------------
union
select distinct cast(substr(x.actl_dt,1,4)as number) as Year_,
w.Corridor_RB,
t.PRJ_NBR as PROJECT_NUMBER,
i.fed_st_prj_nbr as PROJECT_NAME, 
i.desc1 as Description_,
s.MIX_ID,t.cont_id as contract_id,
t.BEG_TERMINI as PROJECT_START,
t.END_TERMINI as PROJECT_END,
cast(t.CONT_ID as varchar(4))as Control_Number,
s.ESALS_NBR as ESALS,
s.OPT_AC_PCT_TOT_WT as As_Built_AC,

case when s.matl_cd = '401.03.01.01' then '3/4'
  when s.matl_cd = '401.03.01.02' then '1/2'
  when s.matl_cd = '401.03.01.06' then '3/8' 
    else s.matl_cd end as As_Built_Aggregate_Size,
      
s.AIR_VOIDS_P as As_Built_Hamburg_Voids,
s.VMA_P as As_Built_VMA,
s.VFA_P as As_Built_VFA,

case when trim(s.BULK_SPC_GR_M) is not null then
  case when s.BULK_SPC_GR_M > 120 and s.BULK_SPC_GR_M < 180
      then round(s.BULK_SPC_GR_M/62.4,3)
        when s.BULK_SPC_GR_M > 2.25 and s.BULK_SPC_GR_M < 3.00
          then round(s.BULK_SPC_GR_M,3)
            when s.BULK_SPC_GR_M > 1000 
               then round(s.BULK_SPC_GR_M/1000,3) 
                 when s.BULK_SPC_GR_M > 180 and s.BULK_SPC_GR_M < 1000 then null end
  else null
      end as As_Built_Bulk_Gravity,
       
case when trim(s.BULK_SPC_GR_M) is not null then
  case when s.BULK_SPC_GR_M > 120 and s.BULK_SPC_GR_M < 180
      then round(s.BULK_SPC_GR_M*27.00,3)
        when s.BULK_SPC_GR_M > 2.25 and s.BULK_SPC_GR_M < 3.00
           then round((s.BULK_SPC_GR_M*62.4)*27.00,3)
             when s.BULK_SPC_GR_M > 180 and s.BULK_SPC_GR_M < 1000 then null end
  else null
      end as As_Built_Comp_LBS_Per_CY,
      
s.ASPH_CEM_T as As_Built_Mix_Type,
--t.ASPHALT_TYPE 
null as Design_Mix_Type,
--t.DESIGN_AVG_AC 
null as Design_AC,
--t.QAG_NAME 
null as Design_Plan,
--t.ADDTIVE_1_TYPE 
null as Design_Additive,
--round(t.DESIGN_PERC_ADDITIVE,2) 
null as DESIGN_PERC_ADDITIVE,
--round(t.DESIGN_HAMBURG_VOIDS,2) 
null as DESIGN_HAMBURG_VOIDS,
--round(t.DESIGN_VFA,2) 
null as DESIGN_VFA, 

/*case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(t.AVG_DEN/1000,3)  
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(t.AVG_DEN,3)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN/62.4,3)
  else null
    end*/ 
null as Design_Bulk_Gravity,
    
/*case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(((t.AVG_DEN/1000)*62.4)*27.00,0)
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(((t.AVG_DEN*62.4))*27.00)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN*27.00,0)
  else null
    end*/ 
null as Design_Comp_LBS_Per_CY,
       
/*case when t.AVG_RICE > 1000 
  then round(t.AVG_RICE/1000,3)
    else round(t.AVG_RICE,3) 
      end*/ 
null as Design_Rice
      
from CONT_ID_PRJ_TABLE s inner join SMGR.T_CONT_PRJ i
on s.cont_id = i.cont_id and s.prim_prj_nbr = i.prj_nbr
inner join PROJECT_NUMBERS_MILES_TABLE_2 t 
on i.cont_id = t.cont_id
and i.prj_nbr = t.prj_nbr
inner join CORRIDORS_TABLE w
on w.sliced = t.sliced
inner join SMGR.T_CONT r
on t.cont_id = r.CONT_ID
inner join SMGR.T_CONT_CRIT_DT x
on x.cont_id = r.cont_id

where x.crit_dt_t = 'FREL'
and substr(x.actl_dt,1,4) > 0
and t.beg_termini not like '%..%'
and t.beg_termini is not null
and t.beg_termini is not null 
and trim(t.beg_termini) is not null
and trim(t.beg_termini) is not null
and t.beg_termini not in (select t.beg_termini from PROJECT_NUMBERS_MILES_TABLE_2 t 
                            where regexp_like(t.beg_termini,'[^0-9 | ^/.]+'))
and i.fed_st_prj_nbr not like '%SF%' 
and i.fed_st_prj_nbr not like '%HSIP%'
and i.desc1 not like '%BRIDGE%'
and i.desc1 not like '%DECK%'
and i.desc1 not like '%SIDEWALKS%'
and i.desc1 not like '%INTERSECTION%'
and t.beg_termini is not null
                        
---------------------------------------***********************************-----------------------------------
union
select distinct
cast(substr(x.actl_dt,1,4)as number) as Year_,
w.nrlg_dept_route as corridor_rb,
c.prim_prj_nbr as PROJECT_NUMBER,
i.fed_st_prj_nbr as PROJECT_NAME, 
--cast(b.fed_st_prj_nbr as varchar2(100)) as fed_st_prj_nbr,
--t.QP_PROJECTNAME 
i.desc1 as DESCRIPTION_,
cast(c.MIX_ID as varchar2(50)) as MIX_ID,
cast(s.cont_id as varchar2(50)) as CONTRACT_ID,
b.beg_termini as PROJECT_START,
b.end_termini as PROJECT_END,
cast(b.cont_id as varchar(4)) as Control_Number,
c.ESALS_NBR as ESALS,
c.OPT_AC_PCT_TOT_WT as AS_BUILT_AC,

case when c.matl_cd = '401.03.01.01' then '3/4'
  when c.matl_cd = '401.03.01.02' then '1/2'
  when c.matl_cd = '401.03.01.06' then '3/8' 
    else c.matl_cd end as As_Built_Aggregate_Size,
      
c.AIR_VOIDS_P as AS_BUILT_HAMBURG_VOIDS,
c.VMA_P as AS_BUILT_VMA,
c.VFA_P as AS_BUILT_VFA,

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
      
c.ASPH_CEM_T as AS_BUILT_MIX_TYPE,
--null t.ASP_TYPE 
null as DESIGN_MIX_TYPE,
--t.AVG_AC 
null as DESIGN_AC,
--t.QAG_NAME 
null as Design_Plan,
--t.ADD1_TYPE 
null as DESIGN_ADDITIVE,
--round(t.AVG_ADD1,2) 
null as DESIGN_PERC_ADDITIVE,
--round(t.AVG_VOID,2) 
null as DESIGN_HAMBURG_VOIDS,
--round(t.AVG_VFA,2) 
null as DESIGN_VFA,

/*case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(t.AVG_DEN/1000,3)  
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(t.AVG_DEN,3)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN/62.4,3)
  else null
    end as*/ 
null as Design_Bulk_Gravity,
    
/*case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(((t.AVG_DEN/1000)*62.4)*27.00,0)
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(((t.AVG_DEN*62.4))*27.00)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN*27.00,0)
  else null
    end as*/ 
null as Design_Comp_LBS_Per_CY,
       
/*case when t.AVG_RICE > 1000 
  then round(t.AVG_RICE/1000,3)
    else round(t.AVG_RICE,3) 
      end*/ 
null as Design_Rice
      
from CONT_ID_PRJ_TABLE c inner join SMGR.T_CONT_PRJ i
on c.cont_id = i.cont_id and c.prim_prj_nbr = i.prj_nbr
inner join PROJECT_NUMBERS_MILES_TABLE_2 b 
on i.cont_id = b.cont_id and i.prj_nbr = b.prj_nbr
inner join INTERSTATES_CORRS w
on w.sliced = b.sliced
inner join SMGR.T_CONT s
on i.cont_id = s.cont_id
inner join SMGR.T_CONT_CRIT_DT x
on x.cont_id = s.cont_id

where x.crit_dt_t = 'FREL'
and substr(x.actl_dt,1,4) > 0 
and i.fed_st_prj_nbr not like '%SF%' 
and i.fed_st_prj_nbr not like '%HSIP%'
and i.desc1 not like '%BRIDGE%'
and i.desc1 not like '%DECK%'
and i.desc1 not like '%SIDEWALKS%'
and i.desc1 not like '%INTERSECTION%'
and b.beg_termini is not null
--order by Year_,Corridor_RB,PROJECT_START,PROJECT_NUMBER
