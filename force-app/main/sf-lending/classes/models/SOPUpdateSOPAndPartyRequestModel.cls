/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description model for SOP party and Update SOP
 * @group Models
 */
public with sharing class SOPUpdateSOPAndPartyRequestModel extends CalloutModel {
  // Wrapper for the 'partyData' object
  public PartyData partyData;

  // Wrapper for the 'sopData' object
  public SopData sopData;

  /**
   * @description PartyData class
   */
  public class PartyData {
    public Party party;
  }
  /**
   * @description Party nested class
   */
  public class Party {
    public String id;
    public String relationshipState;
    public Boolean spouseEarnsIncome;

    /**
     * @description blank construcuor
     */
    public Party() {
    }
    /**
     * @description parameterized constrcutor
     * @param sopViewPartyDetails
     */
    public Party(SOPViewModel.Parties sopViewPartyDetails) {
      this.id = sopViewPartyDetails.id;
      this.spouseEarnsIncome = SOPUpdateSOPandPartyHelper.transformSpouceEarnIncome(
        sopViewPartyDetails.soleIncomeEarner
      );
      this.relationshipState = SOPUpdateSOPandPartyHelper.transformToRelationshipState(
        sopViewPartyDetails.relationshipState
      );
    }
  }

  /**
   * @description Class for SopData Node
   */
  public class SopData {
    public Integer dependantsCount;
    public String etag;
    /**
     * @description blank constrcutor
     */
    public SopData() {
    }
    /**
     * @description parameterized constrcutor
     * @param sopViewDetails
     */
    public SopData(SOPViewModel sopViewDetails) {
      this.dependantsCount = sopViewDetails.parties[0].partyDependantsCount;
      this.etag = sopViewDetails.etag;
    }
  }

  /**
   * @description blank constrcutor
   */
  public SOPUpdateSOPAndPartyRequestModel() {
  }
  /**
   * @description parameterized constrcutor
   * @param sopDetails
   */
  public SOPUpdateSOPAndPartyRequestModel(SOPViewModel sopDetails) {
    this.partyData = new SOPUpdateSOPAndPartyRequestModel.PartyData();
    this.partyData.party = new SOPUpdateSOPAndPartyRequestModel.Party(
      sopDetails.parties[0] // Accessing 0th index value as we are passing only primary party details from UI
    );
    this.sopData = new SOPUpdateSOPAndPartyRequestModel.SopData(sopDetails);
  }
}
