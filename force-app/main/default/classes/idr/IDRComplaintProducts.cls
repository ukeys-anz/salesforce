/**
 * @author Boobalakrishnan Duraisamy
 * @since  05/2021
 * @description Wrapper class to send product details for complaint flag event
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRComplaintProducts {
  public String issueType;
  public String productName;

  /**
   * @description Constructor
   * @param type complaint issue type
   * @param name product name
   */
  public IDRComplaintProducts(String type, String name) {
    issueType = type;
    productName = name;
  }
}
