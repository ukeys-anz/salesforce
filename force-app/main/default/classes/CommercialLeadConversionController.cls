/**
 * @author       : Advait Yermalkar
 * @since        : 02-07-2025
 * @description  :
 **/
public with sharing class CommercialLeadConversionController {
  /**
   * @description Converts ETB/NTB Organization Leads using Maintain Party Api.Used by lwc leadConvertToOpportunity.cmp
   * @param record Lead Record
   * @return MaintainPartyInformationWrapper.MaintainPartyInfoWrapper
   **/
  @AuraEnabled
  public static MaintainPartyInformationWrapper.MaintainPartyInfoWrapper convertOrganizationLead(
    Lead record
  ) {
    try {
      MaintainPartyInformationWrapper.MaintainPartyInfoWrapper maintainResult = new MaintainPartyInformationWrapper.MaintainPartyInfoWrapper();
      CCRMAPIRepository ccrmapi = new CCRMAPIRepository();
      DCRMMaintainPartyModel result;
      CommercialLeadConversionHelper leadConvHelper = new CommercialLeadConversionHelper();
      OCVRequestPayloadWrapper requestRecord = leadConvHelper.getRequestRecordOrganization(
        record
      );
      // call maintain party Api and get result
      result = ccrmapi.maintainPartyOrganisation(requestRecord);
      if (result.newCustomer == null || result.ocvId == null) {
        Logger.error(Label.MLCRM_MaintainParty_NewCustomerError, record.Id)
          .save();
        throw new CommercialLeadConversionHelper.CustomException(
          Label.MLCRM_MaintainParty_NewCustomerError
        );
      }

      // NTB Customers Logic
      if (result.newCustomer == 'true') {
        Account accInstance = CommercialLeadConversionHelper.autoCreateShellProspect(
          requestRecord,
          result
        );
        maintainResult.oppID = '';
        maintainResult.isNewCustomer = true;
        if (accInstance == null || accInstance?.id == null) {
          maintainResult.oppID = '';
          Logger.error('Shell Customer Creation Failure.', record.Id).save();
          throw new CommercialLeadConversionHelper.CustomException(
            'Shell Customer Creation Failure.'
          );
        }
        maintainResult.oppID = CommercialLeadConversionHelper.updateLeadWithCapcisId(
          record,
          result,
          accInstance
        );
      } else {
        //ETB Customers Logic
        maintainResult = CommercialLeadConversionHelper.getExistingCustomerDetails(
          requestRecord,
          result
        );
      }
      return maintainResult;
    } catch (Exception e) {
      Logger.error(e.getMessage(), record.Id).save();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Convert CCRM Lead for matched maintain party Existing Customer
   * @name convertOrganizationMatchedLead
   * @param accId get account id matched for lead conversion
   * @param cpId get cpid from ocv reponse
   * @param record The Lead record to convert
   * @return string  opportunity id created from lead conversion
   */
  @AuraEnabled(cacheable=false)
  public static String convertOrganizationMatchedLead(
    String accId,
    String cpId,
    Lead record
  ) {
    if (String.isBlank(accId)) {
      throw new AuraHandledException(
        Label.MLCRM_AccountBlank_LeadConversionError
      );
    }
    if (String.isBlank(cpId)) {
      throw new AuraHandledException(
        Label.MLCRM_CAPCISIdBlank_LeadConversionError
      );
    }
    try {
      String opportunityId = CommercialLeadConversionHelper.updateAndConvertMatchedLead(
        accId,
        cpId,
        record
      );
      return opportunityId;
    } catch (Exception e) {
      Logger.error(e.getMessage(), record.Id).save();
      throw new AuraHandledException(e.getMessage());
    }
  }
}
