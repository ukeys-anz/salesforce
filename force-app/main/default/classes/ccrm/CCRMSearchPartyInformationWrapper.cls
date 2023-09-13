/**
 * @author Ankit Garg
 * @since  06/2023
 * @description Wrapper class for lead conversion actions which includes calling search and create party api, deleting auto created contacts post conversion
 */
public with sharing class CCRMSearchPartyInformationWrapper {
  /**
   * @description Wrapper class to store only the required search party information
   */
  public class CCRMSearchPartyInfo {
    @AuraEnabled
    public string id;
    @AuraEnabled
    public string ocvId;
    @AuraEnabled
    public string name;
    @AuraEnabled
    public string suburb;
    @AuraEnabled
    public string postCode;
    @AuraEnabled
    public string cpid;
    @AuraEnabled
    public string kycStatus;
    @AuraEnabled
    public String match;
  }

  /**
   * @description Wrapper class to send required and certified results seperately.
   */
  public class CCRMSearchPartyInfoWrapper {
    @AuraEnabled
    public List<CCRMSearchPartyInfo> probableAndCertifiedResults;
  }
}
