/**
 * @author Hrushikesh
 * @since February 2025
 * @description Abstract class enforcing child classes to implement data retrieval for case groups.
 */
public abstract class CaseGroupWizard {
  /**
   * @description Abstract method to retrieve financial account data for a case group.
   * Child classes must implement this method to provide data retrieval logic.
   * @param params A map of key-value parameters used for data filtering.
   * @return List<CaseGroupFinancialAccountModel> A list of financial account models representing case group data.
   */
  public abstract List<CaseGroupFinancialAccountModel> getData(
    Map<String, String> params
  );
}
