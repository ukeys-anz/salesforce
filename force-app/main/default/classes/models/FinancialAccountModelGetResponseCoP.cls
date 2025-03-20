/**
 * @author Aman Gupta
 * @since February 2025
 * @description Model representing financial accounts for Confirmation of Payee (CoP).
 * @group Models
 */
public class FinancialAccountModelGetResponseCoP {
  public AccountList[] accountList;

  /**
   * @description Represents account-related details.
   */
  public class AccountList {
    public String accountIdentification;
    public String accountingSystem;
    public String status;
    public String statusReason;
    public String statusUpdateDate;
    public RequestedBy[] requestedBy;
    public ModifiedBy modifiedBy;
    public Error error;
  }

  /**
   * @description Represents details of the requester.
   */
  public class RequestedBy {
    public String requestorIdType;
    public String requestorId;
  }

  /**
   * @description Represents details of the last modifier.
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
   * @description Parses a JSON string into a `FinancialAccountModelGetResponseCoP` object.
   * @param json The JSON string to deserialize.
   * @return A `FinancialAccountModelGetResponseCoP` instance.
   */
  public static FinancialAccountModelGetResponseCoP parse(String json) {
    return (FinancialAccountModelGetResponseCoP) System.JSON.deserialize(
      json,
      FinancialAccountModelGetResponseCoP.class
    );
  }
}
