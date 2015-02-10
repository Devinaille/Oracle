--1.本脚本用于拼接俩个同名表，去重相同字段，保留不同名字段，生成对应的drop和create语句
--2.user_tab_column_is和user_tab_column_fd为各自user_tab_column中获取的数据，请剔除不需要的表
--3.两边的表数量可以不相同
--4.user_tab_columns_is/user_tab_columns_fd的创建参考下面的SQL：
--  create or replace view tab_columns_1 as 
--  select table_name, column_name, data_type, data_length, data_precision, data_scale 
--    from user_tab_columns;


select 'drop table GHS06_N_'   || table_name || ';'                 drop_table,
       'create table GHS06_N_' || table_name || '(' || CHR(10) || 
       'OC_DATE NUMBER(10),'                        || CHR(10) ||
       'SOURCE_FLAG CHAR(1),'                       || CHR(10) ||
       zd                                           || CHR(10) ||
       ')'                                          || CHR(10) || 
       'tablespace raw_data;'                                       create_table
  from (select table_name,
               substr(wm_concat(chr(10) || col_name || ' ' || data_type || jd), 2) zd
          from (select t.table_name,
                       t.col_name,
                       t.data_type,
                       replace(case
                                  when t.data_type = 'NUMBER' then
                                   '(' || to_char(greatest(pa, pb) || ',' || greatest(sa,sb)) || ')'
                                  when t.data_type = 'VARCHAR2' then
                                   '(' || to_char(greatest(la,lb)) || ')'
                                  when t.data_type = 'DATE' then
                                   ''
                                  when t.data_type = 'CHAR' then
                                   '(' || to_char(greatest(la, lb)) || ')'
                                end
                                ,'(0,0)','') jd
                  from (select greatest(nvl(a.table_name,  ' '),
                                        nvl(b.table_name,  ' ')) table_name,
                               greatest(nvl(a.column_name, ' '),
                                        nvl(b.column_name, ' ')) col_name,
                               greatest(nvl(a.data_type,   ' '),
                                        nvl(b.data_type,   ' ')) data_type,
                               nvl(a.data_length,     0) la,
                               nvl(b.data_length,     0) lb,
                               nvl(a.data_precision,  0) pa,
                               nvl(b.data_precision,  0) pb,
                               nvl(a.data_scale,      0) sa,
                               nvl(b.data_scale,      0) sb
                          from user_tab_columns_is a
                          full join user_tab_columns_fd b
                            on a.table_name = b.table_name
                           and a.column_name = b.column_name
                         order by 1, 2) t)
         group by table_name);
