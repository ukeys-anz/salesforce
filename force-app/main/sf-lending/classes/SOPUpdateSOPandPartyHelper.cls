/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description model helper class for SOP Party
 * @group Models
 */
public class SOPUpdateSOPandPartyHelper {
  /**
   * @description transform the spouce earn income value
   * @param soleIncomeEarner string parameter
   * @return Boolean
   */
  public static Boolean transformSpouceEarnIncome(String soleIncomeEarner) {
    return !(soleIncomeEarner.equalsIgnoreCase('Yes'));
  }
  /**
   * @description Method to transform the text to upper case and append RELATIONSHIP_STATE_ prefix
   * @param state string parameter
   * @return string
   */
  public static String transformToRelationshipState(String state) {
    // Convert the text to uppercase and prepend the prefix
    String prefixText = 'RELATIONSHIP_STATE_';
    if (state.equalsIgnoreCase('In a relationship')) {
      return prefixText + 'IN_RELATIONSHIP';
    }
    return prefixText + state.toUpperCase();
  }

  /**
   * @description To transform the parties list
   * @param sop SOPViewModel for transformation
   * @return List<SOPViewModel.Parties> tranformedParties
   */
  public static List<SOPViewModel.Parties> transformPartiesList(
    SOPViewModel sop
  ) {
    List<SOPViewModel.Parties> transformedParties = new List<SOPViewModel.Parties>();
    for (SOPViewModel.Parties row : sop.parties) {
      SOPViewModel.Parties transformedParty = row.clone();
      transformedParty.partyDependantsCount = sop.dependantsCount;
      transformedParties.add(transformedParty);
    }

    return transformedParties;
  }
}
