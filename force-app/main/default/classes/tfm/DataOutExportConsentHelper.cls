/**
 * @description       : Exports CSV format file from View Consent Detail screen
 * @author            : Transformers Squad - Shivraj
 * @group             :
 * @last modified on  : 11-2024
 * @last modified by  : Transformers Squad - Shivraj
 **/
public with sharing class DataOutExportConsentHelper {
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
    file.add(getDataSharingHistory(dataSharingModel));
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

    for (String scopeID : dataExportModelDetails.dataScopesValue) {
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
    row.add('\"' + String.join(disclaimerString, '') + '\"');
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
   * @param dataSharingModel dataSharingModel
   * @return `List<String>`
   * @description returns data sharing history rows of csv
   */
  @TestVisible
  private static List<String> getDataSharingHistory(
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

    for (
      TFMExportConsentModel.AggregatedEvent aggregatedEvent : dataSharingModel.aggregatedEvents
    ) {
      row.add(String.join(aggregatedEvent.accounts, ' | '));

      String sharingHistoryDate =
        aggregatedEvent.transactionDate.day.value +
        '/' +
        aggregatedEvent.transactionDate.month.value +
        '/' +
        aggregatedEvent.transactionDate.year.value;
      row.add(sharingHistoryDate);

      List<String> scopeTitles = getDataSharingTitles(aggregatedEvent.scopes);
      row.add('\"' + String.join(scopeTitles, ' | ') + '\"');

      List<String> scopeDetails = getDataSharingDetails(aggregatedEvent.scopes);
      row.add('\"' + String.join(scopeDetails, ' | ') + '\"');

      row.add(
        'Transaction details may include data that dates back to 21 July 2021'
      );
    }
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
}