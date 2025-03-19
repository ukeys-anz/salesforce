/**
 * @author Aman Gupta
 * @since February 2025
 * @description Model for updating financial accounts for Confirmation of Payee (CoP).
 * @group Models
 */
public class FinancialAccModelUpdateRequestCoP {
  public String accountIdentification;
  public String accountCoPStatus;
  public String copStatusReason;
  public RequestedBy[] requestedBy;

  /**
   * @description Represents details of the user who requested the CoP status update.
   */
  public class RequestedBy {
    public String requestorIdType;
    public String requestorId;
  }

  /**
   * @description Parses a JSON string into a FinancialAccModelUpdateRequestCoP object.
   * @param json A JSON string representing the CoP update request.
   * @return Deserialized `FinancialAccModelUpdateRequestCoP` object.
   */
  public static FinancialAccModelUpdateRequestCoP parse(String json) {
    return (FinancialAccModelUpdateRequestCoP) System.JSON.deserialize(
      json,
      FinancialAccModelUpdateRequestCoP.class
    );
  }
}
