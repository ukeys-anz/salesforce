/**
 * @author Ashish Kumar
 * @since 06/2025
 * @description class for Mobile Lending settlement actions
 */
public with sharing class MobileLendingSettlementActions {
  private static final ResidentialLoanApplicationRepository RESIDENTIAL_LOAN_APP_REPOSITORY = (ResidentialLoanApplicationRepository) Lib_InstanceProvider.forType(
    ResidentialLoanApplicationRepository.class
  );
  @TestVisible
  private static final Map<String, String> LOAN_APPLICATION_STATUSES = new Map<String, String>{
    'Unspecified' => 'Documents',
    'New' => 'Documents',
    'Initiated' => 'Documents',
    'Declined' => 'Documents',
    'Documents Generated' => 'Documents',
    'Offer Committed' => 'Closed - Won',
    'Settling' => 'Settlement',
    'Settlement Completed' => 'Closed - Won'
  };
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description To filter out the Settlemnt record with broker and lanid and status changed
   * @param records Settlement records from trigger on update
   * @param oldMap Holds records information before update
   */
  public static void updateOpportunityFromSettlement(
    List<Settlement__c> records,
    Map<Id, Settlement__c> oldMap
  ) {
    Set<Id> idsOfSettlement = ListUtil.getIds(
      records,
      Settlement__c.Loan_Application_Number__c
    );
    List<ResidentialLoanApplication> lstOfRLA = RESIDENTIAL_LOAN_APP_REPOSITORY.queryResidentialLoanApplication(
      idsOfSettlement
    );
    Set<Id> filteredRLAIds = ListUtil.getIds(
      lstOfRLA,
      ResidentialLoanApplication.Id
    );
    Map<Id, ResidentialLoanApplication> rlaMap = (Map<Id, ResidentialLoanApplication>) ListUtil.mapBy(
      lstOfRLA,
      ResidentialLoanApplication.Id
    );
    List<Settlement__c> filteredSettlement = ListUtil.filter(records, oldMap)
      .equals(Settlement__c.Loan_Application_Number__c, filteredRLAIds)
      .changed(Settlement__c.Status__c)
      .toList();

    updateOpportunity(filteredSettlement, rlaMap);
  }

  /**
   * @description To update ML Opportunity on Settlement insertion/updation
   * @param records Settlement records from trigger on insert/update
   * @param rlaMap Holds RLA records information
   */
  @TestVisible
  private static void updateOpportunity(
    List<Settlement__c> records,
    Map<Id, ResidentialLoanApplication> rlaMap
  ) {
    List<Opportunity> lstOfOppToUpdate = new List<Opportunity>();
    for (Settlement__c eachSettlement : records) {
      Opportunity oppToUpdate = new Opportunity();
      oppToUpdate.Id = rlaMap.get(eachSettlement.Loan_Application_Number__c)
        .OpportunityId;
      oppToUpdate.stageName = LOAN_APPLICATION_STATUSES.get(
        eachSettlement.Status__c
      );
      lstOfOppToUpdate.add(oppToUpdate);
    }
    DML_REPOSITORY.doUpdate(lstOfOppToUpdate, new DmlConfig().allowPartial());
  }
}
