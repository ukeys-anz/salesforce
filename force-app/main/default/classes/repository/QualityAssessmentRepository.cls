/**
 * @author Aman
 * @since 05/2025
 * @description Repository Class from Quality Assessment Actions
 */
public with sharing class QualityAssessmentRepository {
  /**
   * @description getQAShareRecords return share record for the given QA Ids
   * @param parentIds Quality_Assessment__c records
   * @return list of share records
   */
  public List<Quality_Assessment__Share> getQAShareRecords(
    List<Quality_Assessment__c> parentIds
  ) {
    if (parentIds.isEmpty()) {
      return new List<Quality_Assessment__Share>();
    }
    return [
      SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
      FROM Quality_Assessment__Share
      WHERE ParentId IN :parentIds AND RowCause IN ('Manual', 'ApexSharing__c')
      WITH USER_MODE
    ];
  }

  /**
   * @description getRlaByCustomer return count of RLA by customer
   * @param accountIds set<Ids>
   * @return list of AggregateResult records
   */
  public List<AggregateResult> getRlaByCustomer(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<AggregateResult>();
    }
    return [
      SELECT COUNT(ID) rlaCount, AccountId
      FROM ResidentialLoanApplication
      WHERE AccountId IN :accountIds
      WITH USER_MODE
      GROUP BY AccountId
    ];
  }

  /**
   * @description getRlaByIds return count of RLA by Ids
   * @param rlaIds ResidentialLoanApplication Ids
   * @return list of share records
   */
  public List<ResidentialLoanApplication> getRlaByIds(Set<Id> rlaIds) {
    if (rlaIds.isEmpty()) {
      return new List<ResidentialLoanApplication>();
    }
    return [
      SELECT Id, AccountId, OwnerId
      FROM ResidentialLoanApplication
      WHERE Id IN :rlaIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get related interaction by ids
   * @param interactionIds interaction ids
   * @return  `Map<Id, Interaction>` map of interaction
   */
  public Map<Id, Interaction> getInteractions(Set<Id> interactionIds) {
    return new Map<Id, Interaction>(
      [
        SELECT Id, CreatedDate, Lead__c, CaseId__c, AccountId
        FROM Interaction
        WHERE Id IN :interactionIds
      ]
    );
  }

  /**
   * @description method to get details of related case fields for set of QA records
   * @param qaRecordIds set of quality assessment record Ids
   * @return list of Quality Assessment Records with case Details
   */
  public List<Quality_Assessment__c> getRelatedCaseDetailsForQARecords(
    Set<Id> qaRecordIds
  ) {
    if (qaRecordIds.isEmpty()) {
      return new List<Quality_Assessment__c>();
    }
    return [
      SELECT
        Id,
        OwnerId,
        Evaluation_Type__c,
        RecordTypeId,
        Interaction_Type__c,
        Interaction_Date_Time__c,
        Related_Case__c,
        Related_Case__r.CaseNumber,
        Related_Case__r.Owner.Type,
        Related_Case__r.OwnerId,
        Related_Case__r.Origin,
        Related_Case__r.AccountId,
        Related_Case__r.ClosedDate,
        toLabel(Related_Case__r.Type),
        toLabel(Related_Case__r.IDR_Subsequent_Issue__c)
      FROM Quality_Assessment__c
      WHERE Id IN :qaRecordIds
    ];
  }

  /**
   * @description method to get details of related case fields for set of case records
   * @param caseIds set of caseIds
   * @return list of Case records
   */
  public List<Case> getUserDetailsFromCase(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, OwnerId, Owner.Type, CaseOwnerManager__c
      FROM Case
      WHERE Id IN :caseIds
    ];
  }

  /**
   * @description getQARecordById return QA record by Id
   * @param recordId QA Id
   * @return QA Record
   */
  public Quality_Assessment__c getQARecordById(Id recordId) {
    return [
      SELECT
        Id,
        Evaluation_Type__c,
        Connection_and_Trust__c,
        Discover_and_Align__c,
        Actions_and_Momentum__c,
        Accountability_and_Next_Steps__c,
        Energy_and_Adaptability__c,
        Preparation_and_Framing__c,
        Insights_and_Focus__c,
        Finishing_Touches__c,
        Risk_and_Compliance_Category__c,
        Advice_Initial_Contact__c,
        Advice_Define_Scope__c,
        Advice_Customer_understanding_of_scope__c,
        Key_scoping_and_disclaimers__c,
        Advice_Limit_scope_of_advice__c,
        Advice_Decline_advice_and_refer__c,
        Advice_Substantive_Advice_OFSN__c,
        Join_Actions_Taken__c,
        Join_Blocks_Applied_where_Appropriate__c,
        Join_Case_Data_Field_Accuracy__c,
        Join_Case_Record_Accuracy__c,
        Join_Compliance_Behaviour__c,
        Join_Compliance_Disclaimers__c,
        Join_Compliance_Identification__c,
        Join_Compliance_Information__c,
        Join_Financial_Operation_Accuracy__c,
        Join_Overall_Decision_Supported__c,
        Join_Business_Actions_Taken__c,
        Join_Business_Case_Record__c,
        Join_Business_Information__c,
        Join_Customer_Accountable__c,
        Join_Customer_Caring__c,
        Join_Customer_Interested__c,
        Join_Customer_Respect__c,
        Join_Customer_Welcoming__c,
        Advice_Fact_Find__c,
        CN_Fact_Find__c,
        Advice_Best_Interest_Duty__c,
        Advice_Dispute_Resolution__c,
        Advice_Incomplete_Inaccurate_warning__c,
        CN_Customers_Focus__c,
        CN_Substantive_Advice__c,
        CN_Out_of_Scope__c,
        CN_OFSN__c,
        CN_Scope_Provided__c,
        RecordTypeId,
        CN_Checklist__c
      FROM Quality_Assessment__c
      WHERE Id = :recordId
      LIMIT 1
    ];
  }
}
