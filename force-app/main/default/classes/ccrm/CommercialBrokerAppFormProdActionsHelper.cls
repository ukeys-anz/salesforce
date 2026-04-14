/**
 * @author Vikas AM
 * @since 02/2026
 * @description  CommercialBrokerAppFormProdActionsHelper is the helper class for commercial broker app form product Action class.
 */
public with sharing class CommercialBrokerAppFormProdActionsHelper {
  /**
   * @description Creates a list of Opportunity records from a list of ApplicationFormProduct records.
   * @param allProducts List of ApplicationFormProduct.
   * @param appFormMap Map of ApplicationFormId to ApplicationForm.
   * @param pricebookId Standard Pricebook ID.
   * @return List of Opportunity records ready for insert.
   * @author A M Vikash | Salesforce | 02-11-2025
   */
  public static List<Opportunity> createOpportunity(
    List<ApplicationFormProduct> allProducts,
    Map<Id, ApplicationForm> appFormMap,
    String pricebookId
  ) {
    List<Opportunity> optyToCreate = new List<Opportunity>();

    try {
      for (ApplicationFormProduct appFormProd : allProducts) {
        ApplicationForm parentForm = appFormMap.get(
          appFormProd.ApplicationFormId
        );
        Opportunity opty = new Opportunity();
        opty.Name = 'DUMMY';
        opty.AccountId = parentForm.AccountId;
        opty.CloseDate = Date.today().addDays(30);
        opty.StageName = 'New';
        opty.RecordTypeId = RTOpportunity.commercialOpportunity;
        opty.OwnerId = parentForm.OwnerId;
        opty.Broker_Name__c = parentForm.Assisted_Broker__c;
        opty.LeadSource = 'External Referral';
        opty.Customer_Needs__c = appFormProd.Loan_Purpose__c;
        opty.Description =
          'Broker Asset Finance Application reference ' +
          parentForm.Reference_Number__c;
        opty.Pricebook2Id = pricebookId;

        optyToCreate.add(opty);
      }
    } catch (Exception e) {
      Logger.error('Error while creation of opportunity', e).save();
    }

    return optyToCreate;
  }

  /**
   * @description Sends an in-app notification to the Opportunity owner.
   * @param optyName Name of the Opportunity.
   * @param optyId ID of the Opportunity.
   * @param optyOwnerId ID of the Opportunity owner (User).
   * @param nt Custom Notification Type record.
   * @author A M Vikash | Salesforce | 02-11-2025
   */
  public static void notifyOpportunityOwner(
    String optyName,
    String optyId,
    String optyOwnerId,
    CustomNotificationType nt
  ) {
    try {
      Messaging.CustomNotification notification = new Messaging.CustomNotification();
      notification.setTitle('New opportunity created.');
      notification.setBody(
        'New Broker Asset Finance Opportunity created - ' + optyName
      );
      notification.setSenderId(UserInfo.getUserId());
      notification.setTargetId(optyId);
      notification.setNotificationTypeId(nt.Id);

      // Send notification
      notification.send(new Set<String>{ optyOwnerId });
    } catch (Exception e) {
      Logger.error(
          'Error while notifying opportunity owner of opportunity creation',
          e
        )
        .save();
    }
  }
}
