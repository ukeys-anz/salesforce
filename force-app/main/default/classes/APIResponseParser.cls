/**
 * @author Kopal Goswami
 * @since August 2023
 * @description Mapping of Nodes from v1b1 to v1
 */
public with sharing class APIResponseParser extends CalloutModel {
  /**
   * @param responseJson JSON which needs to be converted
   * @param className name of the class
   * @param responseNodeToModelNode fetching custom metadata mapping records
   * @return 'Object that can be used in other class'
   * @description this method parse the values coming from v1b1 ap back to v1 such that functionality do not impact.
   */
  public static Object parseAPIReponseToModel(
    String responseJson,
    System.Type className,
    Map<String, String> responseNodeToModelNode
  ) {
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      responseJson
    );
    updateNodeNames(responseMap, '', responseNodeToModelNode);
    String finalResponse = JSON.serialize(responseMap);
    String modifiedJson = JSON.serializePretty(responseMap);
    System.debug('Modified JSON:\n' + modifiedJson);
    return deserialize(finalResponse, className);
  }
  private static void updateNodeNames(
    Map<String, Object> dataMap,
    String parentKey,
    Map<String, String> nodeMapping
  ) {
    for (String key : new List<String>(dataMap.keySet())) {
      Object value = dataMap.get(key);
      String currentKey = (String.isEmpty(parentKey))
        ? key
        : parentKey + '.' + key;
      if (value instanceof Map<String, Object>) {
        updateNodeNames((Map<String, Object>) value, currentKey, nodeMapping);
      } else if (value instanceof List<Object>) {
        List<Object> listValue = (List<Object>) value;
        for (Integer i = 0; i < listValue.size(); i++) {
          if (listValue[i] instanceof Map<String, Object>) {
            updateNodeNames(
              (Map<String, Object>) listValue[i],
              currentKey,
              nodeMapping
            );
          }
        }
      }
      if (nodeMapping.containsKey(currentKey)) {
        String updatedKey = nodeMapping.get(currentKey);
        dataMap.put(updatedKey, value);
        dataMap.remove(key);
      }
    }
  }

  /**
   * @param className name of the class
   * @return 'list of mapping records'
   * @description this method fetch the records from custom metadata for parsing the nodes
   */
  public static Map<String, String> fetchResponseToModalMapping(
    String className
  ) {
    List<API_Response_To_Modal_Mapping__mdt> lstOfMappingNodes = [
      SELECT
        Id,
        (SELECT Id, ModelNode__c, ReponseNode__c FROM ResponseToModels__r)
      FROM API_Response_To_Modal_Mapping__mdt
      WHERE MasterLabel = :className
    ];
    Map<String, String> responseNodeToModelNode = new Map<String, String>();
    for (
      ResponseToModel__mdt eachModel : lstOfMappingNodes.get(0)
        .ResponseToModels__r
    ) {
      responseNodeToModelNode.put(
        eachModel.ModelNode__c,
        eachModel.ReponseNode__c
      );
    }
    return responseNodeToModelNode;
  }
}
