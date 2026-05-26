/**
 * @author Pradeep Gaikwad
 * @since February 2026
 * @description Model for statements API
 */

public with sharing class ListDocumentModel {
  @AuraEnabled
  public List<StatementAndNoticesWrapper> allDocuments;

  private static Map<String, String> documentTypeToTitleMap = new Map<String, String>{
    'OnlPaymentChangeAdviceNotice' => 'Online Payment Change Advice Notice',
    'DrawdownNotice' => 'Drawdown Notice',
    'PaymentReviewNotice' => 'Payment Review Notice',
    'InterimTransactionListingDDA' => 'Interim Transaction Listing DDA',
    'HistoricalDocument' => 'Historical Document',
    'EOFYSummary' => 'EOY Summary',
    'StatementClassic' => 'Statement Classic',
    'NoticeClassic' => 'Notice Classic',
    'StatementSuncorp' => 'Statement Suncorp',
    'NoticeSuncorp' => 'Notice Suncorp',
    'ProofOfBalance' => 'Proof Of Balance',
    'StatementILS' => 'Statement ILS',
    'StatementDda' => 'Statement DDA',
    'DocumentFX' => 'Document FX'
  };

  /**
   * @description documents from api
   */
  public List<Document> documents;
  /**
   * @description next page reference if the documents are more than a passed size from api
   */
  public PaginationNext next;
  /**
   * @description countOfInvalidDocuments
   */
  @AuraEnabled
  public Integer countOfInvalidDocuments { get; set; }
  /**
   * @description totalDocuments from api
   */
  @AuraEnabled
  public Integer totalDocuments { get; set; }

  /**
   * @description this method is used to build the documents from the response
   * @param documentResponseJson the JSON string containing the document response
   * @return ListDocumentModel
   */
  @AuraEnabled
  public static ListDocumentModel buildDocsFromResponse(
    String documentResponseJson
  ) {
    ListDocumentModel documentResponse = new ListDocumentModel();
    try {
      documentResponse = (ListDocumentModel) JSON.deserialize(
        documentResponseJson.replace('@', ''),
        ListDocumentModel.class
      );

      if (documentResponse == null || documentResponse.documents == null) {
        return documentResponse;
      }

      documentResponse = initializeDocuments(documentResponse);
      validateDocuments(documentResponse);
    } catch (Exception e) {
      throw new InvalidInformationException(e.getMessage());
    }
    return documentResponse;
  }

  private static ListDocumentModel initializeDocuments(
    ListDocumentModel documentResponse
  ) {
    for (ListDocumentModel.Document doc : documentResponse.documents) {
      doc.initActiveDocument();
    }
    return documentResponse;
  }

  private static void logInvalidDocument(
    ListDocumentModel.Document doc,
    StatementAndNoticesWrapper wrapper,
    Boolean isCurrentDocumentValid
  ) {
    if (!isCurrentDocumentValid) {
      String errorMsg = buildErrorMsg(
        wrapper.issueDate,
        wrapper.startDate,
        wrapper.endDate
      );
      String logMessage =
        wrapper.documentTitle +
        ' and ID ' +
        doc.name +
        ' and Issue is ' +
        errorMsg;
      Logger.info(logMessage);
    }
  }

  /**
   * @description this method is used to validate the documents and build the wrapper list for valid documents
   * @param documentResponse the JSON string containing the document response
   */
  public static void validateDocuments(ListDocumentModel documentResponse) {
    List<StatementAndNoticesWrapper> wrapperList = new List<StatementAndNoticesWrapper>();
    documentResponse.totalDocuments = documentResponse.documents.size();

    for (ListDocumentModel.Document doc : documentResponse.documents) {
      AbstractDocumentModel activeDoc = doc.activeDocument;
      if (activeDoc == null) {
        continue;
      }
      Boolean isDateValid = activeDoc.validateDateNode();
      StatementAndNoticesWrapper wrapper = new StatementAndNoticesWrapper();
      wrapper.name = doc.name;
      wrapper.documentTitle = documentTypeToTitleMap.get(
        doc.activeDocumentTypeName
      );

      if (activeDoc instanceof AbstractNoticeModel) {
        wrapper.issueDate = ((AbstractNoticeModel) activeDoc).getIssueDate();
      } else if (activeDoc instanceof AbstractStatementModel) {
        wrapper.startDate = ((AbstractStatementModel) activeDoc).getStartDate();
        wrapper.endDate = ((AbstractStatementModel) activeDoc).getEndDate();
      }

      ValidationResult result = validateAndBuildWrapper(
        doc,
        isDateValid,
        wrapper
      );

      if (result.isValid) {
        wrapperList.add(result.wrapper);
      }
    }

    Integer invalidCount = documentResponse.totalDocuments - wrapperList.size();
    if (invalidCount > 0) {
      documentResponse.countOfInvalidDocuments = invalidCount;
    }
    Logger.saveLog();
    documentResponse.allDocuments = wrapperList;
  }

  private class ValidationResult {
    public Boolean isValid;
    public StatementAndNoticesWrapper wrapper;

    /**
     * @description this constructor is used to validate the documents and build the wrapper list for valid documents
     * @param isValid
     * @param wrapper
     */
    public ValidationResult(
      Boolean isValid,
      StatementAndNoticesWrapper wrapper
    ) {
      this.isValid = isValid;
      this.wrapper = wrapper;
    }
  }

  private static ValidationResult validateAndBuildWrapper(
    ListDocumentModel.Document doc,
    Boolean isDateValid,
    StatementAndNoticesWrapper wrapper
  ) {
    Boolean isCurrentDocumentValid = (isDateValid && doc.isAccountNumberValid);
    logInvalidDocument(doc, wrapper, isCurrentDocumentValid);
    return new ValidationResult(isCurrentDocumentValid, wrapper);
  }
  /**
   * @description check if the document data integrity
   * @param issueDate
   * @param startDate
   * @param endDate
   * @return String error message
   */
  public static String buildErrorMsg(
    DateComponent issueDate,
    DateComponent startDate,
    DateComponent endDate
  ) {
    String errorMsg = '';
    if (issueDate != null) {
      errorMsg = getDateErrorMessage(issueDate);
    }
    if (startDate != null) {
      errorMsg += getDateErrorMessage(startDate);
    }
    if (endDate != null && String.isBlank(errorMsg)) {
      errorMsg += getDateErrorMessage(endDate);
    }
    return errorMsg;
  }
  /**
   * @description check if the document date data integrity
   * @param documentDate
   * @return String error message
   */
  public static String getDateErrorMessage(DateComponent documentDate) {
    String errorMsg = '';
    errorMsg += documentDate?.year == null ? 'Year ' : '';
    errorMsg += documentDate?.month == null ? 'Month ' : '';
    errorMsg += documentDate?.day == null ? 'Day ' : '';
    if (String.isNotBlank(errorMsg)) {
      errorMsg += 'is missing in document date.';
    }
    return errorMsg;
  }
  /**
   * @description convert the document to json format
   * @return String error message
   */
  public String toJson() {
    return JSON.serializePretty(this);
  }
  /**
   * @description Document class representing the document data structure
   */
  public class Document {
    public String name;

    public String documentTitle;

    public List<Reader> readers;

    public String bsb;

    public String accountNumber;

    public StatementDda statementDda;

    public ProofOfBalance proofOfBalance;

    public OnlPaymentChangeAdviceNotice onlPaymentChangeAdviceNotice;

    public DrawdownNotice drawdownNotice;

    public PaymentReviewNotice paymentReviewNotice;

    public InterimTransactionListingDDA interimTransactionListingDDA;

    public DocumentFX documentFX;

    public StatementILS statementILS;

    public HistoricalDocument historicalDocument;

    public EOFYSummary eOFYSummary;

    public StatementClassic statementClassic;

    public NoticeClassic noticeClassic;

    public StatementSuncorp statementSuncorp;

    public NoticeSuncorp noticeSuncorp;
    /**
     * @description isAccountNumberValid for validating account number in the document
     */
    public Boolean isAccountNumberValid {
      get {
        return String.isNotBlank(this.accountNumber);
      }
      set;
    }

    /**
     * @description Gets and sets the active document
     */
    public AbstractDocumentModel activeDocument { get; set; }

    /**
     * @description Gets and sets the active document type name
     */
    public String activeDocumentTypeName { get; set; }

    /**
     * @description Initializes the active document
     */
    public void initActiveDocument() {
      Map<String, AbstractDocumentModel> documentTypeMap = new Map<String, AbstractDocumentModel>();
      documentTypeMap.put('StatementDda', statementDda);
      documentTypeMap.put('ProofOfBalance', proofOfBalance);
      documentTypeMap.put(
        'OnlPaymentChangeAdviceNotice',
        onlPaymentChangeAdviceNotice
      );
      documentTypeMap.put('DrawdownNotice', drawdownNotice);
      documentTypeMap.put('PaymentReviewNotice', paymentReviewNotice);
      documentTypeMap.put(
        'InterimTransactionListingDDA',
        interimTransactionListingDDA
      );
      documentTypeMap.put('DocumentFX', documentFX);
      documentTypeMap.put('StatementILS', statementILS);
      documentTypeMap.put('HistoricalDocument', historicalDocument);
      documentTypeMap.put('EOFYSummary', eOFYSummary);
      documentTypeMap.put('StatementClassic', statementClassic);
      documentTypeMap.put('NoticeClassic', noticeClassic);
      documentTypeMap.put('StatementSuncorp', statementSuncorp);
      documentTypeMap.put('NoticeSuncorp', noticeSuncorp);

      for (String typeName : documentTypeMap.keySet()) {
        if (documentTypeMap.get(typeName) != null) {
          this.activeDocument = documentTypeMap.get(typeName);
          this.activeDocumentTypeName = typeName;
          return;
        }
      }

      this.activeDocument = null;
      this.activeDocumentTypeName = 'UnKnown';
    }
  }
  /**
   * @description Reader class for reading the document
   */
  public class Reader {
    public String personaId;
  }
  /**
   * @description StatementDda class for statement dda document
   */
  public class StatementDda extends AbstractStatementModel {
    public DateComponent startDate;
    public DateComponent endDate;

    public override Boolean validateDateNode() {
      return startDate != null &&
        startDate.isValid() &&
        endDate != null &&
        endDate.isValid();
    }

    public override DateComponent getStartDate() {
      return startDate;
    }

    public override DateComponent getEndDate() {
      return endDate;
    }
  }
  /**
   * @description DocumentFX class for document fx document
   */
  public class DocumentFX extends AbstractStatementModel {
    public DateComponent startDate;
    public DateComponent endDate;

    public override Boolean validateDateNode() {
      return startDate != null &&
        startDate.isValid() &&
        endDate != null &&
        endDate.isValid();
    }

    public override DateComponent getStartDate() {
      return startDate;
    }

    public override DateComponent getEndDate() {
      return endDate;
    }
  }
  /**
   * @description StatementILS class for statement ils document
   */
  public class StatementILS extends AbstractStatementModel {
    public DateComponent startDate;
    public DateComponent endDate;

    public override Boolean validateDateNode() {
      return startDate != null &&
        startDate.isValid() &&
        endDate != null &&
        endDate.isValid();
    }

    public override DateComponent getStartDate() {
      return startDate;
    }

    public override DateComponent getEndDate() {
      return endDate;
    }
  }
  /**
   * @description ProofOfBalance class for proof of balance document
   */
  public class ProofOfBalance extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description OnlPaymentChangeAdviceNotice class for onl payment change advice notice document
   */
  public class OnlPaymentChangeAdviceNotice extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description DrawdownNotice class for drawdown notice document
   */
  public class DrawdownNotice extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description PaymentReviewNotice class for payment review notice document
   */
  public class PaymentReviewNotice extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description InterimTransactionListingDDA class for interim transaction listing dda document
   */
  public class InterimTransactionListingDDA extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description HistoricalDocument class for historical document
   */
  public class HistoricalDocument extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description EOFYSummary class for eofy summary document
   */
  public class EOFYSummary extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description StatementClassic class for statement classic document
   */
  public class StatementClassic extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description NoticeClassic class for notice classic document
   */
  public class NoticeClassic extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description StatementSuncorp class for statement suncorp document
   */
  public class StatementSuncorp extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description NoticeSuncorp class for notice suncorp document
   */
  public class NoticeSuncorp extends AbstractNoticeModel {
    public DateComponent issueDate;

    public override Boolean validateDateNode() {
      return issueDate != null && issueDate.isValid();
    }

    public override DateComponent getIssueDate() {
      return issueDate;
    }
  }
  /**
   * @description StatementILS class for statement ils document
   */
  public class DateComponent {
    @AuraEnabled
    public Integer year;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer day;
    /**
     * @description DateComponent class for date component
     * @return Boolean true if the date component is valid, false otherwise
     */
    public Boolean isValid() {
      return year != null && month != null && day != null;
    }
    /**
     * @description DateComponent class for date component
     * @return Date
     */
    public Date toApexDate() {
      if (!isValid()) {
        return null;
      }
      try {
        return Date.newInstance(year, month, day);
      } catch (Exception e) {
        return null;
      }
    }
    /**
     * @description DateComponent class for date component
     * @return String in ISO format
     */
    public String toIsoString() {
      Date d = toApexDate();
      return (d == null) ? null : d.format();
    }
  }
  /**
   * @description PaginationNext class for pagination next
   */
  public class PaginationNext {
    public GRPCRequest grpcRequest;
  }
  /**
   * @description GRPCRequest class for gRPC request
   */
  public class GRPCRequest {
    public String pageToken;

    public StructuredFilter structuredFilter;

    public String type;
  }
  /**
   * @description StructuredFilter class for structured filter
   */
  public class StructuredFilter {
    public List<String> doctypes;
  }
  /**
   * @description AbstractDocumentModel class for abstract document model
   */
  public virtual class AbstractDocumentModel {
    /**
     * @description validateDateNode method for abstract document model
     * @return Boolean true if the date node is valid, false otherwise
     */
    public virtual Boolean validateDateNode() {
      return true;
    }
  }
  /**
   * @description AbstractNoticeModel class for abstract notice model
   */
  public virtual class AbstractNoticeModel extends AbstractDocumentModel {
    /**
     * @description getIssueDate method for abstract notice model
     * @return Boolean true if the date node is valid, false otherwise
     */
    public virtual DateComponent getIssueDate() {
      return null;
    }
  }
  /**
   * @description AbstractStatementModel class for abstract statement model
   */

  public virtual class AbstractStatementModel extends AbstractDocumentModel {
    /**
     * @description getStartDate method for abstract statement model
     * @return Boolean true if the date node is valid, false otherwise
     */
    public virtual DateComponent getStartDate() {
      return null;
    }
    /**
     * @description getEndDate method for abstract statement model
     * @return Boolean true if the date node is valid, false otherwise
     */
    public virtual DateComponent getEndDate() {
      return null;
    }
  }
  /**
   * @description InvalidInformationException class for invalid information exception
   */
  public class InvalidInformationException extends Exception {
  }
  /**
   * @description StatementAndNoticesWrapper class for statement and notices wrapper
   */
  public class StatementAndNoticesWrapper {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String documentTitle;
    @AuraEnabled
    public DateComponent issueDate;
    @AuraEnabled
    public DateComponent startDate;
    @AuraEnabled
    public DateComponent endDate;
  }
}
