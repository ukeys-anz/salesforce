/**
 * @description To get record type id based on sobject type and record type name
 * @param connection  JSForce connection
 * @param sObject Object api name
 * @param devName Record type developer name
 */
export async function getRecordTypeID(
  connection: any,
  sObject: String,
  devName: String
) {
  return new Promise<String>(resolve => {
    connection.query(
      "SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType= '" +
        sObject +
        "' AND DeveloperName='" +
        devName +
        "'",
      (err: any, result: any) => {
        if (err) {
          return console.error("error", err);
        }
        resolve(result.records[0].Id);
      }
    );
  });
}
