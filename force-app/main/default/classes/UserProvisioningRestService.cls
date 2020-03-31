/**
 * @author Boobalakrishnan Duraisamy
 * @since  03/2020
 * @description Exposable REST API class to create User Provisioning Requests in Salesforce.
 */

@RestResource(urlMapping='/UserProvisioningRequests/*')
global with sharing class UserProvisioningRestService {
  /**
   * @description HTTP POST method to create User Provisioning Requests in salesforce based on Requester UUID and Request Type.
   * @param uprRecords List of user provisioning requests
   */
  @HttpPost
  global static void doPost(List<UserProvisioningRequest> uprRecords) {
    List<User_Provisioning_Request__c> uprList = new List<User_Provisioning_Request__c>();
    List<UserProvisioningResponse> finalResponseList = new List<UserProvisioningResponse>();
    Integer finalStatusCode = 500;

    if (!uprRecords.isEmpty()) {
      for (UserProvisioningRequest uprRecord : uprRecords) {
        if (isValidRecordForProcessing(uprRecord)) {
          uprList.add(generateUPRRecord(uprRecord));
        } else {
          finalResponseList.add(generateErrorResponse(uprRecord));
        }
      }

      if (!uprList.isEmpty()) {
        //DML OPERATION
        List<Database.SaveResult> insertRequests = Database.insert(
          uprList,
          false
        );

        for (Database.SaveResult insertResult : insertRequests) {
          finalResponseList.add(generateFinalResponse(insertResult));
        }
      }
    }

    for (UserProvisioningResponse finalResponse : finalResponseList) {
      if (finalResponse.statusCode == 200) {
        finalStatusCode = 200;
      }
    }

    //Generate Response based on the results
    String jsonRes = JSON.serialize(finalResponseList);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatusCode;
  }

  /**
   * @description Method to check if the request record is valid or not.
   * @param uprRecord User Provisioning Request record
   * @return `Boolean` true if the record is valid. Otherwise return false.
   */
  private static Boolean isValidRecordForProcessing(
    UserProvisioningRequest uprRecord
  ) {
    if (
      (uprRecord.requestType == 'Grant' || uprRecord.requestType == 'Modify') &&
      (String.isNotBlank(uprRecord.requestorUUID) &&
      String.isNotBlank(uprRecord.businessFunction) &&
      String.isNotBlank(uprRecord.businessRole))
    ) {
      return true;
    } else if (
      uprRecord.requestType == 'Revoke' &&
      String.isNotBlank(uprRecord.requestorUUID)
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Method to generate User Provisioning Request records based on input request records
   * @param uprRecord User Provisioning Request record
   * @return 'User_Provisioning_Request__c'
   */
  private static User_Provisioning_Request__c generateUPRRecord(
    UserProvisioningRequest uprRecord
  ) {
    User_Provisioning_Request__c upr = new User_Provisioning_Request__c();

    upr.Business_Function__c = uprRecord.businessFunction;
    upr.Business_Role__c = uprRecord.businessRole;
    upr.Requestor_UUID__c = uprRecord.requestorUUID;
    upr.Manager_UUID__c = uprRecord.managerUUID;
    upr.Type__c = uprRecord.requestType;

    return upr;
  }

  /**
   * @description Method to generate error response if the required field is missing
   * @param uprRecord User Provisioning Request record
   * @return 'UserProvisioningResponse'
   */

  private static UserProvisioningResponse generateErrorResponse(
    UserProvisioningRequest uprRecord
  ) {
    UserProvisioningResponse result = new UserProvisioningResponse();
    result.errorFields = new List<String>();
    result.success = false;
    result.statusCode = 500;
    result.errorMessage = 'Mandatory Fields are Missing';
    if (String.isBlank(uprRecord.requestorUUID)) {
      result.errorFields.add('requestorUUID');
    }
    if (String.isBlank(uprRecord.requestType)) {
      result.errorFields.add('requestType');
    }
    if (String.isBlank(uprRecord.businessFunction)) {
      result.errorFields.add('businessFunction');
    }
    if (String.isBlank(uprRecord.businessRole)) {
      result.errorFields.add('businessRole');
    }
    return result;
  }

  /**
   * @description Method to generate final response based on DML insert result
   * @param insertResult inserted record result from Database.Insert
   * @return 'UserProvisioningResponse'
   */
  private static UserProvisioningResponse generateFinalResponse(
    Database.SaveResult insertResult
  ) {
    UserProvisioningResponse result = new UserProvisioningResponse();
    result.success = insertResult.success;
    result.sfdcId = insertResult.getId();
    if (insertResult.success == true) {
      result.statusCode = 200;
    } else {
      result.statusCode = 500;
    }
    for (Database.Error error : insertResult.errors) {
      result.errorStatusCode = error.getStatusCode();
      result.errorMessage = error.getMessage();
      result.errorFields = error.getFields();
    }

    return result;
  }

  /**
   * @description Wrapper class to store the User Provisioning Request parameters
   */
  global class UserProvisioningRequest {
    /**
     * @description Business Function value from Tech Assist Request
     */
    public String businessFunction { get; set; }
    /**
     * @description Business Role value from Tech Assist Request
     */
    public String businessRole { get; set; }
    /**
     * @description Requestor UUID value from Tech Assist Request
     */
    public String requestorUUID { get; set; }
    /**
     * @description Manager UUID value from Tech Assist Request
     */
    public String managerUUID { get; set; }
    /**
     * @description Request Type (Grant, Modify, Revoke) value from Tech Assist Request
     */
    public String requestType { get; set; }
  }

  /**
   * @description Wrapper class to store the User Provisioning Response parameters
   */
  global class UserProvisioningResponse {
    /**
     * @description Response result (true or false)
     */
    public Boolean success { get; set; }
    /**
     * @description Response code. 200 for success. 500 for failure.
     */
    public Integer statusCode { get; set; }
    /**
     * @description Salesforce ID
     */
    public String sfdcId { get; set; }
    /**
     * @description Error Message for failure response
     */
    public String errorMessage { get; set; }
    /**
     * @description List of fields causing error
     */
    public List<String> errorFields { get; set; }
    /**
     * @description SFDC error status code
     */
    public StatusCode errorStatusCode { get; set; }
  }
}