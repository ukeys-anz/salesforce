/**
 * @author ramvilas
 * @since Jan 2025
 * @description model for LoanAccountChanges
 * @group Models
 */

public with sharing class LoanAccountChangesModel extends CalloutModel {
  public List<LoanAccountChange> changes;

  /**
   * @description LoanAccountChange details
   */
  public class LoanAccountChange implements GenericObject {
    /**
     * @description name
     */
    public String name {
      get {
        return name?.replace('/', '_');
      }
      set;
    }
    public LoanAccount request;
    public LoanAccount response;
    public String updateMask;
    public Approval approval;

    /**
     * @description Returns the value of the specified field.
     * @param fieldName The name of the field to retrieve the value for.
     * @return The value of the specified field.
     */
    public Object get(String fieldName) {
      switch on fieldName {
        when 'name' {
          return this.name;
        }
        when 'state' {
          return this.approval.state;
        }
      }
      throw new IllegalArgumentException(
        'Field not yet supported: ' + fieldName
      );
    }

    /**
     * @description LoanAccountChange constructor
     * @param name
     * @param req
     * @param res
     * @param mask
     * @param approval
     */
    public LoanAccountChange(
      String name,
      LoanAccount req,
      LoanAccount res,
      String mask,
      Approval approval
    ) {
      this.name = name;
      this.request = req;
      this.response = res;
      this.updateMask = mask;
      this.approval = approval;
    }
  }

  /**
   * @description Approval details
   */
  public class Approval {
    public String state;

    public DateTime updatedTime;

    /**
     * @description Approval constructor
     * @param approval
     * @param updatedTime
     */
    public Approval(String approval, DateTime updatedTime) {
      this.state = approval;
      this.updatedTime = updatedTime;
    }
  }

  /**
   * @description LoanAccount details
   */
  public class LoanAccount {
    /**
     * @description productType
     */
    public String productType;

    /**
     * @description LoanAccount constructor
     * @param type
     */
    public LoanAccount(String type) {
      this.productType = type;
    }
  }

  /**
   * @param json input string to deserialize
   * @return 'LoanAccountChangesModel'
   * @description deserializes the input string into the model
   */
  public static LoanAccountChangesModel parse(String json) {
    return (LoanAccountChangesModel) deserialize(
      json,
      LoanAccountChangesModel.class
    );
  }
}
