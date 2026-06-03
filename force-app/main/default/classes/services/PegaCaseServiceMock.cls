/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Mock class for mocking @link PegaCaseService
 **/
public with sharing class PegaCaseServiceMock extends PegaCaseService {
  public virtual override HttpCalloutResponse createCase(
    PegaCaseRequestModel payload
  ) {
    super.response.body = '{"pyID" : "COB-64020", "nextPageID":"Confirm", "pxObjClass": "ANZ-WF-WORK COB-32007", "errors": []}';
    super.response.statusCode = 200;
    super.response.successful = true;
    return response;
  }
}
