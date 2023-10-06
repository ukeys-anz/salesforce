/**
 * @description controller class for CaseNotificationConfirmation lwc
 * @author Duc Nam Le
 * @since 08/2023
 */
public with sharing class CaseSendCommunicationController {
  private static final String STATUS_PENDING_DOCUMENTS = 'status.pending_documents';
  private static final String KYC_QA_EMAIL_COMMUNICATION_CHATTER_MSG = 'Automated KYC QA Email Communication has been successfully sent to the customer.';

  /**
   * @description method to send email notification to customer by case record ID
   * @param recordId Salesforce ID of the Case record from the lwc component
   */
  @AuraEnabled
  public static void sendCommunication(String recordId) {
    if (
      PermissionUtils.canQuery('Case') &&
      PermissionUtils.canQuery('User') &&
      PermissionUtils.canQuery('Group') &&
      PermissionUtils.canQuery('CustomerOnboardingApplication__c')
    ) {
      List<CloudEventModel> cloudEventModels = generateCloudEventModel(
        new List<String>{ recordId }
      );
      List<sObject> publishingResults = CloudEventController.publishCloudEvents(
        cloudEventModels
      );
      if (!publishingResults.isEmpty()) {
        ChatterUtils.makeAPost(
          recordId,
          KYC_QA_EMAIL_COMMUNICATION_CHATTER_MSG
        );
      } else {
        throw new AuraHandledException(
          'Email notification request could not be sent.'
        );
      }
    }
  }

  /**
   * @description generate Cloud Event Models for send email notification
   * @param caseIds List of case record ids
   * @return List<CloudEventModel> List of Case Cloud Event Model
   */
  private static List<CloudEventModel> generateCloudEventModel(
    List<String> caseIds
  ) {
    List<CloudEventModel> cloudEventModels = new List<CloudEventModel>();
    if (caseIds.isEmpty()) {
      return cloudEventModels;
    }

    List<Case> cases = getRelatedCases(caseIds);
    Set<Id> ownerIds = getOwnerIds(cases);
    Map<Id, User> ownerUsers = new Map<Id, User>(
      [SELECT Id, Username, Email FROM User WHERE Id IN :ownerIds]
    );
    Map<Id, Group> ownerGroups = new Map<Id, Group>(
      [SELECT Id, Name, Email FROM Group WHERE Id IN :ownerIds]
    );

    for (Case caseItem : cases) {
      CloudEventModel.UserModel ownerModel = CloudEventModel.getCaseOwnerModel(
        caseItem.ownerId,
        ownerUsers,
        ownerGroups
      );
      cloudEventModels.add(
        new AutoKYCQACaseCloudEventModel(
          caseItem,
          caseItem.Account,
          STATUS_PENDING_DOCUMENTS,
          caseItem.LastModifiedBy,
          ownerModel,
          caseItem.CustomerOnboardingApplication__r
        )
      );
    }

    return cloudEventModels;
  }

  /**
   * @description get the list Ids of case owners
   * @param cases List of case
   * @return Set<Id> Set Ids of Case Owners
   */
  private static Set<Id> getOwnerIds(List<Case> cases) {
    Set<Id> ownerIds = new Set<Id>();
    for (Case caseItem : cases) {
      ownerIds.add(caseItem.OwnerId);
    }
    return ownerIds;
  }

  /**
   * @description Qquery related data of case records
   * @param caseIds List of case Ids
   * @return List<Case> Case records
   */
  private static List<Case> getRelatedCases(List<String> caseIds) {
    List<Case> cases = [
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
    ];
    return cases;
  }
}
