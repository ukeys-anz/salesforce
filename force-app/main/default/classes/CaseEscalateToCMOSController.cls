/**
 * @author Mouhamed "Mo" Assafiri
 * @since Oct 2021
 * @description  Exposes the manual escalation to Aura component.
 */

public with sharing class CaseEscalateToCMOSController {
  @AuraEnabled
  /**
   * @description Manually Triggers the Case to Escalate to CMOS from Aura component
   * @param recordId The record ID that will be escalated
   * @return boolean - Returns manualEscalationCaseToCMOS Function result
   */
  public static Boolean actionEscalateCaseToCMOS(String recordId) {
    Case record = new Case(id = recordId);

    if (CaseEscalateToCMOS.manualEscalateCaseToCMOS(record)) {
      return true;
    } else {
      throw new AuraHandledException(
        'Could not escalate to Case. Please contact support for more assistance. Error code: CMOSESC-001'
      );
    }
  }
}
