/**
 * @author Mildeep Pahwa
 * @since January 2025
 * @description extended service class for OCV maintain party api
 * @group Service
 */
public with sharing virtual class MaintainPartyService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  private static final CommercialLeadConversionRepository COMMERCIAL_LEAD_CONVERSION_REPOSITORY = (CommercialLeadConversionRepository) Lib_InstanceProvider.forType(
    CommercialLeadConversionRepository.class
  );
  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );

  /**
   * @param record OCVRequestPayloadWrapper payload from the lwc component
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public virtual HttpCalloutResponse maintainPartyOrganisation(
    OCVRequestPayloadWrapper record
  ) {
    Map<String, String> headers = new Map<String, String>();
    User leadOwner = COMMERCIAL_LEAD_CONVERSION_REPOSITORY.getLeadOwnerLanId(
      record.strOwnerId
    );
    if (leadOwner == null || String.isBlank(leadOwner?.Lan_Id__c)) {
      throw new CustomException(Label.User_LAN_Id_Error);
    }
    String body = MaintainPartyOrganisationModel.getBody(record);
    String operatorId = leadOwner.Lan_Id__c;
    String requestTime = String.valueOf(System.now()) + '.00'; // appended with ms as required by API mesh

    headers.put('Content-Type', 'application/json');
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Channel', 'CRM');
    headers.put('Authorization', 'Bearer ' + ARNCService.generateJWTToken());
    headers.put('request-time', requestTime);
    headers.put('user-id', operatorId);
    headers.put('X-Operator-Id', operatorId);
    headers.put('X-Workstation', System.Label.CCRM_CreatePartyWorkStation);
    headers.put('X-Operator-Branch', System.Label.CCRM_CreatePartyBranch);
    headers.put(
      'X-Originating-App',
      System.Label.CCRM_CreatePartyOriginatingApp
    );
    headers.put(
      'X-Idempotency-Key',
      CommonUtil.generateUUID(Blob.valueOf(body))
    );

    return CALLOUT.makeRestCallout(
      Label.MS_Maintain_Party_Organisation,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @param record OCVRequestPayloadWrapper payload from the lwc component
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public virtual override HttpCalloutResponse maintainPartyForIndividual(
    OCVRequestPayloadWrapper record
  ) {
    User leadOwner = USER_REPOSITORY.getUserFromUserIds(record.strOwnerId);
    if (leadOwner == null || String.isBlank(leadOwner?.Lan_Id__c)) {
      throw new CustomException(Label.User_LAN_Id_Error);
    }
    String requestTime = String.valueOf(System.now()) + '.00'; // appended with ms as required by API mesh
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json',
      'client_id' => '{!$Credential.Username}',
      'client_secret' => '{!$Credential.Password}',
      'x-correlation-id' => UniqueIdUtil.getTraceId(),
      'Channel' => 'CRM',
      'Authorization' => 'Bearer ' + ARNCService.generateJWTToken(),
      'request-time' => requestTime,
      'user-id' => leadOwner.Lan_Id__c
    };
    String body = MaintainPartyIndividualModel.getBody(record);
    String endPoint = Label.MS_Maintain_Party;
    return CALLOUT.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }
}
