/**
 * @author Vidhya
 * @since September 2023
 * @description Helper for Model for SOP
 */

public with sharing class SOPModelHelper {
  /**
   * @description returns the owner Name for Credit Bureau section of Connect Data flexcard
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
    for (SOPModel.PartyLiability partylib : sop.partyLiabilities) {
      partylib.ownerName = ocvIdToNameMap.get(
        partyIdToOcvIdMap.get(partylib.partyId)
      );
    }
  }

  /**
   * @description init method
   * @param sop
   */
  public static void initPartyLiability(SOPModel sop) {
    Map<String, SOPModel.PartyLiability> partyLiabilityMap = new Map<String, SOPModel.PartyLiability>();
    for (SOPModel.LiabilitySource source : sop.liabilitySources) {
      SOPModel.PartyLiability partyLiability = partyLiabilityMap.get(
        source.partyId
      );
      if (partyLiability == null) {
        partyLiability = new SOPModel.PartyLiability();
        partyLiability.partyId = source.partyId;
        partyLiabilityMap.put(source.partyId, partyLiability);
      }
      if (source.subType == SOPModel.EQUIFAX) {
        partyLiability.liabilitySourceEquifax = source;
        partyLiability.liabilitySourceEquifax.subType = SOPModel.EQUIFAX_LC;
      } else if (source.subType == SOPModel.EXPERIAN) {
        partyLiability.liabilitySourceExperian = source;
        partyLiability.liabilitySourceExperian.subType = SOPModel.EXPERIAN_LC;
      } else if (source.subType == SOPModel.ILLION) {
        partyLiability.liabilitySourceIllion = source;
        partyLiability.liabilitySourceIllion.subType = SOPModel.ILLION_LC;
      }
      sop.partyLiabilities = partyLiabilityMap.values();
    }
  }
}
