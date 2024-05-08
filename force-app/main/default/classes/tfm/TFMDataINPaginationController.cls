/**
 * @description       : Controller class for TFMDataINListParentCard FlexCard
 * @author            : Anuj jain
 * @group             : TFM
 * @last modified on  : 04-21-2024
 **/
global with sharing class TFMDataINPaginationController implements omnistudio.VlocityOpenInterface, Callable {
  private static final String PERFORM_PAGINATION_FOR_DATAIN = 'performPaginationForDataIN';
  /**
   * @param action String value of local method to invoke
   * @param args arg Map that will contain input, output and options Map
   * @return `Object`
   * @description flex card invokeable method overridden by callable interface
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }

  /**
   * @param methodName String value of local method to invoke
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description flex card invokeable method
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if (methodName.equals(PERFORM_PAGINATION_FOR_DATAIN)) {
      return performPaginationForDataIN(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description implementing pagination logic
   */
  private Boolean performPaginationForDataIN(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    Boolean paginationRequired = false;
    Integer pageNumber = 0;
    Integer totalPages = 0;
    Map<String, Object> responseMap = new Map<String, Object>();
    Map<String, Object> ipOutput = new Map<String, Object>();
    Map<String, Object> ipOptions = new Map<String, Object>();
    List<Object> parentActiveConsentList = (List<Object>) input.get(
      TFMConstants.ACTIVE_CONSENT_LIST
    );
    List<Object> parentArchiveConsentList = (List<Object>) input.get(
      TFMConstants.ARCHIVE_CONSENT_LIST
    );

    //setting 0 for empty List - catch null exception
    Integer parentArchiveListSize = parentArchiveConsentList == null
      ? 0
      : parentArchiveConsentList.size();
    Integer parentActiveListSize = parentActiveConsentList == null
      ? 0
      : parentActiveConsentList.size();

    //checking if pagination Required or not
    paginationRequired =
      (parentActiveListSize + parentArchiveListSize) >
      TFMConstants.RECORDS_PER_PAGE;

    // calculating total page for pagination
    totalPages = Integer.ValueOf(
      (Decimal.valueOf((parentActiveListSize + parentArchiveListSize)) /
        TFMConstants.RECORDS_PER_PAGE)
        .round(System.RoundingMode.CEILING)
    );

    output.put(
      'consentList',
      implementPagination(
        parentActiveConsentList,
        parentArchiveConsentList,
        totalPages
      )
    );
    output.put('totalPages', totalPages);
    output.put('paginationRequired', paginationRequired);
    output.put('pageNumber', pageNumber);
    output.put('isNext', pageNumber < totalPages);
    output.put('isPrevious', pageNumber > 1);

    return true;
  }

  /**
   * @param parentActiveConsentList entire active List
   * @param parentArchiveConsentList  entire archive List
   * @param totalPages totalPages
   * @return Map<String,Object>
   * @description calculate total size of List
   */
  private Object implementPagination(
    List<Object> parentActiveConsentList,
    List<Object> parentArchiveConsentList,
    Integer totalPages
  ) {
    if (parentActiveConsentList.size() < parentArchiveConsentList.size()) {
      return processPagination(
        parentActiveConsentList,
        TFMConstants.PARENT_ACTIVE_CONSENT_LIST,
        parentArchiveConsentList,
        TFMConstants.PARENT_ARCHIVE_CONSENT_LIST,
        totalPages
      );
    } else {
      return processPagination(
        parentArchiveConsentList,
        TFMConstants.PARENT_ARCHIVE_CONSENT_LIST,
        parentActiveConsentList,
        TFMConstants.PARENT_ACTIVE_CONSENT_LIST,
        totalPages
      );
    }
  }

  /**
   * @param consentList1 consentList1
   * @param consentListKey1 consentListKey1
   * @param consentList2 consentList2
   * @param consentListKey2 consentListKey2
   * @param totalPages totalPages
   * @return `Object`
   * @description processPagination
   */
  @TestVisible
  private Object processPagination(
    List<Object> consentList1,
    String consentListKey1,
    List<Object> consentList2,
    String consentListKey2,
    Integer totalPages
  ) {
    Map<String, Object> pageViseRecordList = new Map<String, Object>();

    Integer recordOffset = 0;
    for (Integer pageNumber = 0; pageNumber < totalPages; pageNumber++) {
      Map<String, List<Object>> tempMapOfList = new Map<String, List<Object>>();

      List<Object> pageConsentList1 = getPageRecords(
        consentList1,
        pageNumber,
        recordOffset,
        TFMConstants.RECORDS_PER_LIST
      );
      List<Object> pageConsentList2 = getPageRecords(
        consentList2,
        pageNumber,
        recordOffset,
        TFMConstants.RECORDS_PER_PAGE - pageConsentList1.size()
      );

      recordOffset += pageConsentList2.size();

      tempMapOfList.put(consentListKey1, pageConsentList1);
      tempMapOfList.put(consentListKey2, pageConsentList2);

      pageViseRecordList.put('page' + pageNumber, tempMapOfList);
    }

    return pageViseRecordList;
  }

  /**
   * @param records records
   * @param pageNumber pageNumber
   * @param firstRecord firstRecord
   * @param maxRecords maxRecords
   * @return `List<Object>`
   * @description processPagination
   */
  private static List<Object> getPageRecords(
    List<Object> records,
    Integer pageNumber,
    Integer firstRecord,
    Integer maxRecords
  ) {
    List<Object> pageRecords = new List<Object>();

    Integer lastRecord = maxRecords + firstRecord;
    if (lastRecord >= records.size()) {
      lastRecord = records.size();
    }
    for (Integer i = firstRecord; i < lastRecord; i++) {
      pageRecords.add(records[i]);
    }
    return pageRecords;
  }
}
