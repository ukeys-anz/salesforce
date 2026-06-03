/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Model class for the Callout Response sent by Pega Case Service
 **/
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class PegaCaseResponseModel extends CalloutModel {
  public String pyID;
  public String pxObjClass;
  public String nextPageID;
  public String ErrorMessage;
  public String ErrorReason;
  public List<Error> errors;

  /**
   * @description This is the Response class.
   */
  public class Error {
    public String id;
    public String message;
    public String pxObjectClass;
  }

  /**
   * @param responseInput input string to deserialize
   * @return `PegaCaseResponseModel`
   * @description deserializes the input string into the model
   */
  public static PegaCaseResponseModel parse(String responseInput) {
    return (PegaCaseResponseModel) deserialize(
      responseInput,
      PegaCaseResponseModel.class
    );
  }
}
