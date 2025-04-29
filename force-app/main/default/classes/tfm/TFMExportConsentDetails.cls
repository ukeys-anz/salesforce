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
    if (methodName.equals('exportToCSV')) {
      if (input.get('accountsValue') == 'null') {
        input.put(
          'accountsValue',
          new List<TFMExportConsentModel.AccountInfo>()
        );
      }
      String jsonString = JSON.serialize(input);
      DataOutExportModel dataExportModelDetails = DataOutExportModel.parse(
        jsonString
      );
      output.putAll(exportToCSV(dataExportModelDetails));
      result = true;
    }
    return result;
  }

  /**
   * @param dataExportModelDetails DataOutExportModel model with input paramters
   * @return `Map<String, Object`
   * @description exports data to CSV
   */
  public static Map<String, Object> exportToCSV(
    DataOutExportModel dataExportModelDetails
  ) {
    Map<String, Object> output = new Map<String, Object>();
    String fileTitle = DataOutExportConsentHelper.buildCSVTitle(
      dataExportModelDetails.consentIdValue
    );
    try {
      TFMExportConsentModel dataSharingModel = DataOutExportConsentHelper.getConsentDataSharingHistory(
        dataExportModelDetails
      );
      String csvFile = buildCSV(dataExportModelDetails, dataSharingModel);

      output = setOutputMap(csvFile, fileTitle);
      return output;
    } catch (OpenBankingAPIRepository.InsufficientAccessException e) {
      Logger.info(e.getMessage(), e);
      Logger.saveLog();
      output.put('isValid', false);
      return output;
    } catch (OpenBankingAPIRepository.ServerErrorException e) {
      logError(e);
      String csvFile = buildCSV(dataExportModelDetails, null);
      output = setOutputMap(csvFile, fileTitle);
      return output;
    } catch (Exception e) {
      logError(e);
      output.put('showToast', 'error');
      return output;
    }
  }

  /**
   * @param dataExportModelDetails DataOutExportModel model with input paramters
   * @param dataSharingModel TFMExportConsentModel model with sharing API response
   * @return `String`
   * @description build csv file
   */
  public static String buildCSV(
    DataOutExportModel dataExportModelDetails,
    TFMExportConsentModel dataSharingModel
  ) {
    List<List<String>> csvContent = DataOutExportConsentHelper.buildCSVContent(
      dataExportModelDetails,
      dataSharingModel
    );

    String csvFile = '';
    for (List<String> row : csvContent) {
      if (row.isEmpty()) {
        continue;
      }
      csvFile += String.join(row, ',') + '\n';
    }
    return csvFile;
  }

  /**
   * @param e Exception to set log
   * @description Log error
   */
  public static void logError(Exception e) {
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
  }

  /**
   * @param csvFile String having csvFile
   * @param fileTitle String having fileTitle
   * @return Map<String, Object> having output
   * @description Log error
   */
  public static Map<String, Object> setOutputMap(
    String csvFile,
    String fileTitle
  ) {
    Map<String, Object> output = new Map<String, Object>();
    output.put('blobContent', Blob.valueOf(csvFile));
    output.put('fileTitle', fileTitle);
    output.put('isValid', true);
    output.put('showToast', 'yes');
    return output;
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