-- Page splits

SELECT o.object_id 
	, SCHEMA_NAME(o.schema_id) AS schema_name
	, OBJECT_NAME(os.object_id) AS table_name
	, i.name AS index_name
	, i.index_id
    , reads=range_scan_count + singleton_lookup_count
    , 'leaf_writes'=leaf_insert_count+leaf_update_count+ leaf_delete_count
    , 'leaf_page_splits' = leaf_allocation_count
    , 'nonleaf_writes'=nonleaf_insert_count + nonleaf_update_count + nonleaf_delete_count
    , 'nonleaf_page_splits' = nonleaf_allocation_count
FROM sys.dm_db_index_operational_stats (db_id(),NULL,NULL,NULL) os
JOIN sys.objects o
	ON os.object_id = o.object_id
JOIN sys.indexes i
	ON i.object_id = os.object_id
	AND i.index_id = os.index_id
WHERE OBJECTPROPERTY(os.object_id,'IsUserTable') = 1
ORDER BY nonleaf_page_splits DESC, leaf_page_splits DESC