--1，连上服务器，使用top命令，可以查看cpu使用率以及内存的使用情况等等，还有当前各用户的使用情况
--2，用pl/sql developper，tool里面选sessions，就可以看到当前session的情况，包括卡住的SQL语句

--3，查看各用户的各种资源占用，可以运行下面的SQL

select se.SID, ses.username, ses.osuser, n.NAME, se.VALUE
  from v$statname n, v$sesstat se, v$session ses
  where n.statistic# = se.statistic# and
        se.sid = ses.sid and
        ses.username is not null and
        n.name in ('CPU used by this session',
                   'db block gets',
                   'consistent gets',
                   'physical reads',
                   'free buffer requested',
                   'table scans (long tables)',
                   'table scan rows gotten',
                   'sorts (memory)',
                   'sorts (disk)',
                   'sorts (rows)', 
                   'session uga memory max' ,
                   'session pga memory max')
  order by sid, n.statistic#;

--4，要想看占用资源的SQL top10之类的数据，有下面的SQL哦：

从V$SQLAREA中查询最占用资源的查询
select b.username username,a.disk_reads reads,
    a.executions exec,a.disk_reads/decode(a.executions,0,1,a.executions) rds_exec_ratio,
    a.sql_text Statement
from  v$sqlarea a,dba_users b
where a.parsing_user_id=b.user_id
 and a.disk_reads > 100000
order by a.disk_reads desc;
--用buffer_gets列来替换disk_reads列可以得到占用最多内存的sql语句的相关信息。
 
--V$SQL是内存共享SQL区域中已经解析的SQL语句。

列出使用频率最高的5个查询：
select sql_text,executions
from (select sql_text,executions,
   rank() over
    (order by executions desc) exec_rank
   from v$sql)
where exec_rank <=5;
--消耗磁盘读取最多的sql top5：
select disk_reads,sql_text
from (select sql_text,disk_reads,
   dense_rank() over
     (order by disk_reads desc) disk_reads_rank
   from v$sql)
where disk_reads_rank <=5;

--找出需要大量缓冲读取（逻辑读）操作的查询：
select buffer_gets,sql_text
from (select sql_text,buffer_gets,
   dense_rank() over
     (order by buffer_gets desc) buffer_gets_rank
   from v$sql)
where buffer_gets_rank<=5;