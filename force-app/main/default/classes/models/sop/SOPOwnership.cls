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
     * @description returns the owner name from a given partyid
     */
    public string ownerName {
      get {
        Account acc = ResidentialLoanApplicationModel.partyIdToAccountMap.get(
          this.partyId
        );
        return acc?.FirstName;
      }
    }
  }