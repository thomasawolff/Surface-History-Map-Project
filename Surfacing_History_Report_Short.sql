create or replace view Surfacing_History_Report as
SELECT A.QC_CONTRACTNUMBER, 
RTRIM(B.QP_CONTROLNUMBER) QP_CONTROLNUMBER,
regexp_substr(f.qdp_mixdesigndate,'\d*$') as Year_,
f.qdp_mixdesigndate as Design_Date,
f.qdp_mixdesigndate,
B.QP_PROJECTNUMBER,
B.QP_PROJECTNAME,
H.QAG_NAME,
C.QMI_NAME, 
C.qmi_itemnumber, 
C.qmi_biditemname,  
F.QDP_NUMBERLIFTS, 'D' PHASE,
NULL MIN_TEMP, 
NULL  Max_temp,  
NULL  MIN_STARTTIME, 
NULL  MAX_STOPTIME, 
F.qdp_designasphalttype ASP_TYPE, 
qdp_designpercadditive1  AVG_ADD1,
qdp_designvfa  AVG_VFA,
f.qdp_designhydlimetype ADD1_TYPE, 
ROUND(f.qdp_designpercasphalt ,1) AVG_AC,  
ROUND(f.qdp_designdensity,3)as AVG_DEN,  
f.qdp_designpercvoids  AVG_VOID, 
ROUND(f.qdp_designrice,3)as AVG_RICE, 
'NA' ASP_SUPPLIER,   
'NA'  ADD1_SUPPLIER, 
qdp_designpercadditive2  AVG_ADD2,  
NVL(F.qdp_designadditive2type, 
'NA') ADD2_TYPE,  
'NA' ADD2_SUPPLIER, 
G.QMM_STABILITYMINIMUM AVG_STAB, 
G.QMM_FLOWMINIMUM AVG_FLOW
FROM QAS.QA_CONTRACT A, QAS.QA_PROJECT B, QAS.QA_MATERIAL_ITEM C, QAS.QA_MATERIAL_VERSION D, 
QAS.QA_DAILY_PLANT_MIX_REPORT_DATA E,  QAS.QA_PLNT_MX_RPT_MATERIAL_INFO F, 
QAS.QA_MARSHALL_MATERIAL_INFO G,QAS.QA_AGGREGATE_SPEC_AGGMI H,QAS.QA_MARSHALL_TEST_DATA K  
WHERE B.QP_MDT_FK    = A.QC_MDT_UID
AND C.QMI_MDT_FK     = B.QP_MDT_UID
AND D.QMV_MDT_FK     = C.QMI_MDT_UID
AND E.QDP_MDT_FK     = D.QMV_MDT_UID
AND F.QDP_MDT_FK     = E.QDP_MDT_UID
AND K.QMD_MDT_FK(+)  = D.QMV_MDT_UID
AND G.QMM_MDT_FK(+)  = K.QMD_MDT_UID
AND H.QAG_MDT_FK     = D.QMV_MDT_UID
AND B.QP_PROJECTNAME NOT LIKE 'SF%'
GROUP BY A.QC_CONTRACTNUMBER, 
B.QP_CONTROLNUMBER, f.qdp_mixdesigndate, f.qdp_mixdesigndate,
B.QP_PROJECTNUMBER, B.QP_PROJECTNAME,H.QAG_NAME,
C.QMI_NAME, C.qmi_itemnumber, C.qmi_biditemname,
F.QDP_NUMBERLIFTS, 
F.qdp_designasphalttype, f.qdp_designdensity, f.qdp_designrice,
F.qdp_designpercadditive1, f.qdp_designpercvoids, f.qdp_designpercadditive1, 
F.qdp_designpercadditive2,F.qdp_designadditive2type, qdp_designvfa, 
f.qdp_designhydlimetype, f.qdp_designpercasphalt,
G.QMM_STABILITYMINIMUM, G.QMM_FLOWMINIMUM
;
create or replace view MILES_TO_FLOAT as
select distinct t.CONT_ID,s.Corridor_RB,t.FED_ST_PRJ_NBR,r.Year_,
r.Design_Date,t.ROUTE_NBR,

case when t.BEG_TERMINI like '%RP%' or t.BEG_TERMINI like '%+%'
  then cast(regexp_replace(t.BEG_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else t.BEG_TERMINI
      end as PROJECT_START,
      
case when t.END_TERMINI like '%RP%' or t.END_TERMINI like '%+%'
  then cast(regexp_replace(t.END_TERMINI,'[^0-9]','')/10.0 as VARCHAR(20))
    else t.END_TERMINI
      end as PROJECT_END,
      
r.QP_CONTROLNUMBER as CONTROL_NMBR,
r.QP_PROJECTNUMBER as PROJECT_NMBR,
r.QP_PROJECTNAME as PROJECT_NAME,
r.QAG_NAME,
r.QMI_ITEMNUMBER as ITEM_NUMBER,
r.QMI_BIDITEMNAME as BID_ITEM_NAME,
r.QDP_NUMBERLIFTS as NUMBER_LIFTS,
r.PHASE,r.ASP_TYPE as ASPHALT_TYPE,
r.AVG_ADD1 as DESIGN_PERC_ADDITIVE,
r.AVG_VFA as DESIGN_VFA,
r.ADD1_TYPE as ADDTIVE_1_TYPE,
r.AVG_AC as DESIGN_AVG_AC,

case when r.AVG_RICE > 145 and r.AVG_RICE < (148*1.2) 
  then ((r.AVG_RICE*16.0171)/1000) 
    else r.AVG_RICE 
      end as AVG_RICE,
      
case when r.AVG_DEN > 145 and r.AVG_DEN < (148*1.2) 
  then ((r.AVG_DEN*16.0171)/1000) 
    else r.AVG_DEN 
      end as AVG_DEN,
      
r.AVG_VOID as DESIGN_HAMBURG_VOIDS,
r.ADD2_TYPE as ADDITIVE_2_TYPE,
r.ASP_SUPPLIER as ASPHALT_SUPPLIER,
r.AVG_ADD2,r.AVG_STAB,r.AVG_FLOW
from CORRIDORS_TABLE s inner join PROJECT_NUMBERS_MILES_TABLE t 
on s.sliced = t.sliced and t.sliced is not null
inner join Surfacing_History_Report r
on r.QC_CONTRACTNUMBER = trim(t.cont_id)
where t.ROUTE_NBR not in (select t.ROUTE_NBR 
from PROJECT_NUMBERS_MILES_TABLE t where regexp_like(t.ROUTE_NBR,'[%L]'))
;
create or replace view AS_BUILT_DATA as
select d.cont_id,t.effdt,t.MIX_ID,t.matl_cd,t.AIR_VOIDS_P,t.VMA_P,t.VFA_P,
t.BULK_SPC_GR_M,t.ASPH_CEM_T,t.OPT_AC_PCT_TOT_WT,t.ESALS_NBR
from SMGR.T_SUPERPAVE t
inner join AS_BUILT_TABLE s 
on t.mix_id = s.mix_id
inner join SMGR.T_CONT_MIX_DSN d
on d.mix_id = s.mix_id
;
create or replace view ASPHALT_PROJECTS_MAP_DATA as
select distinct cast(substr(x.actl_dt,1,4)as number) as Year_,
t.Corridor_RB,
t.PROJECT_NMBR as PROJECT_NUMBER,
t.PROJECT_NAME as Description_,
s.MIX_ID,t.CONT_ID as Contract_ID,
t.PROJECT_START as PROJECT_START,
t.PROJECT_END as PROJECT_END,
cast(t.CONTROL_NMBR as varchar(4))as Control_Number,
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
t.ASPHALT_TYPE as Design_Mix_Type,
t.DESIGN_AVG_AC as Design_AC,
t.QAG_NAME as Design_Plan,
t.ADDTIVE_1_TYPE as Design_Additive,
round(t.DESIGN_PERC_ADDITIVE,2) as DESIGN_PERC_ADDITIVE,
round(t.DESIGN_HAMBURG_VOIDS,2) as DESIGN_HAMBURG_VOIDS,
round(t.DESIGN_VFA,2) as DESIGN_VFA, 

case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(t.AVG_DEN/1000,3)  
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(t.AVG_DEN,3)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN/62.4,3)
  else null
    end as Design_Bulk_Gravity,
    
case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(((t.AVG_DEN/1000)*62.4)*27.00,0)
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(((t.AVG_DEN*62.4))*27.00)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN*27.00,0)
  else null
    end as Design_Comp_LBS_Per_CY,
       
case when t.AVG_RICE > 1000 
  then round(t.AVG_RICE/1000,3)
    else round(t.AVG_RICE,3) 
      end as Design_Rice
      
from AS_BUILT_DATA s inner join cont_ID_miles_table i
on s.cont_id = i.cont_id 
inner join MILES_TO_FLOAT t
on t.cont_id = i.cont_id
inner join SMGR.T_CONT_CRIT_DT x
on x.cont_id = i.cont_id
where x.crit_dt_t = 'FREL'
and substr(x.actl_dt,1,4) > 0
and t.PROJECT_START not like '%..%'
and t.PROJECT_START is not null
and t.PROJECT_END is not null 
and trim(t.PROJECT_START) is not null
and trim(t.PROJECT_END) is not null
and t.PROJECT_START not in (select t.PROJECT_START from MILES_TO_FLOAT t 
                            where regexp_like(t.PROJECT_START,'[^0-9 | ^/.]+'))
union
select u.year_,e.corridor_rb,e.project_,e.description_,e.mix_id,e.cont_id,
e.project_start,e.project_end,
e.control_number,e.esals_,e.as_built_ac,

case when c.agg_code = '401.03.01.01' then '3/4'
  when c.agg_code = '401.03.01.02' then '1/2'
  when c.agg_code = '401.03.01.06' then '3/8' 
      else c.agg_code end as As_Built_Aggregate_Size,
        
e.as_built_hamburg_voids,e.as_built_vma,e.as_built_vfa,

case when e.as_built_specific_gravity is not null and e.as_built_specific_gravity > 1000
  then round(e.as_built_specific_gravity/1000,3)  
        when e.as_built_specific_gravity is not null 
          and e.as_built_specific_gravity > 2.25 and e.as_built_specific_gravity < 3.00 
          then round(e.as_built_specific_gravity,3)
            when e.as_built_specific_gravity is not null 
              and e.as_built_specific_gravity > 120 and e.as_built_specific_gravity < 180
              then round(e.as_built_specific_gravity/62.4,3)
  else null
    end as As_Built_Bulk_Gravity,
    
case when e.as_built_specific_gravity is not null and e.as_built_specific_gravity > 1000
  then round(((e.as_built_specific_gravity/1000)*62.4)*27.00,0)
        when e.as_built_specific_gravity is not null 
          and e.as_built_specific_gravity > 2.25 and e.as_built_specific_gravity < 3.00 
          then round(((e.as_built_specific_gravity*62.4))*27.00)
            when e.as_built_specific_gravity is not null 
              and e.as_built_specific_gravity > 120 and e.as_built_specific_gravity < 180
              then round(e.as_built_specific_gravity*27.00,0)
   else null
     end as As_Built_Comp_LBS_Per_CY,
      
e.as_built_mix_type,e.design_mix_type,
e.design__asphalt_content,
cast(null as varchar(10)) as Design_plan,e.design_additive,
round(e.design_percent_additive,2) as design_percent_additive,
round(e.design_hamburg_voids,2) as design_hamburg_voids,
round(e.design_vfa,2) as design_vfa,

case when e.design_density is not null and e.design_density > 1000
  then round(e.design_density/1000,3)  
        when e.design_density is not null 
          and e.design_density > 2.25 and e.design_density < 3.00 
          then round(e.design_density,3)
            when e.design_density is not null 
              and e.design_density > 120 and e.design_density < 180
              then round(e.design_density/62.4,3)
  else null
    end as Design_Bulk_Gravity,
    
case when e.design_density is not null and e.design_density > 1000
  then round(((e.design_density/1000)*62.4)*27.00,0)
        when e.design_density is not null 
          and e.design_density > 2.25 and e.design_density < 3.00 
          then round(((e.design_density*62.4))*27.00)
            when e.design_density is not null 
              and e.design_density > 120 and e.design_density < 180
              then round(e.design_density*27.00,0)
  else null
    end as Design_Comp_LBS_Per_CY,
       
round(e.design_rice,3) as design_rice
from PROJECTS_EXCEL_FILE_080317 e
inner join CHRIS_DATA_CONT_ID_TABLE w on w.cont_id = e.contract_id
inner join CHRIS_DATA_YEARS u on w.cont_id = u.cont_id
inner join CHRIS_DATA_AGG_SIZE c on w.cont_id = c.contract_id
and e.PROJECT_START is not null and u.year_ > 2007
order by Year_,Corridor_RB,PROJECT_START,PROJECT_NUMBER
;
create or replace view NEWEST_ASPHALT_MAP_DATA as
select * from ASPHALT_PROJECTS_MAP_DATA
minus 
select * from ASPHALT_PROJECTS_082317
;

create or replace view INTERSTATE_PROJECTS as
select distinct
cast(substr(x.actl_dt,1,4)as number) as Year_, 
w.nrlg_dept_route as Corridor_RB,
cast(b.fed_st_prj_nbr as varchar2(100)) as PROJECT_NUMBER,
t.QP_PROJECTNAME as DESCRIPTION_,
cast(c.MIX_ID as varchar2(50)) as MIX_ID,
cast(s.cont_id as varchar2(50)) as CONTRACT_ID,
b.beg_termini as PROJECT_START,
b.end_termini as PROJECT_END,
cast(t.QP_CONTROLNUMBER as varchar(4))as Control_Number,
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
t.ASP_TYPE as DESIGN_MIX_TYPE,
t.AVG_AC as DESIGN_AC,
t.QAG_NAME as Design_Plan,
t.ADD1_TYPE as DESIGN_ADDITIVE,
round(t.AVG_ADD1,2) as DESIGN_PERC_ADDITIVE,
round(t.AVG_VOID,2) as DESIGN_HAMBURG_VOIDS,
round(t.AVG_VFA,2) as DESIGN_VFA,

case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(t.AVG_DEN/1000,3)  
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(t.AVG_DEN,3)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN/62.4,3)
  else null
    end as Design_Bulk_Gravity,
    
case when t.AVG_DEN is not null and t.AVG_DEN > 1000
  then round(((t.AVG_DEN/1000)*62.4)*27.00,0)
        when t.AVG_DEN is not null 
          and t.AVG_DEN > 2.25 and t.AVG_DEN < 3.00 
          then round(((t.AVG_DEN*62.4))*27.00)
            when t.AVG_DEN is not null 
              and t.AVG_DEN > 120 and t.AVG_DEN < 180
              then round(t.AVG_DEN*27.00,0)
  else null
    end as Design_Comp_LBS_Per_CY,
       
case when t.AVG_RICE > 1000 
  then round(t.AVG_RICE/1000,3)
    else round(t.AVG_RICE,3) 
      end as Design_Rice
from SURFACING_HISTORY_REPORT t
inner join CONT_ID_TABLE s 
on trim(s.cont_id) = t.QC_CONTRACTNUMBER
inner join AS_BUILT_DATA c 
on s.cont_id = c.cont_id
inner join PROJECT_NUMBERS_MILES_TABLE b 
on c.cont_id = b.cont_id
inner join INTERSTATES_CORRS w on 
b.sliced = w.sliced
inner join SMGR.T_CONT_CRIT_DT x
on x.cont_id = s.cont_id
where x.crit_dt_t = 'FREL'
and substr(x.actl_dt,1,4) > 0 
order by Year_,Corridor_RB,PROJECT_START,PROJECT_NUMBER
;
create or replace view NEWEST_INTERSTATE_MAP_DATA as
select * from INTERSTATE_PROJECTS
minus 
select * from INTERSTATE_PROJECTS_082317
;
create or replace view FINAL_NEW_DATA_FOR_MAP as
select * from NEWEST_ASPHALT_MAP_DATA
union
select * from NEWEST_INTERSTATE_MAP_DATA
;
select * from ASPHALT_PROJECTS_MAP_DATA q
minus
select * from ASPHALT_PROJECTS_MAP_DATA s
where s.DESIGN_VFA = -1
union
select * from INTERSTATE_PROJECTS t

