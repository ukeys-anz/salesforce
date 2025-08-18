/**
 * @description       : Action class for managing business logic on Associated_Loan_Application__c on the RBM Broker Interaction flow.
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class RBMInteractionApplicationActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final AssociatedLoanApplicationRepository ASSOCIATED_APP_REPOSITORY = (AssociatedLoanApplicationRepository) Lib_InstanceProvider.forType(
    AssociatedLoanApplicationRepository.class
  );
  /**
   * @description Define custom exceptions
   */
  public class RBMInteractionApplicationCustomException extends Exception {
  }
  /**
   * @description This function creates Associated Loan Application records for the given list of Interactions.
   * @param records List of Interaction records from the trigger
   */
  public static void createAssociatedLoanApplication(
    List<Interaction> records
  ) {
    List<Interaction> loanInteractions = ListUtil.filter(records)
      .isNotNull(Interaction.Loan_Application__c)
      .toList();
    List<Associated_Loan_Application__c> recordsToInsert = buildAssociatedLoanApplication(
      loanInteractions
    );
    DML_REPOSITORY.doInsert(recordsToInsert);
  }

  /**
   * @description This function builds a list of Associated Loan Application records from the given mapping.
   * @param interactions List of Interaction Ids to Loan Application Ids
   * @return List<Associated_Loan_Application__c> List of records to insert
   */
  @TestVisible
  private static List<Associated_Loan_Application__c> buildAssociatedLoanApplication(
    List<Interaction> interactions
  ) {
    List<Associated_Loan_Application__c> appList = new List<Associated_Loan_Application__c>();

    for (Interaction record : interactions) {
      appList.add(
        new Associated_Loan_Application__c(
          Interaction__c = record.Id,
          Residential_Loan_Application__c = record.Loan_Application__c
        )
      );
    }
    return appList;
  }

  /**
   * @description This function updates Associated Loan Application records based on changes to Interactions.
   * @param newRecords New Interaction records
   * @param oldRecordMap Old Interaction record map
   */
  public static void updateAssociatedLoanApplication(
    List<Interaction> newRecords,
    Map<Id, SObject> oldRecordMap
  ) {
    List<Interaction> modifiedInteractions = (List<Interaction>) ListUtil.filter(
        newRecords,
        oldRecordMap
      )
      .changed(Interaction.Loan_Application__c)
      .toList();
    List<Associated_Loan_Application__c> existingApps = new List<Associated_Loan_Application__c>();

    Set<Id> modifiedInteractionIds = ListUtil.getIds(
      modifiedInteractions,
      Interaction.Id
    );
    existingApps = ASSOCIATED_APP_REPOSITORY.getRelatedLoanApplication(
      modifiedInteractionIds
    );

    Map<Id, Associated_Loan_Application__c> associatedApplicationMap = (Map<Id, Associated_Loan_Application__c>) ListUtil.mapBy(
      existingApps,
      Associated_Loan_Application__c.Residential_Loan_Application__c
    );
    List<Associated_Loan_Application__c> recordsToInsert = getAssociatedLoanApplicationsToInsert(
      modifiedInteractions,
      oldRecordMap,
      associatedApplicationMap
    );

    List<Associated_Loan_Application__c> recordsToDelete = getAssociatedLoanApplicationsToDelete(
      modifiedInteractions,
      oldRecordMap,
      associatedApplicationMap
    );

    DML_REPOSITORY.doDelete(recordsToDelete);
    DML_REPOSITORY.doInsert(recordsToInsert);
  }

  /**
   * @description This function determines which Associated Loan Application records to insert based on Interaction changes.
   * @param modifiedInteractions Modified Interaction records
   * @param oldRecordMap Old Interaction record map
   * @param associatedApplicationMap Existing Associated Loan Application records map
   * @return List<Associated_Loan_Application__c> contains lists of records to insert
   */
  public static List<Associated_Loan_Application__c> getAssociatedLoanApplicationsToInsert(
    List<Interaction> modifiedInteractions,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedApplicationMap
  ) {
    List<Associated_Loan_Application__c> recordsToInsert = new List<Associated_Loan_Application__c>();
    for (Interaction interaction : modifiedInteractions) {
      Id interactionId = interaction.Id;
      Id oldLoanAppId = ((Interaction) oldRecordMap.get(interactionId))
        .Loan_Application__c;
      Id newLoanAppId = interaction.Loan_Application__c;

      Associated_Loan_Application__c existingnewApp = associatedApplicationMap.get(
        newLoanAppId
      );
      if (newLoanAppId == null || existingnewApp != null) {
        continue;
      }
      if (newLoanAppId != oldLoanAppId) {
        recordsToInsert.add(
          new Associated_Loan_Application__c(
            Interaction__c = interactionId,
            Residential_Loan_Application__c = newLoanAppId
          )
        );
      }
    }
    return recordsToInsert;
  }

  /**
   * @description This function determines which Associated Loan Application records to delete based on Interaction changes.
   * @param modifiedInteractions Modified Interaction records
   * @param oldRecordMap Old Interaction record map
   * @param associatedApplicationMap Existing Associated Loan Application records map
   * @return List<Associated_Loan_Application__c> contains lists of records to delete
   */
  public static List<Associated_Loan_Application__c> getAssociatedLoanApplicationsToDelete(
    List<Interaction> modifiedInteractions,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedApplicationMap
  ) {
    List<Associated_Loan_Application__c> recordsToDelete = new List<Associated_Loan_Application__c>();
    for (Interaction interaction : modifiedInteractions) {
      Id interactionId = interaction.Id;
      Id oldLoanAppId = ((Interaction) oldRecordMap.get(interactionId))
        .Loan_Application__c;
      Id newLoanAppId = interaction.Loan_Application__c;
      Associated_Loan_Application__c existingApp = associatedApplicationMap.get(
        oldLoanAppId
      );
      if (existingApp == null) {
        continue;
      }
      if (oldLoanAppId != newLoanAppId) {
        recordsToDelete.add(existingApp);
      }
    }
    return recordsToDelete;
  }
}
