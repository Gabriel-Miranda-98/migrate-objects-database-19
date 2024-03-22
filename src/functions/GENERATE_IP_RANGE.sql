
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."GENERATE_IP_RANGE" (start_ip VARCHAR2, cidr_prefix NUMBER)
  RETURN ip_address_list
IS
  ip_list ip_address_list := ip_address_list();
  base_ip VARCHAR2(15) := SUBSTR(start_ip, 1, INSTR(start_ip, '/', 1) - 1);
  last_octet NUMBER := TO_NUMBER(SUBSTR(base_ip, INSTR(base_ip, '.', 1, 4) + 1));
BEGIN
  FOR i IN (SELECT num FROM temp_numbers WHERE num <= POWER(2, 32 - cidr_prefix) - 1) LOOP
    ip_list.EXTEND;
    
    ip_list(ip_list.COUNT) :=
      base_ip || '.' || TO_CHAR(last_octet + i);
  END LOOP;

  RETURN ip_list;
END;