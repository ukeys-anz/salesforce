/**
 * @author Afreen Khan, Olivier Saier, Ankita Nair
 * @since 03/2021
 * @description Contains Complaints Assignment rules conditions
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseAssignmentRulesTest
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class IDRCaseAssignmentRules {
  private static final IDRCaseActionsRepository CASE_REPOSITORY = (IDRCaseActionsRepository) Lib_InstanceProvider.forType(
    IDRCaseActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static Set<String> caseStatuses = new Set<String>{
    IDRConstants.PROVISIONALLY_CLOSED_STATUS,
    IDRConstants.CLOSED_STATUS
  };
  private static Set<String> oldcaseStatus = new Set<String>{
    IDRConstants.ESCALATED_STATUS,
    IDRConstants.ON_HOLD_STATUS
  };
  private static Set<String> earlyResolutionTypes = new Set<String>{
    '13',
    '12',
    '9'
  };

  private static Set<String> hardshipTypes = new Set<String>{ '4', '17' };

  /**
   * @description method to call the Case assignment rules
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignCases(Case[] cases, Map<Id, Case> oldMap) {
    for (Case c : cases) {
      if (
        !IDRCaseActions.isIDRComplaintType(c) || c.IDR_Product_Family__c == null
      ) {
        continue;
      }
      Case oldCase = oldMap.get(c.Id);
      c.OwnerId = getOwnerIdForEscalatedCases(c, oldCase);
    }
  }
  /**
   * @description method to Assign product family
   * @param cases Records in the current context
   * @param oldMap old map of case record in current trigger context
   */
  public static void assignProductFamily(Case[] cases, Map<Id, Case> oldMap) {
    List<Case> casesUpdatedwithProduct = ListUtil.filter(cases, oldMap)
      .changed(Case.Product__c)
      .isNotNull(Case.Product__c)
      .toList();

    List<Case> casesUpdatedwithProductCategory = ListUtil.filter(cases, oldMap)
      .changed(Case.IDR_Product_Category__c)
      .isNotNull(Case.IDR_Product_Category__c)
      .toList();

    for (Case c : casesUpdatedwithProduct) {
      Case oldCase = oldMap.get(c.Id);
      if (!IDRCaseActions.isIDRComplaintType(c)) {
        continue;
      }
      if (
        oldCase == null ||
        IDRCaseActions.isANZPlusComplaintConvertedToIDR(oldCase, c)
      ) {
        c.IDR_Product_Family__c = QueryProducts.getById(c.Product__c)
          ?.IDR_Product_Family__c;
        c.IDR_Product_Category__c = QueryProducts.getById(c.Product__c)
          ?.IDR_Product_Family__r.IDR_ANZ_com_Product_Category__c;
      }
    }

    for (Case c : casesUpdatedwithProductCategory) {
      Case oldCase = oldMap.get(c.Id);
      if (c.RecordTypeId != RTCase.generalInquiryCmos) {
        continue;
      }
      if (oldCase == null || c.Origin != GetHelpConstants.ANZ_PLUS_WEB_ORIGIN) {
        c.IDR_Product_Family__c = QueryProductFamily.getByCategory(
            c.IDR_Product_Category__c
          )
          ?.Id;
      }
    }
  }

  /**
   * @description Assign cases that aren't escalated. Do this after any prior work has been done.
   * @param lstCases list of cases being updated
   * @param mpOldCases map of old version of cases
   */
  public static void assignUnescalatedCases(
    List<Case> lstCases,
    Map<Id, Case> mpOldCases
  ) {
    Case oOldCase;
    List<Case> lstUpdates = new List<Case>();
    Id idOwner;
    for (Case oCase : lstCases) {
      if (IDRCaseActions.isIDRComplaintType(oCase)) {
        oOldCase = (mpOldCases != null ? mpOldCases.get(oCase.Id) : null);
        idOwner = getOwnerId(oCase, oOldCase);
        if (oCase.OwnerId != idOwner) {
          lstUpdates.add(new Case(Id = oCase.Id, OwnerId = idOwner));
        }
      }
    }

    DML_REPOSITORY.updateRecords(
      lstUpdates,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description method to run the Case assignment rules conditions
   * @param rec case record
   * @param oldCase old record of case
   * @return Id ownerId
   * */
  @SuppressWarnings('PMD.NcssMethodCount')
  @TestVisible
  private static Id getOwnerIdForEscalatedCases(Case rec, Case oldCase) {
    if (rec.Status != IDRConstants.ESCALATED_STATUS) {
      return rec.OwnerId;
    }

    if (
      oldcaseStatus.contains(oldCase.Status) &&
      (oldCase.Status != rec.Status ||
      oldCase.RecordTypeId == rec.RecordTypeId)
    ) {
      return rec.OwnerId;
    }

    Product2 oProduct = QueryProducts.getById(rec.Product__c);
    String productCode = oProduct?.ANZ_Product_Code__c;

    Product_Family__c oProductFamily = QueryProductFamily.getById(
      rec.IDR_Product_Family__c
    );
    String productWorkbasketName = oProductFamily?.IDR_Workbasket__c;
    String strProductFamily = oProductFamily?.Name;

    //rules to run only on escalation

    //CEO or Board
    if (rec.Origin == '9' || rec.Origin == '10') {
      return QueryQueue.get('IDR_CEO').Id;
    }

    // Hardship
    if (hardshipTypes.contains(rec.Type)) {
      if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
        return QueryQueue.get('EDR_Hardship').Id;
      }
      return QueryQueue.get('IDR_Hardship').Id;
    }
    //Inappropriate lending/maladministration
    if (
      rec.IDR_Subsequent_Issue__c == '38' ||
      rec.IDR_Subsequent_Issue_2__c == '38' ||
      rec.IDR_Subsequent_Issue_3__c == '38'
    ) {
      if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
        return QueryQueue.get('Specialised_EarlyRes_Responsible_Lending').Id;
      }
      return QueryQueue.get('IDR_Responsible_Lending').Id;
    }

    if (rec.Origin == IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED) {
      if (
        String.isNotBlank(strProductFamily) &&
        strProductFamily.equals('Insurance/wealth products')
      ) {
        return QueryQueue.get('EDR_Wealth').Id;
      }
      if (rec.Type == 'Scam') {
        return QueryQueue.get('EDR_CM_Everyday_Banking_Wealth').Id; // EDR Scams
      }
      return QueryQueue.get('EDR_Early_Resolution').Id;
    }

    //Credit Reporting
    if (
      rec.Type == '19' ||
      rec.IDR_Issue_Type_2__c == '19' ||
      rec.IDR_Issue_Type_3__c == '19'
    ) {
      return QueryQueue.get('CCR_Complaints').Id;
    }

    // IDR ANZ Plus Rule #5 needs to be applied before Early Resolution Rule #7
    if (
      String.isNotBlank(productWorkbasketName) &&
      productWorkbasketName.equalsIgnoreCase('IDR_ANZ_Plus')
    ) {
      return QueryQueue.get('IDR_ANZ_Plus').Id;
    }
    // Fraud & Scams
    if (IDRConstants.FRAUD_SCAM_ISSUE_TYPE_COLLECTIONS.contains(rec.Type)) {
      if (rec.IDR_Subsequent_Issue__c == '109') {
        return QueryQueue.get('IDR_Spare').Id; // IDR Disputes
      }
      return QueryQueue.get('IDR_Scams').Id; // IDR Scams
    }
    //Deceased Estates
    if (
      (rec.Type == '16' && rec.IDR_Subsequent_Issue__c == '80') ||
      productWorkbasketName == 'IDR_Deceased_Estates'
    ) {
      return QueryQueue.get('IDR_Deceased_Estates').Id; // IDR Deceased Estates
    }
    // Simple Complaint on Unassisted Channel
    if (
      IDRConstants.IDR_EARLY_RESOLUTION.contains(rec.Origin) &&
      String.isNotBlank(rec.IDR_Inbox_Email_Address__c) &&
      (!rec.IDR_Second_Issue__c && !rec.IDR_Third_Issue__c) &&
      IDRConstants.IDR_UNASSISTED_ISSUE_TYPE.contains(rec.Type) &&
      IDRConstants.IDR_UNASSISTED_SUB_ISSUE_TYPE.contains(
        rec.IDR_Subsequent_Issue__c
      )
    ) {
      return QueryQueue.get('IDR_Early_Resolution_Unassisted_Channel').Id;
    }

    // Early Resolution
    if (earlyResolutionTypes.contains(rec.Type)) {
      return QueryQueue.get('IDR_Early_Resolution').Id;
    }

    if (String.isNotBlank(productCode) && productCode.equals('231')) {
      return QueryQueue.get('IDR_Everyday_Banking').Id;
    }

    //Product-based rules
    if (String.isNotBlank(productWorkbasketName)) {
      return QueryQueue.get(productWorkbasketName).Id;
    }

    //Default workbasket
    return QueryQueue.get('IDR_Early_Resolution').Id;
  }

  /**
   * @description get OwnerId without product workbasket
   * @param newCase Case record
   * @param oldCase Previous version of Case record
   * @return Id Calculated Owner Id
   */
  @TestVisible
  private static Id getOwnerId(Case newCase, Case oldCase) {
    if (
      (!caseStatuses.contains(newCase.Status) &&
      oldCase != null &&
      oldCase.Status == IDRConstants.ESCALATED_STATUS)
    ) {
      return newCase.OwnerId;
    }
    if (
      isValidIssueType(newCase) &&
      (CASE_REPOSITORY.checkUserPermission('IDR_Level_2') ||
      CASE_REPOSITORY.checkUserPermission('IDR_Level_3'))
    ) {
      //To auto assign cases to the workbasket 'Hardship_IDR_Letter'
      return QueryQueue.get('IDR_Everyday_Banking').Id;
    }
    return newCase.OwnerId;
  }

  /**
   * @description check for valid Issue & Sub Issue Types
   * @param newCase Case record
   * @return Boolean which indicates if its a Valid combination
   */
  public static Boolean isValidIssueType(Case newCase) {
    Boolean isValidIssueSubIssueType = false;
    if (
      (newCase.Type == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        newCase.IDR_Subsequent_Issue__c
      )) ||
      (newCase.IDR_Issue_Type_2__c == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        newCase.IDR_Subsequent_Issue_2__c
      )) ||
      (newCase.IDR_Issue_Type_3__c == '4' &&
      IDRConstants.SUB_ISSUE_TYPE_HARDSHIP.contains(
        newCase.IDR_Subsequent_Issue_3__c
      ))
    ) {
      isValidIssueSubIssueType = true;
    }
    return isValidIssueSubIssueType;
  }

  /**
   * @description method to get a map of ANZx workbasket queues, API names and Ids
   * @return a map of workbasket queues, API names and Ids
   */
  public static Map<String, Id> getAnzxWorkbaskets() {
    Map<String, Group> anzxWorkBaskets = QueryQueue.get(
      GetHelpConstants.workBasketNames
    );
    Map<String, Id> anzxWorkBasketsById = new Map<String, Id>();
    for (Group g : anzxWorkBaskets.values()) {
      anzxWorkBasketsById.put(g.DeveloperName, g.Id);
    }
    return anzxWorkBasketsById;
  }
}
