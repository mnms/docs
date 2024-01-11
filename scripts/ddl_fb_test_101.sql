drop table if exists fb_test;
create table if not exists fb_test
(user_id string, 
name string, 
company string, 
country string, 
event_date string,
data1 string, 
data2 string, 
data3 string,
data4 string, 
data5 string)
using r2 options (table '101', host 'localhost', port '18102', partitions 'user_id country event_date', mode 'nvkvs', group_size '10', query_result_partition_cnt_limit '40000', query_result_task_row_cnt_limit '10000', query_result_total_row_cnt_limit '100000000');
