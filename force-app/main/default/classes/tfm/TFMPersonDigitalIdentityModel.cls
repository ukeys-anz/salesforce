/**
 * @author Hinduja Upadhyay
 * @since Feb 2024
 * @description PersonDigitalIdentity Model to get response from Aegis thru mule
 * @group TFM
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class TFMPersonDigitalIdentityModel extends CalloutModel {
  /**
   * @description results list for results of api
   */
  public List<Result> result;

  /**
   * @description assiging values to Credential for Serach Customer API
   */
  public class Credential {
    public String ref;
    public String refResourceCollection; // in json: _refResourceCollection
    public String refResourceId; // in json: _refResourceId
    public RefProperties refProperties; // in json: _refProperties
    public String id; // in json: _id
    public String appCorrelationId;
    public String rev; // in json: _rev
    public String type;
    public String status;
    public String provider;
    public String createDateTime;
  }
  /**
   * @description assiging values to Persona for Serach Customer API
   */
  public class Persona {
    public String ref; // in json: _ref
    public String refResourceCollection; // in json: _refResourceCollection
    public String refResourceId; // in json: _refResourceId
    public RefProperties refProperties; // in json: _refProperties
    public String id; // in json: _id
    public String rev; // in json: _rev
    public String type;
    public String status;
    public String createDateTime;
  }

  /**
   * @description assiging values to RefProperties for Serach Customer API
   */
  public class RefProperties {
    public String id; // in json: _id
    public String rev; // in json: _rev
  }

  /**
   * @description assiging values to Result for Serach Customer API
   */
  public class Result {
    public String id; // in json: _id
    public String rev; // in json: _rev
    public String ocvId;
    public String status;
    public String preferredName;
    public String securityEmail;
    public String createDateTime;
    public String securityMobile;
    public String idxInternalUserId;
    public Integer identityAssuranceLevel;
    public List<Persona> persona;
    public List<Credential> credential;
  }

  /**
   * @description Represents Response body for search Customer API
   * @param json json response from search Customer API
   * @return `TFMPersonDigitalIdentityModel` api response is serialised into TFMPersonDigitalIdentityModel
   */
  public static TFMPersonDigitalIdentityModel parse(String json) {
    return (TFMPersonDigitalIdentityModel) deserialize(
      json,
      TFMPersonDigitalIdentityModel.class
    );
  }
}
