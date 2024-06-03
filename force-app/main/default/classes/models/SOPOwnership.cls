/**
 * @author Vidhya Raghavan
 * @since Jun 2023
 * @description model for SOP Ownership
 * @group Models
 */
public class SOPOwnership {
  public String partyId;
  public SOPProportion proportion;

  /**
   * @description constructor
   */
  public SOPOwnership() {
  }

  /**
   * @description constructor to create new SOPOwnership
   * @param id party id
   * @param proportionStr SOPProportion in a string
   */
  public SOPOwnership(String id, String proportionStr) {
    partyId = id;
    SOPProportion prop = new SOPProportion();
    prop.value = proportionStr;
    proportion = prop;
  }
  /**
   * @description returns the owner name from a given partyid, the ownername is only available when this class is used as part of ResidentialLoanApplicationModel
   */
  public string ownerName {
    get {
      Account acc = ResidentialLoanApplicationModel.partyIdToAccountMap
        ?.get(this.partyId);
      return acc?.FirstName;
    }
  }

  /**
   * @description flat ownership to be used by omniscript picklist, to work around a SF bug
   * that the options are not displayed if the json string for the picklist value contains list
   */
  public class FlatOwnerShip {
    public string partyIdOne;
    public string proportionValueOne;
    public string partyIdTwo;
    public string proportionValueTwo;
  }
}
