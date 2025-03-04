/**
 * @author Tan Phan
 * @since 06/2024
 * @description This class represents the profile staging handler for the AutoKYCQA restraint event.
 */
public with sharing class AutoKYCQARestraintHandler {
  private static final String RESTRAINTS_EXPIRYDATE = '9999-12-31';
  private static final AutoKYCQACaseRepository REPOSITORY = (AutoKYCQACaseRepository) Lib_InstanceProvider.forType(
    AutoKYCQACaseRepository.class
  );
  private static final ProfileStagingHandler HANDLER = (ProfileStagingHandler) Lib_InstanceProvider.forType(
    ProfileStagingHandler.class
  );

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
        FinServ__FinancialAccountRole__c far : acc.FinServ__FinancialAccountRoles__r
      ) {
        FinServ__FinancialAccount__c fa = far.FinServ__FinancialAccount__r;
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
    cpu.Case__c = kycCase.Id;
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
    model.restraints.dateExpires = RESTRAINTS_EXPIRYDATE;
    model.restraints.specialComment1 = getSepcialCommentByIndex(0, 30);
    model.restraints.specialComment2 = getSepcialCommentByIndex(30, 60);
    model.restraints.specialComment3 = getSepcialCommentByIndex(60, 90);
    return JSON.serialize(model, true);
  }
  @TestVisible
  private string getSepcialCommentByIndex(
    Integer startIndex,
    Integer endIndex
  ) {
    String comment = Label.CustomerRestraintComment;
    if (startIndex < 0 || endIndex < 0 || startIndex > comment.length()) {
      return '';
    }
    if (endIndex > comment.length()) {
      return comment.substring(startIndex, comment.length());
    }
    return comment.substring(startIndex, endIndex);
  }
}
