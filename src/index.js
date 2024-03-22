import oracledb from 'oracledb';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import 'dotenv/config';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

oracledb.fetchAsString = [oracledb.CLOB];
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.initOracleClient();

const saveDDLToFile = async (directory, name, ddl) => {
  const dirPath = path.join(__dirname, directory);
  try {
    await fs.mkdir(dirPath, { recursive: true });
    const filePath = path.join(dirPath, `${name}.sql`);
    await fs.writeFile(filePath, ddl);
    console.log(`Saved: ${filePath}`);
  } catch (err) {
    console.error(`Error in saveDDLToFile: ${err}`);
  }
};

const extractAndSaveDDLs = async (connection, objectType, ownerInClause) => {
  let objectTypePlural = objectType.toLowerCase() + 's'; // Convert to plural form
  let query = `SELECT OBJECT_NAME, DBMS_METADATA.GET_DDL('${objectType}', OBJECT_NAME, OWNER) AS DLL FROM ALL_OBJECTS WHERE OWNER IN (${ownerInClause}) AND OBJECT_TYPE = '${objectType}'`;

  try {
    const result = await connection.execute(query);
    for (let row of result.rows) {
      await saveDDLToFile(objectTypePlural, row.OBJECT_NAME, row.DLL);
    }
  } catch (err) {
    // Aqui você pode tratar o erro ORA-31603 especificamente, se necessário
    if (err.errorNum === 31603) {
      console.log(`Object not found, skipping... Error: ${err.message}`);
    } else {
      // Para outros erros, você pode querer rethrow ou apenas logar
      console.error(`Error in extractAndSaveDDLs: ${err}`);
    }
  }
};

const run = async () => {
  try {
    const connection = await oracledb.getConnection({
      user: process.env.ORACLE_USER_19,
      password: process.env.ORACLE_PASSWORD_19,
      connectString: process.env.ORACLE_HOST_19
    });

    const owners = "'ARTERH', 'PONTO_ELETRONICO'";
    const objectTypes = ['VIEW', 'PROCEDURE', 'FUNCTION', 'TRIGGER', 'SEQUENCE', 'TYPE'];

    for (let objectType of objectTypes) {
      await extractAndSaveDDLs(connection, objectType, owners);
    }

    await connection.close();
  } catch (err) {
    console.error(`Error in run: ${err}`);
  }
};

run().catch(err => console.error(err));
