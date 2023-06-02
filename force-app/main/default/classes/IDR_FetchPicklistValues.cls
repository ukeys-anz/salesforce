/**
 * @author Laxmi Vuyyuru
 * @since 16/2023
 * @description IDR_FetchPicklistValues is the class for mapping Issue types and sub Issue types
 */
global with sharing class IDR_FetchPicklistValues implements Callable {
  /**
   * @param action beaviour of the method to exhibit
   * @param args arguments to be used by the specified action
   * @return method to be invoked
   * @description To dispatch actual method
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }
  /**
   * @description method to access Issue type picklist values
   * @param methodName
   * @param input method name
   * @param outMap
   * @param options
   * @return true if successful
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    if (methodName.equals('populateIssueTypePicklist')) {
      populatePicklist(input, outMap, options, 'Type');
    } else if (methodName.equals('populateSubIssueTypeDependentPicklist')) {
      populateSubIssueTypeDependentPicklist(input, outMap, options);
    } else if (methodName.equals('populatePriorityPicklist')) {
      populatePicklist(input, outMap, options, 'Priority');
    } else if (methodName.equals('populateOriginPicklist')) {
      populatePicklist(input, outMap, options, 'Origin');
    }
    return true;
  }

  /**
   * @description method to access Issue type picklist values
   * @param input input map
   * @param outMap output map
   * @param options
   * @param fieldName name of picklist field
   */
  public void populatePicklist(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options,
    String fieldName
  ) {
    String objectName = 'Case';
    String controllingField = fieldName;
    List<Map<String, String>> controllingInfo = new List<Map<String, String>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(controllingField)
      .getDescribe();
    List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    for (Schema.PicklistEntry currControllingValue : controllingValues) {
      if (
        (controllingField == 'Type' &&
        currControllingValue.getValue().isNumeric()) ||
        (controllingField == 'Priority' &&
        IDRConstants.IDR_PRIORITY_VALUES.contains(
          currControllingValue.getValue()
        )) ||
        (controllingField == 'Origin' &&
        IDRConstants.IDR_ORIGIN_VALUES.contains(
          currControllingValue.getValue()
        ))
      ) {
        controllingInfo.add(
          new Map<String, String>{
            'name' => currControllingValue.getLabel(),
            'value' => currControllingValue.getLabel()
          }
        );
      }
    }
    outMap.put('options', controllingInfo);
  }

  /**
   * @description method to access Issue type picklist values
   * @param input subsequent Issue type
   * @param outMap  map of subsequent types
   * @param options
   */
  public void populateSubIssueTypeDependentPicklist(
    Map<String, Object> input,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    String objectName = 'Case';
    String controllingField = 'Type';
    String dependentField = 'IDR_Subsequent_Issue__c';
    Map<String, List<Map<String, String>>> controllingInfo = new Map<String, List<Map<String, String>>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    Schema.DescribeSObjectResult describeResult = objType.getDescribe();
    Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap()
      .get(controllingField)
      .getDescribe();
    Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap()
      .get(dependentField)
      .getDescribe();
    List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
    List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    for (Schema.PicklistEntry currControllingValue : controllingValues) {
      controllingInfo.put(
        currControllingValue.getLabel(),
        new List<Map<String, String>>()
      );
    }

    for (Schema.PicklistEntry currDependentValue : dependentValues) {
      String jsonString = JSON.serialize(currDependentValue);
      MyPickListInfo info = (MyPickListInfo) JSON.deserialize(
        jsonString,
        MyPickListInfo.class
      );
      String hexString = EncodingUtil.convertToHex(
          EncodingUtil.base64Decode(info.validFor)
        )
        .toUpperCase();
      Integer baseCount = 0;
      for (Integer curr : hexString.getChars()) {
        Integer val = 0;
        if (curr >= 65) {
          val = curr - 65 + 10;
        } else {
          val = curr - 48;
        }
        if ((val & 8) == 8) {
          controllingInfo.get(controllingValues[baseCount + 0].getLabel())
            .add(
              new Map<String, String>{
                'name' => currDependentValue.getLabel(),
                'value' => currDependentValue.getLabel()
              }
            );
        }
        if ((val & 4) == 4) {
          controllingInfo.get(controllingValues[baseCount + 1].getLabel())
            .add(
              new Map<String, String>{
                'name' => currDependentValue.getLabel(),
                'value' => currDependentValue.getLabel()
              }
            );
        }
        if ((val & 2) == 2) {
          controllingInfo.get(controllingValues[baseCount + 2].getLabel())
            .add(
              new Map<String, String>{
                'name' => currDependentValue.getLabel(),
                'value' => currDependentValue.getLabel()
              }
            );
        }
        if ((val & 1) == 1) {
          controllingInfo.get(controllingValues[baseCount + 3].getLabel())
            .add(
              new Map<String, String>{
                'name' => currDependentValue.getLabel(),
                'value' => currDependentValue.getLabel()
              }
            );
        }
        baseCount = baseCount + 4;
      }
    }
    outMap.put('dependency', +controllingInfo);
  }

  /**
   * @description method to access Issue type picklist values
   */
  public class MyPickListInfo {
    public String validFor;
  }
}
