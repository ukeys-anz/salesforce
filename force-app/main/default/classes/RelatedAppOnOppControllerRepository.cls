/**
 * @author       : Advait Yermalkar
 * @since        : 09-02-2024
 * @description  : Repository class for RelatedAppOnOppController
 **/
public with sharing class RelatedAppOnOppControllerRepository {
  /**
   * @description retrive ApplicationForms related to an Opportunity
   * @param opportunityId
   * @param pageSize
   * @param offSet
   * @return List<ApplicationForm>
   **/
  public List<ApplicationForm> getApplicationForms(
    Id opportunityId,
    Integer pageSize,
    Integer offSet
  ) {
    if (
      opportunityId == null ||
      pageSize == null ||
      offSet == null ||
      !PermissionUtils.canQuery('ApplicationForm') ||
      !PermissionUtils.canQuery('ApplicationFormProduct')
    ) {
      return new List<ApplicationForm>();
    }

    return [
      SELECT
        Id,
        Name,
        Application_Amount__c,
        Stage,
        SubmissionDate,
        Application_Number__c,
        Application_Status__c,
        (
          SELECT Id, Name, Stage, Product.Name, ProductId, Close_Date__c
          FROM ApplicationFormProducts
        )
      FROM ApplicationForm
      WHERE OpportunityId = :opportunityId
      LIMIT :pageSize
      OFFSET :offSet
    ];
  }

  /**
   * @description retrive total Applications Forms related to an Opportunity
   * @param opportunityId
   * @return Integer
   **/
  @AuraEnabled(cacheable=true)
  public static Integer getTotalRecords(Id opportunityId) {
    if (opportunityId == null || !PermissionUtils.canQuery('ApplicationForm')) {
      return 0;
    }

    return [
      SELECT COUNT()
      FROM ApplicationForm
      WHERE OpportunityId = :opportunityId
    ];
  }
}
