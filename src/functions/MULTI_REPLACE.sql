
  CREATE OR REPLACE EDITIONABLE FUNCTION "ARTERH"."MULTI_REPLACE" (
                        pString IN VARCHAR2
                        ,pReplacePattern IN VARCHAR2
) RETURN VARCHAR2 IS
    iCount  INTEGER;
    vResult VARCHAR2(1000);
    vRule   VARCHAR2(100);
    vOldStr VARCHAR2(50);
    vNewStr VARCHAR2(50);
BEGIN
    iCount := 0;
    vResult := pString;
    LOOP
        iCount := iCount + 1;

        -- Step # 1: Pick out the replacement rules
        vRule := REGEXP_SUBSTR(pReplacePattern, '[^/]+', 1, iCount);

        -- Step # 2: Pick out the old and new string from the rule
        vOldStr := REGEXP_SUBSTR(vRule, '[^=]+', 1, 1);
        vNewStr := REGEXP_SUBSTR(vRule, '[^=]+', 1, 2);

        -- Step # 3: Do the replacement
        vResult := REPLACE(vResult, vOldStr, vNewStr);

        EXIT WHEN vRule IS NULL;
    END LOOP;

    RETURN vResult;
END multi_replace;