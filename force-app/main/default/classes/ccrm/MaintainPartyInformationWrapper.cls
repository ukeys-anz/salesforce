/**
 * @author Ankit Garg
 * @since  06/2023
 * @description Wrapper class for lead conversion actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class MaintainPartyInformationWrapper {
  /**
   * @description Wrapper class to store only the required maintain party information
   */
  public class MaintainPartyInfo {
    @AuraEnabled
    public string id;
    @AuraEnabled
    public string ocvId;
    @AuraEnabled
    public string name;
    @AuraEnabled
    public string cpid;
    @AuraEnabled
    public string kycStatus;
    @AuraEnabled
    public String match;
    @AuraEnabled
    public String sourceSystem;
    @AuraEnabled
    public String clgId;
    @AuraEnabled
    public String address;
  }

  /**
   * @description Wrapper class to send matched maintain party results seperately.
   */
  public class MaintainPartyInfoWrapper {
    @AuraEnabled
    public List<MaintainPartyInfo> matchedResults;
    @AuraEnabled
    public Boolean isNewCustomer;
    @AuraEnabled
    public String oppID;
  }
}
