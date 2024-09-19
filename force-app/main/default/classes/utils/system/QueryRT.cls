/**
 * @author Tan Phan
 * @since Aug 2024
 * @description This class represents a utility for handling record types.
 */
public class QueryRT {
  //#region static members
  static Map<SObjectType, QueryRT> mapInstances = new Map<SObjectType, QueryRT>();

  /**
   * @description Returns an instance of QueryRT for the specified SObjectType.
   * @param objType The SObjectType.
   * @return An instance of QueryRT.
   */
  public static QueryRT of(SObjectType objType) {
    if (mapInstances.containsKey(objType)) {
      return mapInstances.get(objType);
    }
    QueryRT instance = new QueryRT(objType);
    mapInstances.put(objType, instance);
    return instance;
  }
  //#endregion

  //#region instance members
  Map<String, RecordTypeInfo> mapRTByDevName;
  Map<Id, RecordTypeInfo> mapRTById;

  QueryRT(SObjectType objType) {
    DescribeSObjectResult info = objType.getDescribe();
    this.mapRTByDevName = info.getRecordTypeInfosByDeveloperName();
    this.mapRTById = info.getRecordTypeInfosById();
  }

  /**
   * @description Returns the RecordTypeInfo object for the specified record type name.
   * @param recordTypeName The name of the record type.
   * @return The RecordTypeInfo object.
   */
  public RecordTypeInfo get(String recordTypeName) {
    return this.mapRTByDevName.get(recordTypeName);
  }

  /**
   * @description Returns the RecordTypeInfo object for the specified record type Id.
   * @param recordTypeId The Id of the record type.
   * @return The RecordTypeInfo object.
   */
  public RecordTypeInfo get(Id recordTypeId) {
    return this.mapRTById.get(recordTypeId);
  }

  /**
   * @description Returns the Id of the record type with the specified name.
   * @param recordTypeName The name of the record type.
   * @return The Id of the record type.
   */
  public Id getId(String recordTypeName) {
    return this.mapRTByDevName.get(recordTypeName).RecordTypeId;
  }
  //#endregion
}
