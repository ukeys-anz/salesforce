/**
 * @author Tan Phan
 * @since 01/2025
 * @description APIRepository class for DAONFile related operations
 */
public with sharing class DAONFileAPIRepository extends RepositoryBase {
  private static final DAONFileService SERVICE = (DAONFileService) Lib_InstanceProvider.forType(
    DAONFileService.class
  );

  /**
   * @description To download files from DAON
   * @param request List<ContactRequest> list of contact requests to be processed.
   * @param customerId unique identifier of the customer.
   * @param customerIdType Identifier type.
   */
  public void downloadFiles(
    DAONFileRequestModel request,
    String customerId,
    String customerIdType
  ) {
    super.processResponse(
      SERVICE.downloadFiles(request, customerId, customerIdType)
    );
  }
}
