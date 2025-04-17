/**
 * @description Wrapper class to store Interaction Context Request parameters
 */
global class InteractionContextRequest {

  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  /**
   * @description chatOrCallId to identify the Twilio details
   */
  public String chatOrCallId { get; set; }
  /**
   * @description Issue Subtype as a String based on Chat context passed from App in to Twilio
   */
  public String issueSubtype { get; set; }
  /**
   * @description Direction from Twillio
   */
  public String direction { get; set; }
  /**
   * @description Customer OCV ID
   */
  public String ocvId { get; set; }
  /**
   * @description phone number from Twilio
   */
  public String phoneNumber { get; set; }
  /**
   * @description PPID from Twilio
   */
  public String ppid { get; set; }
  /**
   * @description Type from Twilio
   */
  public String type { get; set; }
  /**
   * @description Twilio Id from Twilio
   */
  public String twilioId { get; set; }
  /**
   * @description Call Recording Id from Twilio for inbound calls
   */
  public String callRecordingId { get; set; }
  /**
   * @description chatOrCallStatus from Twilio
   */
  public String chatOrCallStatus { get; set; }
   /**
   * @description pubSubEventId from Twilio
   */
  public String pubSubEventId { get; set; }
  /**
   * @description isAuthenticated from Twilio, if the connection is authenticated or not
   */
  public Boolean isAuthenticated {
    get {
      return isAuthenticated ?? false;
    }
    set;
  }

  /**
  * @description fetch account id based on ocvId
  */
  public Account existingAccount { 
    get {
      List<Account> accountExisting = INTERACTION_REPOSITORY.fetchExistingAccountByOCVId(
        ocvId);
      if(accountExisting != null && !accountExisting.isEmpty()){
        return accountExisting[0];
      }
      else{
        return null;
      }
    }
    set;
  }
   /**
  * @description fetch account id based on ocvId
  */
  public Task pushToAppTask { 
    get { 
      List<Task> taskList =  INTERACTION_REPOSITORY.queryPushToAppTaskDetails(
        pubSubEventId);
      if(taskList != null && !taskList.isEmpty()){
        return taskList[0];
      }
      else{
        Logger.info(
            ' No Customer Nudge Task Found having pubSubEventId :-' +
            pubSubEventId + ' For Chat or Call SID :- ' + chatOrCallId
        );
        Logger.saveLog();
        return null;
      }
    }
    set;
  }
}