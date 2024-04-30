/**
 * @description       : Exports CSV format file from View Consent Detail screen
 * @author            : Transformers Squad - Shivraj
 * @group             :
 * @last modified on  : 03-2024
 * @last modified by  : Transformers Squad - Shivraj
 **/
public with sharing class TFMExportConsentDetailsHelper {
  /**
   * @param obj accounts data as object
   * @return `List<TFMExportConsentModel.AccountInfo>`
   * @description forms Account data
   */
  public static List<TFMExportConsentModel.AccountInfo> convertStringToAccountListWrapper(
    Object obj
  ) {
    List<TFMExportConsentModel.AccountInfo> accountsList = new List<TFMExportConsentModel.AccountInfo>();
    String jsonString = JSON.serializePretty(obj);
    if (jsonString.startsWith(TFMConstants.SQUAREBRACEOPEN)) {
      accountsList = (List<TFMExportConsentModel.AccountInfo>) JSON.deserialize(
        jsonString,
        List<TFMExportConsentModel.AccountInfo>.class
      );
    } else {
      jsonString =
        TFMConstants.SQUAREBRACEOPEN +
        jsonString +
        TFMConstants.SQUAREBRACECLOSE;
      accountsList = (List<TFMExportConsentModel.AccountInfo>) JSON.deserialize(
        jsonString,
        List<TFMExportConsentModel.AccountInfo>.class
      );
    }
    return accountsList;
  }
  /**
   * @param obj accounts data as object
   * @return `Map<String, Object>`
   * @description forms Account data
   */
  public static Map<String, Object> formAccountData(Object obj) {
    Map<String, Object> dataMapValues = new Map<String, Object>();

    String accData = TFMConstants.EMPTY;
    Boolean allAccountsClosed = false;
    Boolean allAccountsOpen = false;
    Boolean hasJointAccounts = false;

    List<TFMExportConsentModel.AccountInfo> accountsList = convertStringToAccountListWrapper(
      obj
    );
    
    for (TFMExportConsentModel.AccountInfo acc : accountsList) {
      // form CSV row - Accounts (Account Name - Account Number - Sharing Status)
      accData +=
        // if Joint Account
        (acc.accountType == TFMConstants.JOINTACCOUNTTYPE ? TFMConstants.JOINTACCOUNT : TFMConstants.EMPTY) +
        getSanitisedValue(acc.accountName) + 
        // if Closed Account
        (acc.accountStatus == TFMConstants.CLOSEDSTATUS ? TFMConstants.CLOSEDACCOUNT : TFMConstants.EMPTY) + ' - ' +
        getSanitisedValue(acc.accountNumber) + ' - ' +
        getSanitisedValue(acc.sharingStatus) + ' | ';
      
      if (acc.accountStatus == TFMConstants.CLOSEDSTATUS) {
        allAccountsClosed = true;
      } else {
        allAccountsOpen = true;
      }
      hasJointAccounts = acc.accountType == TFMConstants.JOINTACCOUNTTYPE;
    }

    dataMapValues.put(TFMConstants.ACCDATA, accData);
    dataMapValues.put(TFMConstants.ALLACCOUNTSCLOSEDVALUE, allAccountsClosed);
    dataMapValues.put(TFMConstants.ALLACCOUNTSOPENVALUE, allAccountsOpen);
    dataMapValues.put(TFMConstants.HASJOINTACCOUNTS, hasJointAccounts);
    return dataMapValues;
  }
  /**
   * @param input input from flexcard
   * @param obj accounts value as object
   * @param csvContent csv data
   * @return `Map<String, Object>`
   * @description exports data to CSV
   */
  public static Map<String, Object> formConsentData(
    Map<String, Object> input,
    Object obj,
    String csvContent
  ) {
    Map<String, Object> returnMap = new Map<String, Object>();
    Map<String, Object> dataMapValues = formAccountData(obj);
    String accData = String.valueOf(dataMapValues.get(TFMConstants.ACCDATA));
    Boolean allAccountsClosed = Boolean.valueOf(
      dataMapValues.get(TFMConstants.ALLACCOUNTSCLOSEDVALUE)
    );
    Boolean allAccountsOpen = Boolean.valueOf(
      dataMapValues.get(TFMConstants.ALLACCOUNTSOPENVALUE)
    );
    Boolean hasJointAccounts = Boolean.valueOf(
      dataMapValues.get(TFMConstants.HASJOINTACCOUNTS)
    );

    //form CSV content
    csvContent +=
      TFMConstants.ACCOUNTSSTRING +
      accData.substringBeforeLast(TFMConstants.PIPESYMBOL) +
      TFMConstants.NEWLINE;

    //csv Brand Name row
    csvContent +=
      TFMConstants.BRANDNAME +
      input.get(TFMConstants.BRANDNAMEVALUE) +
      TFMConstants.NEWLINE;

    String softwareProductString = String.valueOf(
      input.get(TFMConstants.REGISTEREDSOFTWAREPRODUCTVALUE)
    );

    //csv Software Product row
    String clientName = String.valueOf(input.get(TFMConstants.CLIENTNAMEVALUE));

    csvContent +=
      TFMConstants.SOFTWAREPRODUCT +
      clientName +
      TFMConstants.NEWLINE;

    csvContent +=
      TFMConstants.CONSENTSTATUS +
      input.get(TFMConstants.STATUSVALUE) +
      TFMConstants.NEWLINE;

    csvContent +=
      TFMConstants.CREATED +
      (input.get(TFMConstants.CREATETIMEVALUE) != null
        ? input.get(TFMConstants.CREATETIMEVALUE)
        : TFMConstants.NA) +
      TFMConstants.NEWLINE;

    csvContent +=
      TFMConstants.EXPIRATION +
      (input.get(TFMConstants.EXPIRETIMEVALUE) != null
        ? input.get(TFMConstants.EXPIRETIMEVALUE)
        : TFMConstants.NA) +
      TFMConstants.NEWLINE;

    if (input.get(TFMConstants.STATUSVALUE) == TFMConstants.STOPPEDSTATUS) {
      csvContent +=
        TFMConstants.STOPPED +
        (input.get(TFMConstants.STOPPEDVALUE) != null
          ? input.get(TFMConstants.STOPPEDVALUE)
          : TFMConstants.NA) +
        TFMConstants.NEWLINE;
      csvContent +=
        TFMConstants.AMENDED +
        TFMConstants.NA +
        TFMConstants.NEWLINE;
    } else if (
      input.get(TFMConstants.STATUSVALUE) == TFMConstants.AMENDEDSTATUS
    ) {
      csvContent +=
        TFMConstants.STOPPED +
        TFMConstants.NA +
        TFMConstants.NEWLINE;
      csvContent +=
        TFMConstants.AMENDED +
        (input.get(TFMConstants.AMENDEDVALUE) != null
          ? input.get(TFMConstants.AMENDEDVALUE)
          : TFMConstants.NA) +
        TFMConstants.NEWLINE;
    } else {
      csvContent +=
        TFMConstants.STOPPED +
        TFMConstants.NA +
        TFMConstants.NEWLINE;
      csvContent +=
        TFMConstants.AMENDED +
        TFMConstants.NA +
        TFMConstants.NEWLINE;
    }

    csvContent +=
      TFMConstants.HASJOINTACCOUNTSVALUE +
      (hasJointAccounts ? TFMConstants.YES : TFMConstants.NO) +
      TFMConstants.NEWLINE;

    returnMap.put(TFMConstants.CSVCONTENTVARIABLE, csvContent);
    returnMap.put(TFMConstants.ALLACCOUNTSCLOSEDVALUE, allAccountsClosed);
    returnMap.put(TFMConstants.ALLACCOUNTSOPENVALUE, allAccountsOpen);
    return returnMap;
  }

  /**
   * @param csvContent csv content
   * @param mapScopeIDToTFMDataScopes datascopes map
   * @param input input map from flexcard
   * @return `String`
   * @description exports data to by forming data for data sharing history
   */
  public static String formDataSharingHistoryData(
    String csvContent,
    Map<String, TFM_Data_Scopes__mdt> mapScopeIDToTFMDataScopes,
    Map<String, Object> input
  ) {
    try {
      Map<String, Object> responseMap = TFMRemoteActionUtility.getConsentDataSharingHistory(
        input
      );

      csvContent += TFMConstants.DATASHARINGHISTORYHEADER;

      Integer yearValue = null;
      Integer monthValue = null;
      Integer dayValue = null;
      String jsonString = JSON.serialize(responseMap);
      if (String.isNotBlank(jsonString)) {
        TFMExportConsentModel model = TFMExportConsentModel.parse(jsonString);

        List<TFMExportConsentModel.AggregatedEvent> aggregatedEventsList = (List<TFMExportConsentModel.AggregatedEvent>) model.aggregatedEvents;
        if (aggregatedEventsList == null && aggregatedEventsList.isEmpty()) {
          csvContent += TFMConstants.DATASHARINGDISCLAIMER;
          return csvContent;
        }
        for (
          TFMExportConsentModel.AggregatedEvent aggregatedEvent : aggregatedEventsList
        ) {
          yearValue = aggregatedEvent.transactionDate.year.value;
          monthValue = aggregatedEvent.transactionDate.month.value;
          dayValue = aggregatedEvent.transactionDate.day.value;

          List<String> accountList = aggregatedEvent.accounts;

          //first replaced with comma as was facing in creating data in CSV
          String newAccounts = +String.join(
            accountList,
            TFMConstants.COMMAWITHSPACE
          );
          newAccounts = newAccounts.replace(
            TFMConstants.COMMA,
            TFMConstants.PIPESYMBOLWITHONESPACE
          );

          Map<String, Object> clusterMap = iterateScopes(
            aggregatedEvent.scopes,
            mapScopeIDToTFMDataScopes
          );
          String clusterDetailsDSH = String.valueOf(
            clusterMap.get(TFMConstants.CLUSTERDETAILSDSH)
          );
          String clusterTitlesDSH = String.valueOf(
            clusterMap.get(TFMConstants.CLUSTERTITLESDSH)
          );

          csvContent +=
            newAccounts +
            TFMConstants.COMMA +
            dayValue +
            TFMConstants.FORWARDSLASH +
            monthValue +
            TFMConstants.FORWARDSLASH +
            yearValue +
            TFMConstants.COMMA +
            TFMConstants.DOUBLEQUOTES +
            clusterTitlesDSH.substringBeforeLast(TFMConstants.PIPESYMBOL) +
            TFMConstants.DOUBLEQUOTES +
            TFMConstants.COMMA +
            TFMConstants.DOUBLEQUOTES +
            clusterDetailsDSH.substringBeforeLast(TFMConstants.PIPESYMBOL) +
            TFMConstants.DOUBLEQUOTES +
            TFMConstants.COMMA +
            TFMConstants.TRANSACTIONSTRING +
            TFMConstants.NEWLINE;
        }
        csvContent += TFMConstants.DATASHARINGDISCLAIMER;
      }

      return csvContent;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      csvContent += TFMConstants.DATASHARINGAPIERROR;
      return csvContent;
    }
  }

  /**
   * @param aggregatedScopes aggregatedScopes values
   * @param mapScopeIDToTFMDataScopes metadata values
   * @return `Map<String, Object>`
   * @description exports data to CSV
   */
  public static Map<String, Object> iterateScopes(
    List<String> aggregatedScopes,
    Map<String, TFM_Data_Scopes__mdt> mapScopeIDToTFMDataScopes
  ) {
    Map<String, Object> clusterMap = new Map<String, Object>();
    String clusterDetailsDSH = TFMConstants.EMPTY;
    String clusterTitlesDSH = TFMConstants.EMPTY;

    for (String scopeID : aggregatedScopes) {
      clusterTitlesDSH +=
        mapScopeIDToTFMDataScopes.get(scopeID).Data_Cluster_Title__c +
        TFMConstants.PIPESYMBOLWITHSPACE;
      clusterDetailsDSH +=
        mapScopeIDToTFMDataScopes.get(scopeID).Data_Cluster_Details__c +
        TFMConstants.PIPESYMBOLWITHSPACE;
    }
    clusterMap.put(TFMConstants.CLUSTERDETAILSDSH, clusterDetailsDSH);
    clusterMap.put(TFMConstants.CLUSTERTITLESDSH, clusterTitlesDSH);
    return clusterMap;
  }

  /**
   * @return `Map<String, TFM_Data_Scopes__mdt>`
   * @description exports data to CSV
   */
  public static Map<String, TFM_Data_Scopes__mdt> getDataScopesMetadata() {
    Map<String, TFM_Data_Scopes__mdt> mapScopeIDToTFMDataScopes = new Map<String, TFM_Data_Scopes__mdt>();
    for (TFM_Data_Scopes__mdt tfm : [
      SELECT
        ID,
        Scope_ID__c,
        Data_Cluster_Title__c,
        Data_Cluster_Details__c,
        Open_Accounts_Disclaimer__c,
        Closed_Accounts_Disclaimer__c,
        Open_and_Closed_Accounts_Disclaimer__c
      FROM TFM_Data_Scopes__mdt
      LIMIT 50
    ]) {
      mapScopeIDToTFMDataScopes.put(tfm.Scope_ID__c, tfm);
    }
    return mapScopeIDToTFMDataScopes;
  }

  /**
   * @param input flexcard input
   * @return `List<String>`
   * @description get data scopes
   */
  public static List<String> getNewDataScopes(Map<String, Object> input) {
    String dataScopes = String.valueOf(input.get(TFMConstants.DATASCOPESVALUE));
    List<String> newDataScopes = dataScopes.substring(
        1,
        dataScopes.length() - 1
      )
      .split(TFMConstants.COMMAWITHSPACE);
    return newDataScopes;
  }

  /**
   * @return `String`
   * @description generates header
   */
  public static String getReportHeader() {
    Datetime currentDatetime = System.now();
    String formattedDatetime = currentDatetime.format(
      TFMConstants.DATETIMEFORMAT,
      TFMConstants.DATETIMEFORMATLOCALE
    );

    String reportGenerated =
      TFMConstants.REPORTGENERATED1 +
      formattedDatetime +
      TFMConstants.REPORTGENERATED2;

    return reportGenerated;
  }

  /**
   * @param csvContent csvContent
   * @param returnMap map from formConsentData method
   * @param newDataScopes newDataScopes values
   * @param mapScopeIDToTFMDataScopes metadata values
   * @return `String`
   * @description form csv data
   */
  public static String formClusterData(
    String csvContent,
    Map<String, Object> returnMap,
    List<String> newDataScopes,
    Map<String, TFM_Data_Scopes__mdt> mapScopeIDToTFMDataScopes
  ) {
    Boolean allAccountsClosed = Boolean.valueOf(
      returnMap.get(TFMConstants.ALLACCOUNTSCLOSEDVALUE)
    );
    Boolean allAccountsOpen = Boolean.valueOf(
      returnMap.get(TFMConstants.ALLACCOUNTSOPENVALUE)
    );

    String clusterTitles = TFMConstants.EMPTY;
    String clusterDetails = TFMConstants.EMPTY;
    String disclaimerData = TFMConstants.EMPTY;

    for (String scopeID : newDataScopes) {
      TFM_Data_Scopes__mdt dataScope = mapScopeIDToTFMDataScopes.get(scopeID);
      if (dataScope == null) {
        continue;
      }

      clusterTitles +=
        dataScope.Data_Cluster_Title__c + TFMConstants.PIPESYMBOLWITHSPACE;
      clusterDetails +=
        dataScope.Data_Cluster_Details__c + TFMConstants.PIPESYMBOLWITHSPACE;

      if (allAccountsClosed && !allAccountsOpen) {
        disclaimerData += getSanitisedValue(
          dataScope.Closed_Accounts_Disclaimer__c
        );
      } else if (allAccountsOpen && !allAccountsClosed) {
        disclaimerData += getSanitisedValue(
          dataScope.Open_Accounts_Disclaimer__c
        );
      } else {
        disclaimerData += getSanitisedValue(
          dataScope.Open_and_Closed_Accounts_Disclaimer__c
        );
      }
    }

    csvContent += addNewRowLineToCsv(
      TFMConstants.DATAREQCLUSTERTITLE,
      clusterTitles.substringBeforeLast(TFMConstants.PIPESYMBOL)
    );
    csvContent += addNewRowLineToCsv(
      TFMConstants.DATAREQDETAILS,
      clusterDetails.substringBeforeLast(TFMConstants.PIPESYMBOL)
    );
    csvContent += addNewRowLineToCsv(TFMConstants.DISCLAIMERS, disclaimerData);
    return csvContent;
  }

  /**
   * @param value data value
   * @return `String`
   * @description generates header
   */
  private static String getSanitisedValue(String value) {
    return String.isNotBlank(value) ? value : TFMConstants.EMPTY;
  }

  /**
   * @param prefix first column of csv
   * @param data second column of csv
   * @return `String`
   * @description generates header
   */
  private static String addNewRowLineToCsv(String prefix, String data) {
    return (prefix +
    TFMConstants.DOUBLEQUOTES +
    data +
    TFMConstants.DOUBLEQUOTES +
    TFMConstants.NEWLINE);
  }

  /**
   * @param consentIdValue consentId Value
   * @return `String`
   * @description generates header
   */
  public static String getFileTitle(String consentIdValue) {
    String fileDate = System.now().format('dd-MM-yyyy');
    String fileTitle =
      TFMConstants.FILENAME +
      consentIdValue +
      TFMConstants.UNDERSCORE +
      fileDate +
      TFMConstants.CSVFILEFORMAT;

    return fileTitle;
  }
}