/**
 * @author Tan Phan
 * @since 01/2025
 * @description Mock class for mocking DAONFileService
 */
public with sharing class DAONFileServiceMock extends DAONFileService {
  public virtual override HttpCalloutResponse downloadFiles(
    DAONFileRequestModel request,
    String customerId,
    String customerIdType
  ) {
    super.response.statusCode = 200;
    super.response.successful = true;
    return super.response;
  }
}
