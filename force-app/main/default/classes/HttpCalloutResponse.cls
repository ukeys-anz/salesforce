/**
 *
 * @author
 * @since
 * @description
 */
public with sharing class HttpCalloutResponse {
  /**
   * @description
   */
  public Boolean successful { get; set; }
  /**
   * @description
   */
  public Integer statusCode { get; set; }
  /**
   * @description
   */
  public String status { get; set; }
  /**
   * @description
   */
  public String body { get; set; }
  /**
   * @description
   */
  public Exception error { get; set; }
  /**
   * @description
   */
  public Blob bodyAsBlob { get; set; }
}
