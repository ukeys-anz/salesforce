/**
 * @author Ashish Kumar
 * @since Jan 2025
 * @description extended service class for OCV retrieve party api
 * @group Service
 */
public with sharing class RetrievePartyService extends Service {
  private static final String PARTY_TYPE = 'P';
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  /**
   * @param record OCVRetrievePartyPayloadWrapper payload from the class
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public override HttpCalloutResponse retrieveParty(
    OCVRetrievePartyPayloadWrapper record
  ) {
    User leadOwner = USER_REPOSITORY.getUserFromUserIds(UserInfo.getUserId());
    if (leadOwner == null || String.isBlank(leadOwner?.Lan_Id__c)) {
      throw new CustomException(Label.User_LAN_Id_Error);
    }
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json',
      'client_id' => '{!$Credential.Username}',
      'client_secret' => '{!$Credential.Password}',
      'x-correlation-id' => UniqueIdUtil.getTraceId(),
      'Authorization' => 'Bearer ' + ARNCService.generateJWTToken(),
      'X-Workstation' => System.Label.Customer_Auth_Workstation,
      'X-Operator-Branch' => System.Label.Customer_Auth_Operator_Branch,
      'X-Operator-Id' => leadOwner.Lan_Id__c,
      'X-Originating-App' => System.Label.Customer_Auth_Originating_App
    };
    String endPoint = record.partyType == PARTY_TYPE
      ? Label.MS_Retrieve_Party_Individual
      : Label.MS_Retrieve_Party_Organization;
    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_PUT,
      headers,
      JSON.serialize(record)
    );
    return response;
  }

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
}
