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
   * @description This function creates Associated Loan Application records for the given list of Interactions.
   * @param records List of Interaction records from the trigger
   */
  public static void createAssociatedLoanApplication(
    List<Interaction> records
  ) {
    Map<Id, Id> interactionIdVsRLAMap = getInteractionToAppMap(records);
    List<Associated_Loan_Application__c> recordsToInsert = buildAssociatedLoanApplication(
      interactionIdVsRLAMap
    );

    try {
      DML_REPOSITORY.doInsert(recordsToInsert, new DmlConfig().allowPartial());
    } catch (exception e) {
      logException(e);
    }
  }

  /**
   * @description This function maps each Interaction Id to its corresponding Loan Application Id.
   * @param interactions List of Interaction records
   * @return Map<Id, Id> Map of Interaction Ids to Loan Application Ids
   */
  @TestVisible
  public static Map<Id, Id> getInteractionToAppMap(
    List<Interaction> interactions
  ) {
    Map<Id, Id> interactionIdVsAppMap = new Map<Id, Id>();
    for (Interaction i : interactions) {
      interactionIdVsAppMap.put(i.Id, i.Loan_Application__c);
    }
    return interactionIdVsAppMap;
  }

  /**
   * @description This function builds a list of Associated Loan Application records from the given mapping.
   * @param interactionToAppMap Map of Interaction Ids to Loan Application Ids
   * @return List<Associated_Loan_Application__c> List of records to insert
   */
  @TestVisible
  public static List<Associated_Loan_Application__c> buildAssociatedLoanApplication(
    Map<Id, Id> interactionToAppMap
  ) {
    List<Associated_Loan_Application__c> appList = new List<Associated_Loan_Application__c>();

    for (Id interactionId : interactionToAppMap.keySet()) {
      appList.add(
        new Associated_Loan_Application__c(
          Interaction__c = interactionId,
          Residential_Loan_Application__c = interactionToAppMap.get(
            interactionId
          )
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

    if (modifiedInteractions.isEmpty()) {
      return;
    }

    Map<Id, Id> interactionToNewAppMap = getInteractionToAppMap(
      modifiedInteractions
    );
    List<Associated_Loan_Application__c> existingApps = ASSOCIATED_APP_REPOSITORY.getRelatedLoanApplication(
      interactionToNewAppMap.keySet()
    );

    Map<Id, Associated_Loan_Application__c> associatedApplicationMap = (Map<Id, Associated_Loan_Application__c>) ListUtil.mapBy(
      existingApps,
      Associated_Loan_Application__c.Residential_Loan_Application__c
    );
    AssociatedLoanApplicationChange changes = modifyAssociatedLoanApplication(
      modifiedInteractions,
      oldRecordMap,
      associatedApplicationMap
    );

    try {
      DML_REPOSITORY.doDelete(
        changes.appsToDelete,
        new DmlConfig().allowPartial()
      );
      DML_REPOSITORY.doInsert(
        changes.appsToInsert,
        new DmlConfig().allowPartial()
      );
    } catch (Exception e) {
      logException(e);
    }
  }

  /**
   * @description This function determines which Associated Loan Application records to insert or delete based on Interaction changes.
   * @param modifiedInteractions Modified Interaction records
   * @param oldRecordMap Old Interaction record map
   * @param associatedApplicationMap Existing Associated Loan Application records map
   * @return AssociatedLoanApplicationChange contains lists of records to insert and delete
   */
  public static AssociatedLoanApplicationChange modifyAssociatedLoanApplication(
    List<Interaction> modifiedInteractions,
    Map<Id, SObject> oldRecordMap,
    Map<Id, Associated_Loan_Application__c> associatedApplicationMap
  ) {
    AssociatedLoanApplicationChange changeSet = new AssociatedLoanApplicationChange();

    for (Interaction interaction : modifiedInteractions) {
      Id interactionId = interaction.Id;
      Id oldLoanAppId = ((Interaction) oldRecordMap.get(interactionId))
        .Loan_Application__c;
      Id newLoanAppId = interaction.Loan_Application__c;

      Associated_Loan_Application__c existingApp = associatedApplicationMap.get(
        oldLoanAppId
      );

      Boolean isRemoved = (existingApp != null && newLoanAppId == null);
      Boolean isChanged = (existingApp != null && oldLoanAppId != newLoanAppId);
      Boolean isAdded = (oldLoanAppId == null && newLoanAppId != null);
      if (isRemoved || isChanged) {
        changeSet.appsToDelete.add(existingApp);
      }

      if (isAdded || isChanged) {
        changeSet.appsToInsert.add(
          new Associated_Loan_Application__c(
            Interaction__c = interactionId,
            Residential_Loan_Application__c = newLoanAppId
          )
        );
      }
    }
    return changeSet;
  }

  /**
   * @description This class holds the lists of Associated Loan Application records to insert or delete.
   */
  public class AssociatedLoanApplicationChange {
    public List<Associated_Loan_Application__c> appsToInsert;
    public List<Associated_Loan_Application__c> appsToDelete;
    /**
     * @description AssociatedLoanApplicationChange constructor.
     */
    public AssociatedLoanApplicationChange() {
      appsToInsert = new List<Associated_Loan_Application__c>();
      appsToDelete = new List<Associated_Loan_Application__c>();
    }
  }
  @TestVisible
  private static void logException(Exception e) {
    Logger.error(e.getMessage(), e);
    Logger.saveLog();
    throw e;
  }
}
