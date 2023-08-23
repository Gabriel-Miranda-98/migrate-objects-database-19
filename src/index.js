import oracledb from 'oracledb'
import fs from 'node:fs'
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import 'dotenv/config'

const __filename = fileURLToPath(import.meta.url);

const __dirname = path.dirname(__filename);
oracledb.fetchAsString = [ oracledb.CLOB ];
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.initOracleClient()
async function run() {

  let SQL_OBJECT =null
  const connection = await oracledb.getConnection ({
    user          : process.env.ORACLE_USER,
    password      : process.env.ORACLE_PASSWORD,
    connectString : process.env.ORACLE_HOST
});

const connection19 = await oracledb.getConnection ({
  user          : process.env.ORACLE_USER_19,
  password      : process.env.ORACLE_PASSWORD,
  connectString : process.env.ORACLE_HOST_19
});

await connection.execute(`BEGIN
dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',false);
END;`)
await connection.execute("begin dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',false);end;")
await connection.execute("begin dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',false);end;")
let result = await connection.execute(
  `SELECT  VIEW_NAME, DBMS_METADATA.GET_DDL('VIEW', VIEW_NAME,OWNER) AS DLL FROM DBA_VIEWS  WHERE OWNER IN ('ARTERH','PONTO_ELETRONICO')`,
  );

for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'views', `${result.rows[i].VIEW_NAME}.sql`);

 SQL_OBJECT = result.rows[i].DLL; 
try {
  await connection19.execute(SQL_OBJECT)
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })

}
 
  

}


result = await connection.execute(`SELECT  TYPE_NAME, DBMS_METADATA.GET_DDL('TYPE', TYPE_NAME,OWNER) AS DLL FROM dba_types  WHERE OWNER IN ('ARTERH','PONTO_ELETRONICO')`,
[])
for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'tipos', `${result.rows[i].TYPE_NAME}.sql`);

 SQL_OBJECT =result.rows[i].DLL; 
 try {
  await connection19.execute(SQL_OBJECT,[])
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })

}

  

}

result = await connection.execute(`SELECT OBJECT_NAME, DBMS_METADATA.GET_DDL(OBJECT_TYPE, OBJECT_NAME,OWNER) AS DLL FROM DBA_PROCEDURES WHERE OWNER IN ('ARTERH','PONTO_ELETRONICO')AND OBJECT_TYPE='FUNCTION'`,[])


for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'funcoes', `${result.rows[i].OBJECT_NAME}.sql`);

 SQL_OBJECT =result.rows[i].DLL; 
 try {
  await connection19.execute(SQL_OBJECT,[])
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })

}

 

}

result = await connection.execute(`SELECT OBJECT_NAME, DBMS_METADATA.GET_DDL(OBJECT_TYPE, OBJECT_NAME,OWNER) AS DLL FROM DBA_PROCEDURES WHERE OWNER IN ('ARTERH','PONTO_ELETRONICO')AND OBJECT_TYPE='PROCEDURE'`,[])


for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'procedures', `${result.rows[i].OBJECT_NAME}.sql`);

 SQL_OBJECT =result.rows[i].DLL; 
 try {
  await connection19.execute(SQL_OBJECT,[])
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })

}

 

}
await connection.execute(`begin
  
dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY'              , false );

dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR'       , false); 

end;`)
await connection.commit()
result = await connection.execute(`SELECT OWNER,TRIGGER_NAME, DBMS_METADATA.GET_DDL('TRIGGER', TRIGGER_NAME,OWNER) AS DLL FROM dba_triggers  WHERE OWNER IN ('ARTERH','PONTO_ELETRONICO')`)


for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'trigger', `${result.rows[i].TRIGGER_NAME}.sql`);
let owner = result.rows[i].OWNER;
let triggerName = result.rows[i].TRIGGER_NAME;

let regexPattern = new RegExp(`ALTER TRIGGER "${owner}"."${triggerName}" ENABLE`, 'g');

SQL_OBJECT = result.rows[i].DLL.replace(regexPattern, "");
 try {
  await connection19.execute(SQL_OBJECT,[])
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })
}



}
 result = await connection.execute(`SELECT  SEQUENCE_NAME, DBMS_METADATA.GET_DDL('SEQUENCE', SEQUENCE_NAME,SEQUENCE_OWNER) AS DLL FROM dba_sequences  WHERE SEQUENCE_OWNER IN ('ARTERH','PONTO_ELETRONICO')AND   SEQUENCE_NAME NOT LIKE '%ISEQ%'`)


for(let i=0; i<result.rows.length; i++){
  const filePath = path.join(__dirname, 'sequences', `${result.rows[i].SEQUENCE_NAME}.sql`);



SQL_OBJECT = result.rows[i].DLL
 try {
  await connection19.execute(SQL_OBJECT,[])
  console.log('Saved!');

} catch (error) {
  console.log(error)
  console.log(SQL_OBJECT)
  fs.appendFile(filePath, SQL_OBJECT, function (err) {
    if (err) throw err;
    console.log('Saved!');
  })
}



}


await connection.close();


}


run();