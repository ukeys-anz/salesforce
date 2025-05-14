/**
 * @author Shivam
 * @since May 2025
 * @description Holds Twilio Interaction Status Mapping for Twilio
 */
public with sharing class QueryTwilioStatusMapping {

    public static Map<String, String> interactionTwilioStatusMap = new Map<String, String>();
    static {
        //Fetch Status Mapping for Twilio and Interaction
        List<InteractionStatusMappingForTwilio__mdt> statusMap = [SELECT Type__c, Interaction_Status__c, Twilio_Status__c
        FROM InteractionStatusMappingForTwilio__mdt
        WHERE Type__c = :InteractionConstants.CHAT
        WITH USER_MODE
        ];
        for (InteractionStatusMappingForTwilio__mdt status : statusMap) {
          interactionTwilioStatusMap.put(
            status.Twilio_Status__c,
            status.Interaction_Status__c
          );
        }
      }
}