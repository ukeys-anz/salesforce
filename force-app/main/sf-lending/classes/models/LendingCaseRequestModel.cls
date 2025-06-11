/** @author Jaya Srivastava
 * @since Jan 2025
 * @description Request model for Lending Cases
 * @group Models
 */
public class LendingCaseRequestModel extends CalloutModel {
  /**
   * @description Details of approval status and loanAccountChange
   */
  public Approval approval;

  /**
   * @description blank constructor for instantiation
   */
  public LendingCaseRequestModel() {
  }

  /**
   * @description Storing details of the approval status
   */
  public class Approval {
    public String state;

    /**
     * @description constructor with 1 parameter
     * @param state String
     */
    public Approval(String state) {
      this.state = state;
    }
  }

  /**
   * @description constructor with 1 parameter to form the request body
   * @param state String
   */
  public LendingCaseRequestModel(String state) {
    this.approval = new LendingCaseRequestModel.Approval(state);
  }
}
