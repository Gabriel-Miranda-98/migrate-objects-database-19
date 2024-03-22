
  CREATE OR REPLACE EDITIONABLE PROCEDURE "ARTERH"."PR_ENVIA_EMAIL_AD" (av_name_from varchar2,av_msg_from varchar2,av_name_to varchar2,
  av_msg_to varchar2,av_msg_subject varchar2,av_msg_text varchar2,av_name_file varchar2,av_diretorio varchar2,
  av_body_html varchar2) AS

  vconnection utl_tcp.connection;
  vfile_type  utl_file.file_type;

  rc             integer;
  vv_quebralinha varchar2(2) := CHR(13)||CHR(10);
  recip_aux      varchar2(200);
  filetxtbuf     long;
  posit          number := 1;   -- Posição inicial do endereço do destinatário
  separator      char(1) := ';';
  vv_name_from   varchar2(2000);
  vv_name_to     varchar2(2000);

begin
  if trim(av_name_from) = '' then
    vv_name_from := av_msg_from;
  else
    vv_name_from := av_name_from;
  end if;

  if trim(av_name_to) = '' then
    vv_name_to := av_msg_to;
  else
    vv_name_to := av_name_to;
  end if;

  -- abre porta SMTP para envio
  vconnection := utl_tcp.open_connection('envia.aplicacao.pbh', 587);
  -- envia hello para preparar/testar porta
  rc := utl_tcp.write_line(vconnection, 'HELO 196.35.140.18');
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  -- envia novo hello para preparar linha de escrita na porta
  rc := utl_tcp.write_line(vconnection, 'HELO 196.35.140.18');
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));

  -- envia o(s) emitente(s) do e-mail
  rc := utl_tcp.write_line(vconnection, 'MAIL FROM: ' || av_msg_from);
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  while posit < length(av_msg_to) loop
    if instr(av_msg_to, separator, posit, 1) <> 0 then
      recip_aux := substr(av_msg_to, posit, instr(av_msg_to, separator,posit, 1) - posit);
      posit     := instr(av_msg_to, separator, posit, 1) + 1;
    else
      recip_aux := substr(av_msg_to, posit, length(av_msg_to)-posit + 1);
      posit     := length(av_msg_to) + 1;
    end if;
    rc := utl_tcp.write_line(vconnection, 'RCPT TO: '||recip_aux );
    dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  end loop;

  -- envia a parte não-visível do corpo do e-mail(parametros)
  rc := utl_tcp.write_line(vconnection, 'DATA');
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  rc := utl_tcp.write_line(vconnection, 'Date: '||to_char(sysdate, 'dd Mon yy hh24:mi:ss'));
  rc := utl_tcp.write_line(vconnection, 'From: ' || vv_name_from || ' <' || av_msg_from || '>');
  rc := utl_tcp.write_line(vconnection, 'MIME-Version: 1.0');
  rc := utl_tcp.write_line(vconnection, 'To: ' || vv_name_to || ' <' || av_msg_to || '>');
  -- imprimi assuto com a data de execução
  rc := utl_tcp.write_line(vconnection, 'Subject: ' || av_msg_subject  ||' do dia ' || to_char(sysdate,'dd/mm/yyyy'));
  -- indica que o e-mail é composto de mais partes
  rc := utl_tcp.write_line(vconnection, 'Content-Type: multipart/mixed;');
  -- indica o marcador(separador) das partes do corpo do e-mail
  rc := utl_tcp.write_line(vconnection, ' boundary="-----SECBOUND"');
  -- insere uma linha em branco (padrão do formato MIME e não pode ser removido)
  rc := utl_tcp.write_line(vconnection, '');
  -- fim do envio da parte não-visível do corpo do e-mail(parametros)

  -- envia a mensagem visível do corpo do e-mail especificando antes se é HTML ou Texto Plano, marcando antes como nova seção do corpo
  rc := utl_tcp.write_line(vconnection, '-------SECBOUND');
  if av_body_html = 'S' then
    rc := utl_tcp.write_line(vconnection, 'Content-Type: text/html');
  else
    rc := utl_tcp.write_line(vconnection, 'Content-Type: text/plain');
  end if;

  rc := utl_tcp.write_line(vconnection, 'Content-Transfer-Encoding: 7bit');
  rc := utl_tcp.write_line(vconnection, '');
  rc := utl_tcp.write_line(vconnection, av_msg_text  ||' do dia ' || to_char(sysdate,'dd/mm/yyyy'));
  rc := utl_tcp.write_line(vconnection, '');
  -- fim do envio da mensagem visível do corpo do e-mail

  -- se tem arquivo anexo envia linha a linha para a porta marcando antes como nova seção do corpo
  if av_name_file <> 'N' then
    rc := utl_tcp.write_line(vconnection, '-------SECBOUND');
    rc := utl_tcp.write_line(vconnection, 'Content-Type: text/plain;');
    rc := utl_tcp.write_line(vconnection, ' name="'||av_name_file||'"');
    rc := utl_tcp.write_line(vconnection, 'Content-Transfer_Encoding: 8bit');
    -- indica que e um anexo
    rc := utl_tcp.write_line(vconnection, 'Content-Disposition: attachment;');
    rc := utl_tcp.write_line(vconnection, ' filename="'||av_name_file||'"');
    rc := utl_tcp.write_line(vconnection, '');
    vfile_type := utl_file.fopen(av_diretorio, av_name_file, 'r');
    loop
    begin
      filetxtbuf := '';
      utl_file.get_line(vfile_type, filetxtbuf);
      rc := utl_tcp.write_line(vconnection, filetxtbuf);
      --  Linha original  rc := utl_tcp.write_line(vconnection, vv_quebralinha||filetxtbuf);
    exception
      when no_data_found then exit;
    end;
    end loop;
    utl_file.fclOSE(vfile_type);
    rc := utl_tcp.write_line(vconnection, '-------SECBOUND--');
  end if;

  -- fim do envio do arquivo anexo
  rc := utl_tcp.write_line(vconnection, '');
  -- envia [.] para sinalizar fim do corpo do e-mail
  rc := utl_tcp.write_line(vconnection, '.');
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  -- envia [QUIT] para sinalizar fim do e-mail
  rc := utl_tcp.write_line(vconnection, 'QUIT');
  dbms_output.put_line(utl_tcp.get_line(vconnection, true));
  -- fecha a conexão com a porta SMTP
  utl_tcp.close_connection(vconnection);
end;
