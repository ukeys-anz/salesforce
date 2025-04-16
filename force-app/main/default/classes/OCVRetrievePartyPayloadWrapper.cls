/**
 * @author Ashish Kumar
 * @since  28/01/25
 * @description Wrapper class for OCV Request creationwrapper to call retrieve party api
 */
public class OCVRetrievePartyPayloadWrapper {
  public String ocvId;
  public String ownerId;
  public String partyType;
  public sourceSystems[] sourceSystems;

  /**
   * @author Ashish Kumar
   * @since  28/01/25
   * @description Inner Wrapper class for OCV Request creationwrapper to call retrieve party api
   */
  public class SourceSystems {
    public String sourceSystemId;
    public String sourceSystemName;
  }
}
