/**
 * @author Nagendra Singh
 * @since 06/2023
 * @description  Class for FetchRecordFromURL to check if callable interface calls correct method based on params.
 */
global without sharing class FetchRecordFromURL implements omnistudio.VlocityOpenInterface, Callable {
  /**
   * @description invokeMethod to handle insertion of logs from omnistudio.
   * @param methodName Method named to be called.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Boolean success = true;
    String error = '';
    try {
      if (methodName == 'fetchRecordFromURL') {
        processURLAndReturnRecord(inputMap, outMap, options);
      }
    } catch (Exception e) {
      error = e.getMessage() + ' StackTrace -> ' + e.getStackTraceString();
      success = false;
    }
    return success;
  }

  /**
   * @description insertError to handle insertion of error logs from omnistudio.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   */
  public void processURLAndReturnRecord(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    String wsParam = (String) inputMap.get('ws');
    String recordTypeId = (String) inputMap.get('recordTypeId');
    Pattern patternCompile = Pattern.compile('\\/([a-zA-Z0-9]{15,18})\\/');
    if (String.isNotBlank(wsParam)) {
      Matcher patternMatcher = patternCompile.matcher(wsParam);
      if (patternMatcher.find()) {
        String extractedRecordId = patternMatcher.group(1);
        Schema.SObjectType sobjectType = Id.valueOf(extractedRecordId)
          .getSobjectType();
        String sObjectName = String.valueOf(sobjectType);
        SObject recordFromDB = Database.query(
          'Select Id, Name From ' +
          sObjectName +
          ' WHERE Id = :extractedRecordId'
        );
        Map<String, String> idByName = new Map<String, String>();
        idByName.put('Id', String.valueOf(recordFromDB.get('Id')));
        idByName.put('Name', String.valueOf(recordFromDB.get('Name')));
        outMap.put('returnedRecordFromURL', idByName);
      }
    }
    if (String.isNotBlank(recordTypeId)) {
      SObject recordTypeFromDB = Database.query(
        'Select Name FROM RecordType WHERE Id = :recordTypeId'
      );
      outMap.put(
        'recordTypeName',
        String.valueOf(recordTypeFromDB.get('Name'))
      );
    }
  }

  /**
   * @description Overriden method from Callable interface to invoke methods dynamically based on action passed.
   * @param action Dynamic method name to be called.
   * @param args Dynamic arguments to passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  global Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }
}
