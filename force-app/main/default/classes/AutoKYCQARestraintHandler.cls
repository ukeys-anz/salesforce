/**
 * @author Tan Phan
 * @since 06/2024
 * @description This class represents the profile staging handler for the AutoKYCQA restraint event.
 */
public with sharing class AutoKYCQARestraintHandler {
  private static final AutoKYCQACaseRepository REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );
  private static final ProfileStagingHandler HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

  private static final String SPECIAL_COMMENT_1 = 'KYC QA defects found -';
  private static final String SPECIAL_COMMENT_2 = 'do not remove until clarified -';
  private static final String SPECIAL_COMMENT_3 = 'call ID OPS 030-4050-7838';

  /**
   * @description Processes the records for AutoKYCQA restraint.
   * @param records The list of Account records.
   * @param mapAccIdToCase The map of Account Id to Case.
   */
  public void process(List<Account> records, Map<Id, Case> mapAccIdToCase) {
    if (REPOSITORY.isRestraintEnabled() == false) {
      return;
    }
    List<Customer_Profile_Updates__c> updates = this.generateUpdates(
      records,
      mapAccIdToCase
    );
    HANDLER.process(updates);
  }

  @TestVisible
  private List<Customer_Profile_Updates__c> generateUpdates(
    List<Account> records,
    Map<Id, Case> mapAccIdToCase
  ) {
    List<Customer_Profile_Updates__c> updates = new List<Customer_Profile_Updates__c>();
    for (Account acc : records) {
      for (
        FinServ__FinancialAccount__c fa : acc.FinServ__ClientFinancialAccounts__r
      ) {
        Case kycCase = mapAccIdToCase.get(acc.Id);
        updates.add(this.generateUpdate(fa, kycCase, 60));
        updates.add(this.generateUpdate(fa, kycCase, 61));
      }
    }
    return updates;
  }

  @TestVisible
  private Customer_Profile_Updates__c generateUpdate(
    FinServ__FinancialAccount__c fa,
    Case kycCase,
    Integer type
  ) {
    Customer_Profile_Updates__c cpu = HANDLER.templateCpu;
    cpu.Action__c = 'Update';
    cpu.Object_Name__c = 'Case';
    cpu.Customer_Name__c = kycCase.AccountId;
    cpu.TriggeredFrom__c = 'Case.KYC_QA.AddRestraints';
    cpu.NewValue__c = 'Apply Restraints Type ' + type + ' of Class Hard Hold';
    cpu.Name = String.format(
      'KYC QA Case {0} Add Type {1} Restraint on {2}',
      new List<String>{
        kycCase.CaseNumber,
        String.valueOf(type),
        fa.FinServ__FinancialAccountNumber__c
      }
    );
    cpu.ToBeValue__c = createRestraintPayload(fa, type);
    return cpu;
  }

  @TestVisible
  private String createRestraintPayload(
    FinServ__FinancialAccount__c fa,
    Integer restraintType
  ) {
    CustomerRestraintModel model = new CustomerRestraintModel();
    model.accountNumber = fa.FinServ__FinancialAccountNumber__c;
    model.productCode = fa.Product_Type__c.split(':')[1];
    model.restraints.restraintClass = 1;
    model.restraints.restraintType = restraintType;
    // API is not accepting 9999-12-31 atm to be updated later
    model.restraints.dateExpires = System.now()
      .addDays(475)
      .format('YYYY-MM-dd');
    model.restraints.specialComment1 = SPECIAL_COMMENT_1;
    model.restraints.specialComment2 = SPECIAL_COMMENT_2;
    model.restraints.specialComment3 = SPECIAL_COMMENT_3;
    return JSON.serialize(model, true);
  }
}
