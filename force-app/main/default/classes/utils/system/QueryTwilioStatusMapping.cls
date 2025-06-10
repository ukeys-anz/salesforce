/**
 * @author Shivam
 * @since May 2025
 * @description Holds Twilio Interaction Status Mapping for Twilio
 */
public with sharing class QueryTwilioStatusMapping {

    public static Map<String, InteractionStatusMappingForTwilio__mdt> mapByStatus = new Map<String, InteractionStatusMappingForTwilio__mdt>();
    static {
        //Fetch Status Mapping for Twilio and Interaction
        List<InteractionStatusMappingForTwilio__mdt> allConfigRecord = [SELECT Type__c, Interaction_Status__c, Twilio_Status__c
        FROM InteractionStatusMappingForTwilio__mdt
        WHERE Type__c = :InteractionConstants.CHAT
        WITH USER_MODE
        ];
        for (InteractionStatusMappingForTwilio__mdt config : allConfigRecord) {
          mapByStatus.put(
            config.Twilio_Status__c,
            config
          );
        }
      }

      /**
       * @description Returns InteractionStatusMappingForTwilio__mdt record based on the twilio status.
       * @param twilioStatus status value coming from twilio context.
       * @return InteractionStatusMappingForTwilio__mdt config data.
       */
      public static InteractionStatusMappingForTwilio__mdt getByStatus(
        String twilioStatus
      ) {
        return mapByStatus.get(twilioStatus);
      }
}