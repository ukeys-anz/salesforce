/**
 * @author Karen Valeriano
 * @since 08/2024
 * @description  Repository class for CaseSendCommunicationController.
 */

public with sharing class CaseSendCommunicationRepository {
  /**
   * @description Query related data of case records
   * @param caseIds List of case Ids
   * @return List<Case> Case records
   */
  public List<Case> getRelatedCases(List<String> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        ContactId,
        Subject,
        Description,
        OwnerId,
        CustomerOnboardingApplication__r.PersonaId__c,
        CaseNumber,
        ParentId,
        IDR_Date_Received__c,
        Priority,
        Origin,
        Twilio_Channel_SID__c,
        Status,
        Sub_Status__c,
        AccountId,
        Account.OCV_ID__c,
        Account.Source_System_ID__c,
        Account.Source_System_Name__c,
        ContactMobile,
        Fraud_Customer_Details__c,
        Fraud_MiddleNameCheck__c,
        Fraud_Selfie_Comparison_Match__c,
        Fraud_PO_Box__c,
        Fraud_Address_Valid__c,
        Fraud_Restraint_Status__c,
        Fraud_ID_Legible__c,
        Fraud_ID_Not_Picture__c,
        Fraud_Customer_Photo_Modified__c,
        Fraud_Security_Features__c,
        Fraud_Defects_Rectified__c,
        SuppliedEmail,
        LastModifiedBy.Email,
        LastModifiedBy.UserName,
        LastModifiedDate
      FROM Case
      WHERE Id IN :caseIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Query related data of case records
   * @param ownerIds List of Case records' Owner Ids
   * @return List<User> User records
   */
  public List<User> getUsers(Set<Id> ownerIds) {
    if (ownerIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Username, Email
      FROM User
      WHERE Id IN :ownerIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Query related data of case records
   * @param ownerIds List of Case records' Owner Ids
   * @return List<Group> Group records
   */
  public List<Group> getGroups(Set<Id> ownerIds) {
    if (ownerIds.isEmpty()) {
      return new List<Group>();
    }
    return [
      SELECT Id, Name, Email
      FROM Group
      WHERE Id IN :ownerIds
      WITH USER_MODE
    ];
  }
}
