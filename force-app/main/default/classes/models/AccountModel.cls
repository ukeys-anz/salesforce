/**
 * @author Kopal Goswami
 * @since May 2025
 * @description This class is used for forming customer node data in the AccountModel format
 */
public class AccountModel {
  /**
   * @description Holds id of the account
   */
  public String id { get; set; }
  /**
   * @description Holds ocvId of the account
   */
  public String ocvId { get; set; }
  /**
   * @description Holds sourceSystem of the account
   */
  public String sourceSystem { get; set; }
  /**
   * @description Holds sourceSystemId of the account
   */
  public String sourceSystemId { get; set; }
  /**
   * @description Holds status of the account
   */
  public String status { get; set; }
  /**
   * @description Holds RecordType of the account
   */
  public RecordTypeModal recordType { get; set; }

  /**
   * @description get an instance of AccountModel
   * @param theAccount the Account record
   */
  public AccountModel(Account theAccount) {
    if (theAccount == null) {
      return;
    }
    this.id = theAccount.Id;
    this.ocvId = theAccount.OCV_ID__c;
    this.sourceSystem = theAccount.Source_System_Name__c;
    this.sourceSystemId = theAccount.Source_System_ID__c;

    // This approach is taken to avoid exceptions when accessing fields that haven't been previously queried.
    // This way, it will simply yield null when we try to retrieve a non-existent key.
    Map<String, Object> fldMap = theAccount.getPopulatedFieldsAsMap();
    this.status = (string) fldMap.get('FinServ__Status__c');
    this.recordType = new RecordTypeModal(
      (RecordType) fldMap.get('RecordType')
    );
  }

  /**
   * @description This is a modal class to hold RecordType details of the account in AccountModel
   */
  public class RecordTypeModal {
    /**
     * @description Holds id of the RecordType
     */
    public String recordTypeId { get; set; }
    /**
     * @description Holds name of the RecordType
     */
    public String recordTypeName { get; set; }

    /**
     * @description get an instance of RecordTypeModal
     * @param rt the RecordType record
     */
    public RecordTypeModal(RecordType rt) {
      if (rt == null) {
        return;
      }
      this.recordTypeId = rt.Id;
      this.recordTypeName = rt.DeveloperName;
    }
  }
}
