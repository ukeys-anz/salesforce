/**
 * @author Vidhya Raghavan
 * @since Sep 2023
 * @description model for SOP LiabilitySources.returns credit bureau details specific to a customer
 * @group Models
 */
public class SOPLiabilitySources {
  public String partyId;
  public String ownerName;
  public SOPDebtSources liabilitySourceEquifax;
  public SOPDebtSources liabilitySourceExperian;
  public SOPDebtSources liabilitySourceIllion;
}
