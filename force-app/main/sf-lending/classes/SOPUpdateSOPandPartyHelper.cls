/**
 * @author Raman Gupta
 * @since Nov 2024
 * @description model helper class for SOP Party
 * @group Models
 */
public class SOPUpdateSOPandPartyHelper {
  private static final LendingAccountRepository ACCOUNT_SOQL_HELPER = (LendingAccountRepository) Lib_InstanceProvider.forType(
    LendingAccountRepository.class
  );
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
    Map<String, Account> applicantDetails = getLoanApplicants(sop);
    List<SOPViewModel.Parties> transformedParties = new List<SOPViewModel.Parties>();
    for (SOPViewModel.Parties row : sop.parties) {
      SOPViewModel.Parties transformedParty = row.clone();
      transformedParty.partyDependantsCount = sop.dependantsCount;
      transformedParty.applicantName = applicantDetails.get(row.ocvId)?.Name;
      transformedParty.applicantId = applicantDetails.get(row.ocvId)?.Id;
      transformedParties.add(transformedParty);
    }

    return transformedParties;
  }

  /**
   * @description To get parties ocvIds
   * @param sop SOPViewModel for transformation
   * @return List<String> ocvIds
   */
  public static List<String> getPartiesOcvIds(SOPViewModel sop) {
    List<String> ocvIds = new List<String>();
    for (SOPViewModel.Parties row : sop.parties) {
      ocvIds.add(row.ocvId);
    }
    return ocvIds;
  }

  /**
   * @description To get Loan Applicant record
   * @param sop SOPViewModel for transformation
   * @return Map<String,Account> accountsMap
   */
  public static Map<String, Account> getLoanApplicants(SOPViewModel sop) {
    List<Account> accounts = ACCOUNT_SOQL_HELPER.queryAccountsByOcvIds(
      getPartiesOcvIds(sop)
    );
    Map<String, Account> accountsMap = (Map<String, Account>) ListUtil.mapBy(
      accounts,
      Account.OCV_ID__c
    );
    return accountsMap;
  }
}
