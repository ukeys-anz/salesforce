/**
 * @author Vidhya
 * @since September 2023
 * @description Helper for Model for SOP
 */

public with sharing class SOPModelHelper {
  public static final String EQUIFAX = 'EQUIFAX';
  public static final String EQUIFAX_LC = 'Equifax';
  public static final String EXPERIAN = 'EXPERIAN';
  public static final String EXPERIAN_LC = 'Experian';
  public static final String ILLION = 'ILLION';
  public static final String ILLION_LC = 'Illion';
  /**
   * @description returns the owner Name for Confirmation status section of Connect Data flexcard
   * @param sop
   */
  public static void enrichOwnerName(SOPModel sop) {
    Map<String, String> partyIdToOcvIdMap = new Map<String, String>();
    Set<String> ocvIdSet = new Set<String>();
    Map<String, String> ocvIdToNameMap = new Map<String, String>();
    for (SOPModel.Parties party : sop.parties) {
      if (party.ocvId != null) {
        ocvIdSet.add(party.ocvId);
        partyIdToOcvIdMap.put(party.id, party.ocvId);
      }
    }
    if (ocvIdSet.size() > 0 && PermissionUtils.canAccess('Account')) {
      for (Account acc : [
        SELECT ocv_id__c, FirstName
        FROM Account
        WHERE ocv_id__c IN :ocvIdSet
      ]) {
        ocvIdToNameMap.put(acc.ocv_id__c, acc.FirstName);
      }
    }
    for (SOPModel.Parties party : sop.parties) {
      party.ownerName = ocvIdToNameMap.get(party.ocvId);
    }
  }

  /**
   * @description returns the owner Name for Credit Bureau section of Finance and savings flexcard
   * @param sop
   */
  public static void enrichSourcesOwnerName(
    ResidentialLoanApplicationModel sop
  ) {
    Map<String, String> partyIdToNameMap = new Map<String, String>();
    Map<String, String> partyIdToOcvIdMap = new Map<String, String>();
    Set<String> ocvIdSet = new Set<String>();
    Map<String, String> ocvIdToNameMap = new Map<String, String>();
    for (ResidentialLoanApplicationModel.SOPParty party : sop.sop.parties) {
      if (party.ocvId != null) {
        ocvIdSet.add(party.ocvId);
        partyIdToOcvIdMap.put(party.id, party.ocvId);
      }
    }
    if (ocvIdSet.size() > 0 && PermissionUtils.canAccess('Account')) {
      for (Account acc : [
        SELECT ocv_id__c, FirstName
        FROM Account
        WHERE ocv_id__c IN :ocvIdSet
      ]) {
        ocvIdToNameMap.put(acc.ocv_id__c, acc.FirstName);
      }
    }
    for (SOPLiabilitySources source : sop.liabilitiesSummary.partyLiabilities) {
      source.ownerName = ocvIdToNameMap.get(
        partyIdToOcvIdMap.get(source.partyId)
      );
    }
  }
  /*for (SOPModel.Parties party : sop.parties) {
      party.ownerName = ocvIdToNameMap.get(party.ocvId);
    }*/
  /**
   * @description init method
   * @param sop
   */
  public static void initPartyLiability(ResidentialLoanApplicationModel sop) {
    Map<String, SOPLiabilitySources> partyLiabilityMap = new Map<String, SOPLiabilitySources>();

    for (SOPDebtSources source : sop.liabilitiesSummary.sources) {
      SOPLiabilitySources partyLiability = partyLiabilityMap.get(
        source.partyId
      );
      if (partyLiability == null) {
        partyLiability = new SOPLiabilitySources();
        partyLiability.partyId = source.partyId;
        partyLiabilityMap.put(source.partyId, partyLiability);
      }
      if (source.subType == EQUIFAX) {
        partyLiability.liabilitySourceEquifax = source;
        partyLiability.liabilitySourceEquifax.subType = EQUIFAX_LC;
      } else if (source.subType == EXPERIAN) {
        partyLiability.liabilitySourceExperian = source;
        partyLiability.liabilitySourceExperian.subType = EXPERIAN_LC;
      } else if (source.subType == ILLION) {
        partyLiability.liabilitySourceIllion = source;
        partyLiability.liabilitySourceIllion.subType = ILLION_LC;
      }
      sop.liabilitiesSummary.partyLiabilities = partyLiabilityMap.values();
    }
  }
}
