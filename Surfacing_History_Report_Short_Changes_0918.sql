create or replace view surface_history_cleaner as
----------------------------------***********************************************-----------------------------Excel Data from Chris Lang

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


----------------------------------***********************************************---------------------------------NonInterstate Query
union
select distinct cast(substr(x.actl_dt,1,4)as number) as Year_,
w.Corridor_RB,
t.PRJ_NBR as PROJECT_NUMBER,
i.fed_st_prj_nbr as PROJECT_NAME, 
i.desc1 as Description_,
s.MIX_ID,t.cont_id as contract_id,

case when t.BEG_TERMINI like '%RP%' or t.BEG_TERMINI like '%+%'
  then cast(regexp_replace(t.BEG_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else t.BEG_TERMINI
      end as PROJECT_START,
      
case when t.END_TERMINI like '%RP%' or t.END_TERMINI like '%+%'
  then cast(regexp_replace(t.END_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else t.END_TERMINI
      end as PROJECT_END,
      
cast(t.CONT_ID as varchar(4))as Control_Number,
s.ESALS_NBR as ESALS,
s.OPT_AC_PCT_TOT_WT as As_Built_AC,

case when s.matl_cd = '401.03.01.01' then '3/4"'
  when s.matl_cd = '401.03.01.02' then '1/2"'
  when s.matl_cd = '401.03.01.06' then '3/8"' 
    else null end as As_Built_Aggregate_Size,
      
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
      
from CONT_ID_PRJ_TABLE s inner join SMGR.T_CONT_PRJ i -- Primary key = cont_id, prj_nbr
on s.cont_id = i.cont_id and s.prim_prj_nbr = i.prj_nbr
inner join PROJECT_NUMBERS_MILES_TABLE_2 t -- Primary key = cont_id, prj_nbr
on i.cont_id = t.cont_id and i.prj_nbr = t.prj_nbr
inner join CORRIDORS_TABLE w -- Primary key = sliced
on w.sliced = t.sliced
inner join CONT_CRIT_DT_TABLE x -- Primary key = cont_id
on i.cont_id = x.CONT_ID

and t.beg_termini not like '%..%'
and t.beg_termini is not null
and t.end_termini is not null 
and trim(t.beg_termini) is not null
and trim(t.end_termini) is not null
and t.beg_termini not in (select t.beg_termini from PROJECT_NUMBERS_MILES_TABLE_2 t 
                            where regexp_like(t.beg_termini,'[^0-9 | ^/.]+'))
and i.fed_st_prj_nbr not like '%SF%' 
and i.fed_st_prj_nbr not like '%HSIP%'
and i.desc1 not like '%BRIDGE%'
and i.desc1 not like '%DECK%'
and i.desc1 not like '%SIDEWALKS%'
and i.desc1 not like '%INTERSECTION%'
and i.desc1 not like '%FENCE%'
and t.beg_termini is not null
                        

---------------------------------------***********************************-----------------------------------Interstate Query
union
select distinct
cast(substr(x.actl_dt,1,4)as number) as Year_,
w.nrlg_dept_route as corridor_rb,
c.prim_prj_nbr as PROJECT_NUMBER,
i.fed_st_prj_nbr as PROJECT_NAME, 
i.desc1 as DESCRIPTION_,
cast(c.MIX_ID as varchar2(50)) as MIX_ID,
cast(i.cont_id as varchar2(50)) as CONTRACT_ID,

case when b.BEG_TERMINI like '%RP%' or b.BEG_TERMINI like '%+%'
  then cast(regexp_replace(b.BEG_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else b.BEG_TERMINI
      end as PROJECT_START,
      
case when b.END_TERMINI like '%RP%' or b.END_TERMINI like '%+%'
  then cast(regexp_replace(b.END_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else b.END_TERMINI
      end as PROJECT_END,
      
cast(b.cont_id as varchar(4)) as Control_Number,
c.ESALS_NBR as ESALS,
c.OPT_AC_PCT_TOT_WT as AS_BUILT_AC,

case when c.matl_cd = '401.03.01.01' then '3/4"'
  when c.matl_cd = '401.03.01.02' then '1/2"'
  when c.matl_cd = '401.03.01.06' then '3/8"' 
    else null end as As_Built_Aggregate_Size,
      
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
      
from CONT_ID_PRJ_TABLE c inner join SMGR.T_CONT_PRJ i -- Primary key = cont_id, prj_nbr
on c.cont_id = i.cont_id and c.prim_prj_nbr = i.prj_nbr
inner join PROJECT_NUMBERS_MILES_TABLE_2 b -- Primary key = cont_id, prj_nbr
on i.cont_id = b.cont_id and i.prj_nbr = b.prj_nbr
inner join INTERSTATES_CORRS w -- Primary Key = sliced
on w.sliced = b.sliced
inner join CONT_CRIT_DT_TABLE x -- Primary key = cont_id
on i.cont_id = x.CONT_ID
 
and i.fed_st_prj_nbr not like '%SF%' 
and i.fed_st_prj_nbr not like '%HSIP%'
and i.desc1 not like '%BRIDGE%'
and i.desc1 not like '%DECK%'
and i.desc1 not like '%SIDEWALKS%'
and i.desc1 not like '%INTERSECTION%'
and i.desc1 not like '%FENCE%'
and b.beg_termini is not null
--order by Year_,Corridor_RB,PROJECT_START,PROJECT_NUMBER

;
---------------------------------------***********************************-----------------------------------

create or replace view asphalt_data_final_output as
select abs(t.project_end-t.project_start) as "LENGTH",
cast(t.year_ as number) as "YEAR",
case when t."CORRIDOR" not like s.corridor_rb then s.corridor_rb
     when t."CORRIDOR" like 'C000090' then concat(t."CORRIDOR",'N')
     when t."CORRIDOR" like 'C000015' then concat(t."CORRIDOR",'E')
     when t."CORRIDOR" like 'C000094' then concat(t."CORRIDOR",'E')
       else t."CORRIDOR"
            end as CORRIDOR,
t.PROJECT_NUMBER as "PROJECT NUMBER",
t.project_name as "PROJECT NAME",
t.DESCRIPTION_ as "DESCRIPTION",
t.mix_id as "MIX ID",
t.contract_id as "CONTRACT ID",
cast(t.project_start as numeric(10,1)) as "PROJECT START",
cast(t.project_end as numeric(10,1)) as  "PROJECT END",
t.control_number as "CONTROL NUMBER",
cast(t.esals as number) as "ESALS",
case when t.AS_BUILT_AC = (' ')
  then NULL
    else cast(t.AS_BUILT_AC as numeric(10,2)) 
      end as "AS BUILT AC",
t.AS_BUILT_AGGREGATE_SIZE as "AS BUILT AGGREGATE SIZE",
t.as_built_hamburg_voids as "AS BUILT HAMBURG VOIDS",
t.as_built_vma as "AS BUILT VMA",
t.as_built_vfa as "AS BUILT VFA",
cast(t.As_Built_Bulk_Gravity as numeric(10,2)) as "AS BUILT BULK GRAVITY",
cast(t.As_Built_Comp_LBS_Per_CY as numeric(10,3)) as "AS BUILT COMP LBS PER CY",
cast(t.as_built_mix_type as number) as "AS BUILT MIX TYPE",
t.design_mix_type as "DESIGN MIX TYPE",
cast(t.design_ac as numeric(10,1)) as "DESIGN AC",
t.design_plant_mix as "DESIGN PLANT MIX",
t.design_additive as "DESIGN ADDITIVE",
cast(t.design_perc_additive as numeric(10,2)) as "DESIGN % ADDITIVE",
cast(t.design_hamburg_voids as numeric(10,2)) as "DESIGN HAMBURG VOIDS",
cast(t.design_vfa as numeric(10,1)) as "DESIGN VFA",
cast(t.Design_Bulk_Gravity as numeric(10,3)) as "DESIGN BULK GRAVITY",
cast(t.Design_Comp_LBS_Per_CY as number) "DESIGN COMP LBS PER CY",
cast(t.design_rice as numeric(10,3)) as "DESIGN RICE"
from SURFACE_HISTORY_CLEANER t left join corridors_table s
on t.CORRIDOR = s.nrlg_dept_route
where t.year_ >= (select (max(t.year_)) from SURFACE_HISTORY_CLEANER t
                  where t.year_ <= extract(year from sysdate) - 10)
group by abs(t.project_end-t.project_start),
t.year_,t.corridor,s.corridor_rb,t.PROJECT_NUMBER,t.project_name,t.DESCRIPTION_,
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
order by t.corridor,t.project_start
;

----------------------------------***********************************************-----------------------------

