/**
 * @description controller class for cobTinView lwc
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
public with sharing class COBTaxResidencyViewController {
  @TestVisible
  private static final String FAILED_DETOKENIZATION = 'Failed to retrieve detokenized Tax Identification Number. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description method to retrieve detokenized Tax Residency TIN  and return to lwc component
   * @param cobTaxResidency COBTaxResidency__c record from the lwc component
   * @return String detokenized TIN
   */
  @AuraEnabled
  public static String detokenizeCOBTaxResidencyData(
    COBTaxResidency__c cobTaxResidency
  ) {
    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBTaxResidencyModel response;

    try {
      response = stravinskyApi.cobTaxResidencyDetokenization(cobTaxResidency);
    } catch (Exception e) {
      CommonUtil.throwException(FAILED_DETOKENIZATION);
    }

    return response?.values[0]?.detokenized;
  }
}
