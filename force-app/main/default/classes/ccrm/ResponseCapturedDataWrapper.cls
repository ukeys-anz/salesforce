/**
* @author Ashish Kumar
* @since 05/2023
* @description Class for CCRM Lead Response Task Record.
* @name ResponseCapturedDataWrapper
*/
public class ResponseCapturedDataWrapper {
    /**
     * @description task Id
     */
    @AuraEnabled
    public String responseData { get; set; }
    /**
     * @description Boolean if final expiry date is greater than campaign end date.
     */
    @AuraEnabled
    public Boolean isCampaignEndDateMax { get; set; }
    
    /**
     * @description Constructor.
     * @name ResponseCapturedDataWrapper
     * @param responseData to have task Id
     * @param isCampaignEndDateMax Boolean if final expiry date is greater than campaign end date. 
     */
    public ResponseCapturedDataWrapper(String responseData,Boolean isCampaignEndDateMax) {
        this.responseData = responseData;
        this.isCampaignEndDateMax = isCampaignEndDateMax;
    }
}