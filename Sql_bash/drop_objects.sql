declare
  sql_text varchar(1000);
  cursor drop_object is 
    select 'drop '||object_type||' ' ||object_name for_drop 
      from user_objects 
     where object_type in ('SEQUENCE', 'PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'TABLE', 'VIEW');
  row_drop_object drop_object%rowtype;
begin
  open drop_object;
  loop
    fetch drop_object into row_drop_object;
    exit when drop_object%NOTFOUND;
    sql_text := row_drop_object.for_drop;
    execute immediate sql_text;
  end loop;
  dbms_output.put_line('Done!');
end;
/