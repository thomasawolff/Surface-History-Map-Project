select abs(t.project_end-t.project_start) as LENGTH_,
cast(t.year_ as number) as YEAR_,
case when t.CORRIDOR not like s.corridor_rb then s.corridor_rb
     when t.CORRIDOR like 'C000090' then 'C000090N'
     when t.CORRIDOR like 'C000015' then 'C000015E'
     when t.CORRIDOR like 'C000094' then 'C000094E'
       else t.CORRIDOR
            end as CORRIDOR,
t.PROJECT_NUMBER as PROJECT_NUMBER,
t.project_name as PROJECT_NAME,
t.DESCRIPTION_ as DESCRIPTION_,
t.mix_id as MIX_ID,
t.contract_id as CONTRACT_ID,
cast(t.project_start as numeric(10,1)) as PROJECT_START,
cast(t.project_end as numeric(10,1)) as  PROJECT_END,
t.control_number as CONTROL_NUMBER,
cast(t.esals as number) as ESALS,
case when t.AS_BUILT_AC = ' '
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
