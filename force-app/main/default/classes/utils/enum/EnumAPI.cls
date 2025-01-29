/**
 * @author Mani
 * @since 01/2025
 * @description This acts as a Proto Enum Mapper service, convert the salesforce picklist value to Proto Enum and vice versa
 */
public with sharing class EnumAPI {
  //#region static members
  static Map<String, Map<String, String>> enumMap = new Map<String, Map<String, String>>();

  //#region instance members
  Map<String, string> mapByProtoKey;
  Map<String, string> mapBySfKey;
  /**
   * @description Constructor of EnumAPI
   * @param source api name static resource
   * @param version Proto version
   * @param fieldName enum field name
   */
  public EnumAPI(string source, string version, string fieldName) {
    this.mapByProtoKey = this.getEnumMap(
      source,
      version +
      '.' +
      fieldName +
      '_key'
    );
    this.mapBySfKey = this.getEnumMap(
      source,
      version +
      '.' +
      fieldName +
      '_value'
    );
  }
  //#endregion

  /**
   * @description Get salesforce picklist value by given Proto Enum Key
   * @param protoKey Proto Enum key
   * @return string salesforce picklist value
   */
  public String getSfKey(String protoKey) {
    return this.mapByProtoKey.get(protoKey);
  }

  /**
   * @description Get Proto Enum Key by given salesforce picklist value
   * @param sfKey salesforce picklist value
   * @return string Proto Enum key
   */
  public String getProtoKey(String sfKey) {
    return this.mapBySfKey.get(sfKey);
  }

  private Map<String, String> getEnumMap(string source, string key) {
    if (enumMap.containsKey(key)) {
      return enumMap.get(key);
    }
    Map<String, Map<String, String>> tempMap = (Map<String, Map<String, String>>) JSON.deserialize(
      getStaticResource(source),
      Map<String, Map<String, String>>.class
    );
    enumMap.putAll(tempMap);
    return enumMap.get(key);
  }

  private string getStaticResource(string source) {
    return [SELECT body FROM StaticResource WHERE Name = :source]
      .body.toString();
  }
}
