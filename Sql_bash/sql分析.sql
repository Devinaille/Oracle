sql分析
--取快照
select t.snap_id,cast(t.end_interval_time as date) end_time 
  from dba_hist_snapshot t
 order by snap_id desc;

--查询某段时间耗时语句
select s.sql_id,s.plan_hash_value phv,dbms_lob.substr(t.sql_text,3000) sql_text,
       round(s.elapsed_time_delta/1000000) td,round(s.elapsed_time_total/1000000) tt,
       s.executions_delta ed,s.executions_total et,s.* 
  from dba_hist_sqlstat s,dba_hist_sqltext t 
 where s.sql_id = t.sql_id 
   and s.snap_id = 9583
 order by td desc;

--查看执行计划
select sql_id,lpad(' ',depth*6,' ')||operation||' '||options||decode(id,0,',GOAL='||optimizer) operation,
       object_owner,object_name,cost,cardinality,bytes,cpu_cost,io_cost,timestamp 
  from dba_hist_sql_plan 
 where sql_id = '&sql_id'
   and plan_hash_value = &phv
 order by id;


select b.SID,a.BLOCKS,a.* from v$sort_usage a join v$session b on a.SESSION_ADDR = b.SADDR;

