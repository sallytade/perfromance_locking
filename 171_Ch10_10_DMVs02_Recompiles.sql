/*
Diagnosing recompilations and statement recompiles 

sys.dm_exec_query_stats:
	-- plan_generation_num is the sequential number of the plan that is currently being used. 
	"1" means this is the initial compile. "2" means that this is a recompile.
	A number of "5" indicates that there were four previous compiles in addition to the current one.
	
	-- execution_count - total number of times the plan has been executed

*/

SELECT  TOP 100
	qs.plan_generation_num ,
         qs.execution_count,
         DatabaseName = DB_NAME(qp.dbid),
         ObjectName = OBJECT_NAME(qp.objectid,qp.dbid),
         StatementDefinition =
                SUBSTRING (
                        st.text,
                        (
                                qs.statement_start_offset / 2
                        ) + 1,
                 (
                                       (
                                               CASE qs.statement_end_offset
                         WHEN -1 THEN DATALENGTH(st.text)
                         ELSE qs.statement_end_offset
                                               END - qs.statement_start_offset
                                       ) / 2
                                ) + 1
                ),
         query_plan,
         st.text, total_elapsed_time
 FROM    sys.dm_exec_query_stats AS qs
         CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
         CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) qp
 WHERE
     st.encrypted = 0
     AND st.dbid = DB_ID('LearnItFirst')
     AND qs.plan_generation_num > 1
 ORDER BY qs.execution_count DESC