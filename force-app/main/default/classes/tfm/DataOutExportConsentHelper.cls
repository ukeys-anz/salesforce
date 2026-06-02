/**
 * @description       : Exports CSV format file from View Consent Detail screen
 * @author            : Transformers Squad - Shivraj
 * @group             :
 * @last modified on  : 11-2024
 * @last modified by  : Transformers Squad - Shivraj
 **/
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class DataOutExportConsentHelper {
  /**
   * Map of consent sharing duration to corresponding Custom Metadata key and account status config for transaction disclaimer logic
   * `key` is the consent sharing duration in years (2 or 7)
   * `value` is a map containing:
   *    - `cmKey`: the scope ID for fetching the correct disclaimer from Custom Metadata
   *    - `accStatus`: the aggregated account status to determine which disclaimer to use (can be 'Open', 'Closed', 'Hybrid', or null if it needs to be determined dynamically)
   */
  static final Map<Integer, Map<String, String>> TXN_DISCLAIMER_BY_DURATION = new Map<Integer, Map<String, String>>{
    2 => new Map<String, String>{
      'cmKey' => 'bank:transactions:read:2y:active',
      'accStatus' => 'Open'
    },
    7 => new Map<String, String>{
      'cmKey' => 'bank:transactions:read',
      'accStatus' => null // determined dynamically based on account statuses
    }
  };

  public static List<String> archivedStatusesList = new List<String>{
    'STOPPED',
    'AMENDED',
    'EXPIRED'
  };

  /**
   * @param consentIdValue consentIdValue
   * @return `String`
   * @description returns file name of csv
   */
  public static String buildCSVTitle(String consentIdValue) {
    String fileDate = System.now().format('dd-MM-yyyy');
    String fileTitle =
      'ANZPlus_DataSharingHistory_' +
      consentIdValue +
      '_' +
      fileDate +
      '.csv';
    return fileTitle;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @param dataSharingModel dataSharingModel
   * @return `List<List<String>>`
   * @description returns csv content
   */
  public static List<List<String>> buildCSVContent(
    DataOutExportModel dataExportModelDetails,
    TFMExportConsentModel dataSharingModel
  ) {
    List<List<String>> file = new List<List<String>>();
    file.add(getReportHeader());
    file.add(getEmptyRow());
    file.add(getDataSharing());
    file.add(getAccounts(dataExportModelDetails));
    file.add(getBrandName(dataExportModelDetails.brandNameValue));
    file.add(getSoftwareProduct(dataExportModelDetails.clientNameValue));
    file.add(getConsentStatus(dataExportModelDetails.statusValue));
    file.add(getCreated(dataExportModelDetails.createTimeValue));
    file.add(getExpiration(dataExportModelDetails.expireTimeValue));
    file.add(getStopped(dataExportModelDetails));
    file.add(getAmended(dataExportModelDetails));
    file.add(getHasJointAccount(dataExportModelDetails.accountsValue));
    file.add(getDataClusterTitle(dataExportModelDetails.dataScopesValue));
    file.add(getDataClusterDetails(dataExportModelDetails.dataScopesValue));
    file.add(getDisclaimer(dataExportModelDetails));

    file.add(getEmptyRow());
    file.add(getEmptyRow());

    file.add(getDataSharingHistoryTitle());
    file.add(getDataSharingHistoryHeaders());
    file.add(getDataSharingHistory(dataExportModelDetails, dataSharingModel));
    file.add(getDataSharingHistoryDisclaimers(dataSharingModel));

    return file;
  }

  /**
   * @return `List<String>`
   * @description returns Report Generated csv row
   */
  @TestVisible
  private static List<String> getReportHeader() {
    List<String> row = new List<String>();
    String formattedDatetime = System.now()
      .format('dd MMM yyy HH:mm:ss', 'Australia/Sydney');
    row.add(
      'Report Generated At ' +
        formattedDatetime +
        ' GMT+1000 (Australian Eastern Standard Time)'
    );
    return row;
  }

  /**
   * @return `List<String>`
   * @description returns Consent Data Sharing History for csvrow
   */
  @TestVisible
  private static List<String> getDataSharing() {
    List<String> row = new List<String>();
    row.add('Consent Data Sharing History for:');
    return row;
  }

  /**
   * @return `List<String>`
   * @description returns empty row
   */
  @TestVisible
  private static List<String> getEmptyRow() {
    List<String> row = new List<String>();
    row.add('');
    return row;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @return `List<String>`
   * @description returns Accounts (Account Name - Account Number - Sharing Status) csv row
   */
  @TestVisible
  private static List<String> getAccounts(
    DataOutExportModel dataExportModelDetails
  ) {
    List<String> row = new List<String>();
    if (
      archivedStatusesList.contains(dataExportModelDetails.statusValue) == true
    ) {
      row.add('Accounts (Account Name - Account Number)');
    }
    if (
      archivedStatusesList.contains(dataExportModelDetails.statusValue) == false
    ) {
      row.add('Accounts (Account Name - Account Number - Sharing Status)');
    }
    List<String> accounts = new List<String>();
    for (
      TFMExportConsentModel.AccountInfo acc : dataExportModelDetails.accountsValue
    ) {
      String accountDetails = '';
      accountDetails += acc.accountType == 'Joint Account' ? 'Joint ' : '';
      accountDetails += acc.accountName;
      accountDetails += acc.accountStatus == 'Closed' ? ' (closed)' : '';
      accountDetails += ' - ';
      accountDetails += acc.accountNumber;
      accountDetails += archivedStatusesList.contains(
          dataExportModelDetails.statusValue
        ) == false
        ? ' - ' + acc.sharingStatus
        : '';
      accounts.add(accountDetails);
    }
    row.add(String.join(accounts, ' | '));
    return row;
  }

  /**
   * @param brandNameValue brandNameValue
   * @return `List<String>`
   * @description returns Brand Name csv row
   */
  @TestVisible
  private static List<String> getBrandName(String brandNameValue) {
    List<String> row = new List<String>();
    row.add('Brand Name');
    row.add(brandNameValue);
    return row;
  }

  /**
   * @param clientNameValue clientNameValue
   * @return `List<String>`
   * @description returns Software Product csv row
   */
  @TestVisible
  private static List<String> getSoftwareProduct(String clientNameValue) {
    List<String> row = new List<String>();
    row.add('Software Product');
    row.add(clientNameValue);
    return row;
  }

  /**
   * @param statusValue statusValue
   * @return `List<String>`
   * @description returns Consent Status csv row
   */
  @TestVisible
  private static List<String> getConsentStatus(String statusValue) {
    List<String> row = new List<String>();
    row.add('Consent Status');
    row.add(statusValue);
    return row;
  }

  /**
   * @param createTimeValue createTimeValue
   * @return `List<String>`
   * @description returns Created csv row
   */
  @TestVisible
  private static List<String> getCreated(String createTimeValue) {
    List<String> row = new List<String>();
    row.add('Created');
    row.add(createTimeValue);
    return row;
  }

  /**
   * @param expireTimeValue expireTimeValue
   * @return `List<String>`
   * @description returns Expiry csv row
   */
  @TestVisible
  private static List<String> getExpiration(String expireTimeValue) {
    List<String> row = new List<String>();
    row.add('Expiry');
    row.add(expireTimeValue);
    return row;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @return `List<String>`
   * @description returns Stopped csv row
   */
  @TestVisible
  private static List<String> getStopped(
    DataOutExportModel dataExportModelDetails
  ) {
    List<String> row = new List<String>();
    row.add('Stopped');
    String val = dataExportModelDetails.statusValue == 'STOPPED'
      ? dataExportModelDetails.stoppedValue
      : 'N/A';
    row.add(val);
    return row;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @return `List<String>`
   * @description returns Amended csv row
   */
  @TestVisible
  private static List<String> getAmended(
    DataOutExportModel dataExportModelDetails
  ) {
    List<String> row = new List<String>();
    row.add('Amended');
    String val = dataExportModelDetails.statusValue == 'AMENDED'
      ? dataExportModelDetails.amendedValue
      : 'N/A';
    row.add(val);
    return row;
  }

  /**
   * @param accountsValue accountsValue
   * @return `List<String>`
   * @description returns Consent Has Joint Accounts? csv row
   */
  @TestVisible
  private static List<String> getHasJointAccount(
    List<TFMExportConsentModel.AccountInfo> accountsValue
  ) {
    List<String> row = new List<String>();
    row.add('Consent Has Joint Accounts?');
    for (TFMExportConsentModel.AccountInfo acc : accountsValue) {
      if (acc.accountType == 'Joint Account') {
        row.add('Yes');
        return row;
      }
    }
    row.add('No');
    return row;
  }

  /**
   * @param dataScopesValue dataScopesValue
   * @return `List<String>`
   * @description returns Data Requested - Cluster Title row of csv
   */
  @TestVisible
  private static List<String> getDataClusterTitle(
    List<String> dataScopesValue
  ) {
    List<String> row = new List<String>();
    row.add('Data Requested - Cluster Title');

    List<String> scopes = new List<String>();
    for (String scopeID : dataScopesValue) {
      TFM_Data_Scopes__mdt dataScope = QueryDataScopes.getByScopeId(scopeID);
      if (dataScope == null) {
        continue;
      }
      scopes.add(dataScope.Data_Cluster_Title__c);
    }

    row.add('\"' + String.join(scopes, ' | ') + '\"');
    return row;
  }

  /**
   * @param dataScopesValue dataScopesValue
   * @return `List<String>`
   * @description returns Data Requested - Details row of csv
   */
  @TestVisible
  private static List<String> getDataClusterDetails(
    List<String> dataScopesValue
  ) {
    List<String> row = new List<String>();
    row.add('Data Requested - Details');

    List<String> scopes = new List<String>();
    for (String scopeID : dataScopesValue) {
      TFM_Data_Scopes__mdt dataScope = QueryDataScopes.getByScopeId(scopeID);
      if (dataScope == null) {
        continue;
      }
      scopes.add(dataScope.Data_Cluster_Details__c);
    }

    row.add('\"' + String.join(scopes, ' | ') + '\"');
    return row;
  }

  /**
   * @param accountsValue accountsValue
   * @return `Boolean`
   * @description returns accounts open or closed
   */
  @TestVisible
  private static Boolean allAccountsAreClosed(
    List<TFMExportConsentModel.AccountInfo> accountsValue
  ) {
    for (TFMExportConsentModel.AccountInfo acc : accountsValue) {
      if (acc.accountStatus != 'Closed') {
        return false;
      }
    }
    return true;
  }

  /**
   * @param accountsValue accountsValue
   * @return `Boolean`
   * @description returns accounts open or closed
   */
  @TestVisible
  private static Boolean allAccountsAreOpen(
    List<TFMExportConsentModel.AccountInfo> accountsValue
  ) {
    for (TFMExportConsentModel.AccountInfo acc : accountsValue) {
      if (acc.accountStatus == 'Closed') {
        return false;
      }
    }
    return true;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @return `List<String>`
   * @description returns Disclaimer row
   */
  @TestVisible
  private static List<String> getDisclaimer(
    DataOutExportModel dataExportModelDetails
  ) {
    List<String> row = new List<String>();
    row.add('Disclaimers');

    List<String> disclaimerString = new List<String>();
    Boolean accountsAreClosed = allAccountsAreClosed(
      dataExportModelDetails.accountsValue
    );
    Boolean accountsAreOpen = allAccountsAreOpen(
      dataExportModelDetails.accountsValue
    );

    Map<String, String> disclaimerOverride = new Map<String, String>{
      'bank:transactions:read' => dataExportModelDetails.transactionDisclaimer
    };

    for (String scopeID : dataExportModelDetails.dataScopesValue) {
      String disclaimer = disclaimerOverride.get(scopeID);
      if (String.isNotBlank(disclaimer)) {
        disclaimerString.add(disclaimer);
        continue;
      }
      TFM_Data_Scopes__mdt dataScope = QueryDataScopes.getByScopeId(scopeID);
      if (dataScope == null) {
        continue;
      }
      if (accountsAreClosed) {
        disclaimerString.add(dataScope.Closed_Accounts_Disclaimer__c);
      } else if (accountsAreOpen) {
        disclaimerString.add(dataScope.Open_Accounts_Disclaimer__c);
      } else {
        disclaimerString.add(dataScope.Open_and_Closed_Accounts_Disclaimer__c);
      }
    }
    row.add('\"' + String.join(disclaimerString, '').stripHtmlTags() + '\"');
    return row;
  }

  /**
   * @return `List<String>`
   * @description returns data sharing history title
   */
  @TestVisible
  private static List<String> getDataSharingHistoryTitle() {
    List<String> row = new List<String>();
    row.add('Data Sharing History');
    return row;
  }

  /**
   * @return ` List<String>`
   * @description returns data sharing history row header
   */
  @TestVisible
  private static List<String> getDataSharingHistoryHeaders() {
    List<String> row = new List<String>();
    row.add('Account');
    row.add('Sharing Date');
    row.add('Data Shared - Cluster Title');
    row.add('Data Shared - Details');
    row.add('Disclaimers');
    return row;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @param dataSharingModel dataSharingModel
   * @return `List<String>`
   * @description returns data sharing history rows of csv
   */
  @TestVisible
  private static List<String> getDataSharingHistory(
    DataOutExportModel dataExportModelDetails,
    TFMExportConsentModel dataSharingModel
  ) {
    List<String> row = new List<String>();
    if (dataSharingModel == null) {
      return row;
    }
    if (dataSharingModel.queryTime == null) {
      return row;
    }
    if (
      dataSharingModel.aggregatedEvents == null ||
      dataSharingModel.aggregatedEvents.isEmpty()
    ) {
      return row;
    }

    String dataSharingRows = '';
    List<List<String>> dataSharingRowsList = new List<List<String>>();
    for (
      TFMExportConsentModel.AggregatedEvent aggregatedEvent : dataSharingModel.aggregatedEvents
    ) {
      List<String> eachDataSharingRow = new List<String>();
      eachDataSharingRow.add(String.join(aggregatedEvent.accounts, ' | '));

      String sharingHistoryDate =
        aggregatedEvent.transactionDate.day.value +
        '/' +
        aggregatedEvent.transactionDate.month.value +
        '/' +
        aggregatedEvent.transactionDate.year.value;
      eachDataSharingRow.add(sharingHistoryDate);

      List<String> scopeTitles = getDataSharingTitles(aggregatedEvent.scopes);
      eachDataSharingRow.add('\"' + String.join(scopeTitles, ' | ') + '\"');

      List<String> scopeDetails = getDataSharingDetails(aggregatedEvent.scopes);
      eachDataSharingRow.add('\"' + String.join(scopeDetails, ' | ') + '\"');

      String transactionDisclaimer = getTransactionDisclaimer(
        aggregatedEvent,
        dataExportModelDetails.accountsValue
      ) ?? '';

      eachDataSharingRow.add(
        '\"' + transactionDisclaimer.stripHtmlTags() + '\"'
      );
      dataSharingRowsList.add(eachDataSharingRow);
    }

    for (List<String> eachRecord : dataSharingRowsList) {
      if (eachRecord.isEmpty()) {
        continue;
      }
      dataSharingRows += String.join(eachRecord, ',') + '\n';
    }

    row.add(dataSharingRows);
    return row;
  }

  /**
   * @param dataSharingModel dataSharingModel
   * @return `List<String>`
   * @description returns Disclaimers
   */
  @TestVisible
  private static List<String> getDataSharingHistoryDisclaimers(
    TFMExportConsentModel dataSharingModel
  ) {
    List<String> row = new List<String>();
    if (dataSharingModel == null) {
      row.add('Error occurred in fetching data sharing history');
      return row;
    }

    row.add('Disclaimers');
    row.add('~All data sharing history information is based on GMT');
    return row;
  }

  /**
   * @param values scopes from API
   * @return ` List<String>`
   * @description returns scope title for cluster
   */
  @TestVisible
  private static List<String> getDataSharingTitles(List<String> values) {
    List<String> scopeTitles = new List<String>();
    for (String scopeID : values) {
      TFM_Data_Scopes__mdt dataScope = QueryDataScopes.getByScopeId(scopeID);
      if (dataScope == null) {
        continue;
      }
      scopeTitles.add(dataScope.Data_Cluster_Title__c);
    }
    return scopeTitles;
  }

  /**
   * @param values scopes from API
   * @return `List<String>`
   * @description returns scope deatils for cluster
   */
  @TestVisible
  private static List<String> getDataSharingDetails(List<String> values) {
    List<String> scopeDetails = new List<String>();
    for (String scopeID : values) {
      TFM_Data_Scopes__mdt dataScope = QueryDataScopes.getByScopeId(scopeID);
      if (dataScope == null) {
        continue;
      }
      scopeDetails.add(dataScope.Data_Cluster_Details__c);
    }
    return scopeDetails;
  }

  /**
   * @param dataExportModelDetails dataExportModelDetails
   * @return `TFMExportConsentModel`
   * @description returns TFMExportConsentModel API response
   */
  public static TFMExportConsentModel getConsentDataSharingHistory(
    DataOutExportModel dataExportModelDetails
  ) {
    StaffTokenRequestModel staffModel = TFMRemoteActionUtility.setStaffModel(
      dataExportModelDetails.IDValue
    );
    OpenBankingAPIRepository api = new OpenBankingAPIRepository();
    HttpCalloutResponse response = api.getConsentDataSharingHistory(
      dataExportModelDetails.consentIdValue,
      dataExportModelDetails.originalCreateTimeValue,
      dataExportModelDetails.originalExpireTimeValue,
      staffModel
    );
    TFMExportConsentModel model = TFMExportConsentModel.parse(response.body);
    return model;
  }

  /**
   * @description Returns transaction disclaimer based on account status and sharing period for individual data sharing history record
   * @param aggregatedEvent Aggregated event from API response
   * @param accountInfos List of account info objects containing account status (from consent-level data)
   * @return Transaction disclaimer for data sharing history section of CSV
   */
  @TestVisible
  static String getTransactionDisclaimer(
    TFMExportConsentModel.AggregatedEvent aggregatedEvent,
    List<TFMExportConsentModel.AccountInfo> accountInfos
  ) {
    Integer duration = aggregatedEvent.maxShareablePeriod?.years ??
      TFMRemoteActionUtility.DEFAULT_TXN_SHARING_DURATION_YEARS;
    Map<String, String> config = TXN_DISCLAIMER_BY_DURATION.get(duration);
    if (config == null) {
      return null;
    }

    String cmKey = config.get('cmKey');
    String accStatus = config.get('accStatus') ??
      getAllAccStatus(aggregatedEvent.accounts, accountInfos);
    String cmField = TFMRemoteActionUtility.DISCLAIMER_FIELD_MAP.get(accStatus);
    if (cmField == null) {
      return null;
    }

    TFM_Data_Scopes__mdt cm = QueryDataScopes.getByScopeId(cmKey);
    return (String) cm?.get(cmField);
  }

  /**
   * @description Determines account status category (Open, Closed, or Hybrid) based on aggregated event accounts
   * @param accounts List of account identifiers from aggregated event
   * @param accountInfos List of account info objects containing account status (from consent-level data)
   * @return Account status category: 'Open', 'Closed', or 'Hybrid'
   */
  @TestVisible
  static String getAllAccStatus(
    List<String> accounts,
    List<TFMExportConsentModel.AccountInfo> accountInfos
  ) {
    Set<String> statuses = new Set<String>();
    for (TFMExportConsentModel.AccountInfo acc : accountInfos) {
      String key = acc.accountNumber.replace(' ', '-');
      if (accounts.contains(key)) {
        statuses.add(acc.accountStatus);
      }
    }
    if (statuses.isEmpty()) {
      return 'Closed';
    }
    if (statuses.size() == 1) {
      return statuses.iterator().next();
    }
    return 'Hybrid';
  }
}
