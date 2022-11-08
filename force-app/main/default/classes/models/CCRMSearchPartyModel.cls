/**
 * @author Boobalakrishnan Duraisamy
 * @since May 2022
 * @description model for OCV Search Party API
 * @group Models
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class CCRMSearchPartyModel extends CalloutModel {
  public Integer totalCount; //2
  public CustomerDetails[] certifiedResults;
  public CustomerDetails[] probableResults;
  /**
   * @description CustomerDetails wrapper
   */
  public class CustomerDetails {
    public String ocvId; //8019989897
    public KycDetails kycDetails;
    public String cpId; //R5271
    public Addresses[] addresses;
    public Names[] names;
    public SourceSystems[] sourceSystems;
  }
  /**
   * @description KycDetails wrapper
   */
  public class KycDetails {
    public String status; //CO
    public String verificationLevel; //VE
  }
  /**
   * @description Addresses wrapper
   */
  public class Addresses {
    public String city; //Melbourne
    public String postalCode; //3168
  }
  /**
   * @description Names wrapper
   */
  public class Names {
    public String nameUsageType; //Legal Name
    public String name; //ABC Pvt Ltd
    public String prefix; //Dr
    public String title; //Mr
    public String firstName; //MARY
    public String middleName; //JOHN
    public String lastName; //NAPOLI
    public String suffix; //JR.
    public String source; //CAP-CIS
    public String startDate; //2001-01-01
    public String endDate; //
  }

  /**
   * @description Source Systems wrapper
   */
  public class SourceSystems {
    public String sourceSystemId; //1212201901
    public String sourceSystemName; //CAP-CIS
  }

  /**
   * @param json input string to deserialize
   * @return CCRMSearchPartyModel
   * @description deserializes the input string into the model
   */
  public static CCRMSearchPartyModel parse(String json) {
    return (CCRMSearchPartyModel) System.JSON.deserialize(
      json,
      CCRMSearchPartyModel.class
    );
  }
}
