/**
 * @author Aman Gupta
 * @since February 2025
 * @description Model class for updating financial accounts for Confirmation Of Payee (CoP).
 * @group Models
 * @note ExcessivePublicCount suppressed: FinancialAccModelUpdateResponseCoP consolidates all public methods and attributes.
 */
public class FinancialAccModelUpdateResponseCoP {
  public AccountList[] accountList;

  /**
   * @description Represents account details for CoP status updates.
   */
  public class AccountList {
    public String accountIdentification;
    public String copStatusUpdateDate;
    public String accountCoPStatus;
    public String copStatusReason;
    public RequestedBy[] requestedBy;
    public ModifiedBy modifiedBy;
    public Error error;
  }

  /**
   * @description Represents details of the user who requested the CoP status update.
   */
  public class RequestedBy {
    public String requestorIdType;
    public String requestorId;
  }

  /**
   * @description Represents details of the user who modified the CoP status.
   */
  public class ModifiedBy {
    public String modifierIdType;
    public String modifierId;
  }

  /**
   * @description Represents error details related to the CoP process.
   */
  public class Error {
    public String code;
    public String message;
  }

  /**
   * @description Parses a JSON string into a FinancialAccModelUpdateResponseCoP object.
   * @param json A JSON string representing the CoP update response.
   * @return FinancialAccModelUpdateResponseCoP The deserialized object from JSON.
   */
  public static FinancialAccModelUpdateResponseCoP parse(String json) {
    return (FinancialAccModelUpdateResponseCoP) System.JSON.deserialize(
      json,
      FinancialAccModelUpdateResponseCoP.class
    );
  }
}
