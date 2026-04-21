/**
 * @author       : Kritika Sharma
 * @since        : Feb 2026
 * @description  : Controller for exportFailedReferrels LWC to re-publish cloud events.
 **/
public with sharing class ExportFailedReferralsController {
  @testVisible
  private static final String STATUS_EXPORT_FAILED = 'Export Failed';
  @testVisible
  private static final String STATUS_IN_PROGRESS = 'In Progress';

  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CommercialReferralLeadRepository LEAD_REPO = (CommercialReferralLeadRepository) Lib_InstanceProvider.forType(
    CommercialReferralLeadRepository.class
  );

  /**
   * @description : Retries exporting the referral. Validates status, republishes events, then updates status.
   * @param leadId : Id of the lead record.
   */
  @AuraEnabled
  public static void retryReferralExport(Id leadId) {
    try {
      List<Lead> leads = LEAD_REPO.getLeadsById(new Set<Id>{ leadId });
      Lead ld = leads[0];

      // Republish the events first
      CommercialReferralLeadActions.republishFailedEvents(new List<Lead>{ ld });

      // Update status to 'In Progress' after successful republish
      ld.Referral_Status__c = STATUS_IN_PROGRESS;
      DML_REPO.doUpdate(ld);
    } catch (Exception e) {
      Logger.error('Manual retry failed for referral : ' + leadId, e).save();
      throw new AuraHandledException(e.getMessage());
    }
  }
}
