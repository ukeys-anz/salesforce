/**
 * @description       : Exports CSV format file from View Consent Detail screen
 * @author            : Transformers Squad - Shivraj
 * @group             :
 * @last modified on  : 02-21-2024
 * @last modified by  : Transformers Squad - Shivraj
 **/
global with sharing class TFMExportConsentDetails implements Callable {
  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Boolean result = false;
    if (methodName.equals(TFMConstants.EXPORTCSVACTION)) {
      exportToCSV(input, output, options);
      result = true;
    }
    return result;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description exports data to CSV
   */
  global static Map<String, Object> exportToCSV(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    try {
      Map<String, TFM_Data_Scopes__mdt> mapScopeIDToTFMDataScopes = TFMExportConsentDetailsHelper.getDataScopesMetadata();

      List<String> newDataScopes = TFMExportConsentDetailsHelper.getNewDataScopes(
        input
      );

      String csvContent = TFMExportConsentDetailsHelper.getReportHeader();

      Map<String, Object> returnMap = TFMExportConsentDetailsHelper.formConsentData(
        input,
        input.get(TFMConstants.ACCOUNTSVALUE),
        csvContent
      );

      csvContent = String.valueOf(
        returnMap.get(TFMConstants.CSVCONTENTVARIABLE)
      );

      csvContent = TFMExportConsentDetailsHelper.formClusterData(
        csvContent,
        returnMap,
        newDataScopes,
        mapScopeIDToTFMDataScopes
      );

      Map<String, Object> sharingHistoryMap = TFMExportConsentDetailsHelper.formDataSharingHistoryData(
        csvContent,
        mapScopeIDToTFMDataScopes,
        input
      );
      Boolean isValid = Boolean.valueOf(sharingHistoryMap.get('isValid'));
      output.put('isValid', isValid);
      if (!isValid) {
        return output;
      }

      csvContent = String.valueOf(sharingHistoryMap.get('csvContent'));

      String fileTitle = TFMExportConsentDetailsHelper.getFileTitle(
        String.valueOf(input.get(TFMConstants.CONSENTIDSTRING))
      );

      output.put(TFMConstants.SHOWTOAST, TFMConstants.YESSTRING);
      output.put(TFMConstants.BLOBCONTENT, Blob.valueOf(csvContent));
      output.put(TFMConstants.FILETITLE, fileTitle);
      return output;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      output.put(TFMConstants.SHOWTOAST, TFMConstants.ERROR);
      return output;
    }
  }

  /**
   * @param action String value of local method to invoke
   * @param args arg map that will contain input, output and options map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  global Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }
}
