
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."REBUILD_PARTITION_RHMOV_2006" 
as
  i integer;
BEGIN
execute immediate('alter index RHMOVI_MOVI_PART_PK rebuild partition P_2006 tablespace RHINDEX_P5A');
END;

 