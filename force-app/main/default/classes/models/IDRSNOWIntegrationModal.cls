/**
 * @author Anuja Vats
 * @since April 2024
 * @description model for CMOS ServiceNow Intergation
 * @group Models
 */
public class IDRSNOWIntegrationModal {
    @AuraEnabled
	public ServiceNowResult[] result;
    
   /**
   * @description result wrapper
   */
	class ServiceNowResult {
        @AuraEnabled
		public String eventNumber;
        @AuraEnabled
		public String eventType;
	}
	
   /**
   * @param json input string to deserialize
   * @return IDRSNOWIntegrationModal
   * @description deserializes the input string into the model
   */
    public static IDRSNOWIntegrationModal parse(String json){
        String modifiedJson = modifyJsonTags(json);
		return (IDRSNOWIntegrationModal) System.JSON.deserialize(modifiedJson, IDRSNOWIntegrationModal.class);
	}
    
   /**
   * @param json input string to modify
   * @return String Modified Json
   * @description modifies Key in incoming json
   */
    public static String modifyJsonTags(String json){
        String jsonBody = json;
    	Map<String,String> mappedTags = new Map<String,String>{'number' => 'eventNumber' , 'event_type' => 'eventType'};
        for(String oldTag : mappedTags.keySet()){
            jsonBody = jsonBody.replace(oldTag, mappedTags.get(oldTag));
        }
        return jsonBody;
    }
}