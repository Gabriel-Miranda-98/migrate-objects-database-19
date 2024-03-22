
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."SP_TESTE_GRAVA_TXT" as
    arquivo_saida                    UTL_File.File_Type;
    Cursor Cur_Linha is select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss "seculo" CC') DATA from dual;

BEGIN
    arquivo_saida := UTL_File.Fopen('/vpn_BRADESCO/xiprodab/processar','teste.txt','w');
    For Reg_Linha in Cur_linha Loop
        UTL_File.Put_Line(arquivo_saida, Reg_linha.Data);
    End Loop;
    UTL_File.Fclose(arquivo_saida);
    Dbms_Output.Put_Line('Arquivo gerado com sucesso.');
EXCEPTION
      WHEN UTL_FILE.INVALID_OPERATION THEN
               Dbms_Output.Put_Line('Operação inválida no arquivo.');
               UTL_File.Fclose(arquivo_saida);
      WHEN UTL_FILE.WRITE_ERROR THEN
               Dbms_Output.Put_Line('Erro de gravação no arquivo.');
               UTL_File.Fclose(arquivo_saida);
      WHEN UTL_FILE.INVALID_PATH THEN
               Dbms_Output.Put_Line('Diretório inválido.');
               UTL_File.Fclose(arquivo_saida);
      WHEN UTL_FILE.INVALID_MODE THEN
               Dbms_Output.Put_Line('Modo de acesso inválido.');
               UTL_File.Fclose(arquivo_saida);
      WHEN Others THEN
               Dbms_Output.Put_Line('Problemas na geração do arquivo.');
               UTL_File.Fclose(arquivo_saida);
END;
