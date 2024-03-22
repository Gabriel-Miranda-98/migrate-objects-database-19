
  CREATE OR REPLACE EDITIONABLE TRIGGER "PONTO_ELETRONICO"."TR_ARTERH_SIOM_SET_LAT_LONG" 
   BEFORE INSERT OR UPDATE OF COORD_X, COORD_Y, Latitude, Longitude
      ON PONTO_ELETRONICO.ARTERH_SIOM  FOR EACH ROW
       DECLARE
   GEOM_Lat_Long        MDSYS.SDO_GEOMETRY ;
   GEOM_UTM_SIRGAS2000  MDSYS.SDO_GEOMETRY ;

BEGIN    

   -- Caso as coordenadadas UTM/Sirgas2000 (X e Y) tenham sido informadas, calcular os respectivos valores para coordenadas geogrÃ¡ficas (WGS84)  
   If (:New.COORD_X IS NOT NULL) AND (:New.COORD_Y IS NOT NULL) Then

      -- Obs.: ConversÃ£o realizada considerando que as coordenadas X e Y, quando informadas, estarÃ£o no sistema UTM SIRGAS 2000 23S - SRID 31983 
      GEOM_UTM_SIRGAS2000 := MDSYS.SDO_GEOMETRY(2001,31983,SDO_POINT_TYPE(:New.COORD_X,:New.COORD_Y,NULL),NULL,NULL) ;

      -- Tranformando para coordenadas geogrÃ¡ficas WGS84 - SRID 4326
      GEOM_Lat_Long := sdo_cs.transform(GEOM_UTM_SIRGAS2000,'Longitude / Latitude') ;

      :New.Latitude := GEOM_Lat_Long.SDO_Point.Y ;
      :New.Longitude := GEOM_Lat_Long.SDO_Point.X ;

   End If;

EXCEPTION
   When OTHERS Then
      raise_application_error(-20000,'ERRO NA CONVERSÃƒO DE COORDENADAS');
END;




ALTER TRIGGER "PONTO_ELETRONICO"."TR_ARTERH_SIOM_SET_LAT_LONG" ENABLE