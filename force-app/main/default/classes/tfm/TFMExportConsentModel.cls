/**
 * @author Shivraj Kadam
 * @since Mar 2024
 * @description Export Consent Model to get response from data sharing API
 * @group TFM
 */
public with sharing class TFMExportConsentModel extends CalloutModel {
  /**
   * @description results list for results of api
   */
  public String queryTime;
  public List<AggregatedEvent> aggregatedEvents;
  public String nextPageToken;

  /**
   * @description This is wrapper class for AggregatedEvent
   * @name AccountInfo
   * @author Shivraj Kadam
   */
  public class AggregatedEvent {
    public DateInfo transactionDate;
    public List<String> accounts;
    public List<String> scopes;
    public List<String> requestTypes;
    public List<String> userInfoDisclosed;
  }

  /**
   * @description This is wrapper class for AccountInfo
   * @name AccountInfo
   * @author Shivraj Kadam
   */
  public class AccountInfo {
    public String accountNumber;
    public String accountName;
    public String accountType;
    public String accountStatus;
    public String sharingStatus;

    /**
     * @param name name of the account
     * @param accNumber account number
     * @param status account status
     * @param type type og account
     * @param sharing sharing status
     * @description AccountInfo constructor
     */
    public AccountInfo(
      String name,
      String accNumber,
      String status,
      String type,
      String sharing
    ) {
      accountName = name;
      accountNumber = accNumber;
      accountStatus = status;
      accountType = type;
      sharingStatus = sharing;
    }
  }

  /**
   * @description This is wrapper class for MonthWrapper
   * @name AccountInfo
   * @author Shivraj Kadam
   */
  public class ValueWrapper {
    public Integer value;
  }

  /**
   * @description This is wrapper class for DateInfo
   * @name AccountInfo
   * @author Shivraj Kadam
   */
  public class DateInfo {
    public ValueWrapper year;
    public ValueWrapper month;
    public ValueWrapper day;
  }

  /**
   * @description Represents Response body for search Consents DataSharing History API
   * @param json json response from Consents DataSharing History API
   * @return `TFMExportConsentModel` api response is serialised into TFMExportConsentModel
   */
  public static TFMExportConsentModel parse(String json) {
    return (TFMExportConsentModel) deserialize(
      json,
      TFMExportConsentModel.class
    );
  }
}
