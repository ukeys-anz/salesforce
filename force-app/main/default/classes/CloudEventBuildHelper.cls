/**
 * @author Sanskriti Routray
 * @since  08/2024
 * @description Class to generate Cloud Event Model objects
 * without sharing: to allow trigger to publish cloud event on afterInsert
 */
public with sharing class CloudEventBuildHelper {
  /**
   * @description get Cloud Event Models for Case
   * @param theCase Case record
   * @param theAccount related Account record
   * @param action created, or updated
   * @param theUser related last modifed user
   * @param theOwner related owner user
   * @return CloudEventModel Case Cloud Event Model
   */
  public static CloudEventModel createCloudEvent(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    CloudEventModel.UserModel theOwner
  ) {
    CloudEventModel cloudEventModel;
    String caseRecordType = QueryRT.of(Case.SObjectType)
      .get(theCase.RecordTypeId)
      .getDeveloperName();

    switch on caseRecordType {
      when 'ATM_Dispute' {
        cloudEventModel = new ATMDisputeCaseCloudEventModelV2(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'Card_Dispute' {
        cloudEventModel = new CardDisputeCaseCloudEventModelV2(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'NPP_Dispute' {
        if (theCase.Dispute_Reason__c == 'Unauthorised Transaction') {
          cloudEventModel = new NPPFraudDisputeCaseCloudEventModel(
            theCase,
            theAccount,
            action,
            theUser,
            theOwner
          );
          return cloudEventModel;
        }
        cloudEventModel = new NPPDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'Direct_Debit_Dispute' {
        cloudEventModel = new DirectDebitDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'Direct_Entry_Dispute' {
        cloudEventModel = new DirectEntryDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'BPAY_Dispute' {
        cloudEventModel = new BPayDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'PayTo_Dispute' {
        cloudEventModel = new PayToDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
    }
    return null;
  }

  /**
   * @description get Cloud Event Models for Case
   * @param theCase Case record
   * @param theAccount related Account record
   * @param action created, or updated
   * @param theUser related last modifed user
   * @param theOwner related owner user
   * @return CloudEventModel Case Cloud Event Model
   */
  public static CloudEventModel createCloudEventForAlpha1(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    CloudEventModel.UserModel theOwner
  ) {
    CloudEventModel cloudEventModel;
    String caseRecordType = QueryRT.of(Case.SObjectType)
      .get(theCase.RecordTypeId)
      .getDeveloperName();

    switch on caseRecordType {
      when 'ATM_Dispute' {
        cloudEventModel = new ATMDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
      when 'Card_Dispute' {
        cloudEventModel = new CardDisputeCaseCloudEventModel(
          theCase,
          theAccount,
          action,
          theUser,
          theOwner
        );
        return cloudEventModel;
      }
    }
    return null;
  }

  /**
   * @description get ce_data payload for Case, to be used in comparing the new data model with the old data model
   * @param theCase Case record
   * @param theAccount related Account record
   * @param theOwner related owner user record
   * @param theUser related owner user record
   * @return String ce_data payload for cloud event
   */
  public static String getCloudEventDataPayload(
    Case theCase,
    Account theAccount,
    CloudEventModel.UserModel theOwner,
    User theUser
  ) {
    String cloudEventDataPayload;
    String caseRecordType = QueryRT.of(Case.SObjectType)
      .get(theCase.RecordTypeId)
      .getDeveloperName();

    switch on caseRecordType {
      when 'ATM_Dispute' {
        ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel cloudEventDataModel = new ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'Card_Dispute' {
        CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel cloudEventDataModel = new CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'NPP_Dispute' {
        if (theCase.Dispute_Reason__c == 'Unauthorised Transaction') {
          NPPFraudDisputeCaseCloudEventModel.NPPFraudDisputeCaseCloudEventDataModel cloudEventDataModel = new NPPFraudDisputeCaseCloudEventModel.NPPFraudDisputeCaseCloudEventDataModel(
            theCase,
            theAccount,
            theOwner,
            theUser
          );
          cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
          return cloudEventDataPayload;
        }
        NPPDisputeCaseCloudEventModel.NPPDisputeCaseCloudEventDataModel cloudEventDataModel = new NPPDisputeCaseCloudEventModel.NPPDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner,
          theUser
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'Direct_Debit_Dispute' {
        DirectDebitDisputeCaseCloudEventModel.DirectDebitDisputeCaseCloudEventDataModel cloudEventDataModel = new DirectDebitDisputeCaseCloudEventModel.DirectDebitDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner,
          theUser
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'Direct_Entry_Dispute' {
        DirectEntryDisputeCaseCloudEventModel.DirectEntryDisputeCaseCloudEventDataModel cloudEventDataModel = new DirectEntryDisputeCaseCloudEventModel.DirectEntryDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner,
          theUser
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'BPAY_Dispute' {
        BPayDisputeCaseCloudEventModel.BPayDisputeCaseCloudEventDataModel cloudEventDataModel = new BPayDisputeCaseCloudEventModel.BPayDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner,
          theUser
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
      when 'PayTo_Dispute' {
        PayToDisputeCaseCloudEventModel.PayToDisputeCaseCloudEventDataModel cloudEventDataModel = new PayToDisputeCaseCloudEventModel.PayToDisputeCaseCloudEventDataModel(
          theCase,
          theAccount,
          theOwner,
          theUser
        );
        cloudEventDataPayload = JSON.serialize(cloudEventDataModel);
        return cloudEventDataPayload;
      }
    }
    return null;
  }
}
