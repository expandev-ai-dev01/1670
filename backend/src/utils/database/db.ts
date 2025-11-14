import sql, { IRecordSet, IResult } from 'mssql';
import { getPool } from './connection';

export enum ExpectedReturn {
  Single,
  Multi,
  None,
}

/**
 * Executes a stored procedure with the given parameters.
 * @param routine The name of the stored procedure to execute.
 * @param parameters An object containing the parameters for the stored procedure.
 * @param expectedReturn The expected return type from the stored procedure.
 * @returns The result of the stored procedure execution.
 */
export async function dbRequest(
  routine: string,
  parameters: Record<string, any>,
  expectedReturn: ExpectedReturn
): Promise<any> {
  const pool = await getPool();
  const request = pool.request();

  for (const key in parameters) {
    if (Object.prototype.hasOwnProperty.call(parameters, key)) {
      request.input(key, parameters[key]);
    }
  }

  const result: IResult<any> = await request.execute(routine);

  switch (expectedReturn) {
    case ExpectedReturn.Single:
      return result.recordset[0] || null;
    case ExpectedReturn.Multi:
      return result.recordsets;
    case ExpectedReturn.None:
      return;
    default:
      throw new Error('Invalid expected return type.');
  }
}
