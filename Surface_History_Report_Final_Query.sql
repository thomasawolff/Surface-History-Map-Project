select abs(t.project_end-t.project_start) as "LENGTH",
cast(t.year_ as number) as "YEAR",
case when t."CORRIDOR" not like s.corridor_rb then s.corridor_rb
     when t."CORRIDOR" like 'C000090' then 'C000090N'
     when t."CORRIDOR" like 'C000015' then 'C000015E'
     when t."CORRIDOR" like 'C000094' then 'C000094E'
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
order by t.corridor,t.project_start*/
;
