/**
 * @description Test class for LexSettlementV1b1SettlementTypes.
 * @author Mohit Tripathi
 * @since 08/2025
 */
@isTest
public class LexSettlementV1b1SettlementTypesTest {
  @isTest
  static void testAcceptedDocument() {
    LexSettlementV1b1SettlementTypes.AcceptedDocument doc = new LexSettlementV1b1SettlementTypes.AcceptedDocument();
    doc.documentId = 'settlements/123/loan/documents/456';
    doc.documentStorageId = 'storage-id-789';
    doc.documentFileId = 'file-id-101112';
    doc.documentFileVersion = 1L;

    Assert.areEqual(
      'settlements/123/loan/documents/456',
      doc.documentId,
      'doc.documentId should match "settlements/123/loan/documents/456"'
    );
    Assert.areEqual(
      'storage-id-789',
      doc.documentStorageId,
      'doc.documentStorageId should match "storage-id-789"'
    );
    Assert.areEqual(
      'file-id-101112',
      doc.documentFileId,
      'doc.documentFileId should match "file-id-101112"'
    );
    Assert.areEqual(
      1L,
      doc.documentFileVersion,
      'doc.documentFileVersion should be 1L'
    );
  }

  @isTest
  static void testAccountId() {
    LexSettlementV1b1SettlementTypes.AccountId account = new LexSettlementV1b1SettlementTypes.AccountId();
    account.apxrsvdNumber = '123456789';
    account.bsbNumber = '123-456';

    Assert.areEqual(
      '123456789',
      account.apxrsvdNumber,
      'account.apxrsvdNumber should match "123456789"'
    );
    Assert.areEqual(
      '123-456',
      account.bsbNumber,
      'account.bsbNumber should match "123-456"'
    );
  }

  @isTest
  static void testCancelBy() {
    LexSettlementV1b1SettlementTypes.Cancellation cancel = new LexSettlementV1b1SettlementTypes.Cancellation();
    cancel.cancelBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    cancel.cancelBy.id = 'party-456';
    cancel.cancelBy.type = 'Admin';
    cancel.cancelTime = '2023-10-01T12:30:00Z';

    Assert.areEqual(
      'party-456',
      cancel.cancelBy.id,
      'cancel.cancelBy.id should match "party-456"'
    );
    Assert.areEqual(
      'Admin',
      cancel.cancelBy.type,
      'cancel.cancelBy.type should match "Admin"'
    );
    Assert.areEqual(
      '2023-10-01T12:30:00Z',
      cancel.cancelTime,
      'cancel.cancelTime should match "2023-10-01T12:30:00Z"'
    );
  }

  @IsTest
  static void testAutomaticRepaymentPreferences() {
    LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences prefs = new LexSettlementV1b1SettlementTypes.AutomaticRepaymentPreferences();
    prefs.id = 'auto-123';
    prefs.settlementId = 'settlement-456';
    prefs.repaymentFrequency = 'MONTHLY';
    prefs.state = 'ACTIVE';
    prefs.repaymentAccount = new LexSettlementV1b1SettlementTypes.AccountId();
    prefs.repaymentAccount.apxrsvdNumber = '987654321';
    prefs.repaymentAccount.bsbNumber = '654-321';
    Assert.areEqual('auto-123', prefs.id, 'prefs.id should match "auto-123"');
    Assert.areEqual(
      'settlement-456',
      prefs.settlementId,
      'prefs.settlementId should match "settlement-456"'
    );
    Assert.areEqual(
      'MONTHLY',
      prefs.repaymentFrequency,
      'prefs.repaymentFrequency should match "MONTHLY"'
    );
    Assert.areEqual('ACTIVE', prefs.state, 'prefs.state should match "ACTIVE"');
    Assert.areEqual(
      '987654321',
      prefs.repaymentAccount.apxrsvdNumber,
      'prefs.repaymentAccount.apxrsvdNumber should match "987654321"'
    );
    Assert.areEqual(
      '654-321',
      prefs.repaymentAccount.bsbNumber,
      'prefs.repaymentAccount.bsbNumber should match "654-321"'
    );
  }

  @isTest
  static void testConversation() {
    LexSettlementV1b1SettlementTypes.Conversation conv = new LexSettlementV1b1SettlementTypes.Conversation();
    conv.id = 'conv-123';
    conv.initiatingPartyName = 'John Doe';
    conv.createTime = '2023-08-15T10:00:00Z';
    conv.unread = true;

    Assert.areEqual('conv-123', conv.id, 'conv.id should match "conv-123"');
    Assert.areEqual(
      'John Doe',
      conv.initiatingPartyName,
      'conv.initiatingPartyName should match "John Doe"'
    );
    Assert.areEqual(
      '2023-08-15T10:00:00Z',
      conv.createTime,
      'conv.createTime should match "2023-08-15T10:00:00Z"'
    );
    Assert.areEqual(true, conv.unread, 'conv.unread should be true');
  }

  @isTest
  static void testCreditEnquiry() {
    LexSettlementV1b1SettlementTypes.CreditEnquiry enquiry = new LexSettlementV1b1SettlementTypes.CreditEnquiry();
    enquiry.creditEnquiryId = 'enquiry-123';
    enquiry.creditEnquiryVersion = 2;
    enquiry.version = 'v1';
    enquiry.creditAssessmentId = 'assessment-456';

    Assert.areEqual(
      'enquiry-123',
      enquiry.creditEnquiryId,
      'enquiry.creditEnquiryId should match "enquiry-123"'
    );
    Assert.areEqual(
      2,
      enquiry.creditEnquiryVersion,
      'enquiry.creditEnquiryVersion should be 2'
    );
    Assert.areEqual('v1', enquiry.version, 'enquiry.version should match "v1"');
    Assert.areEqual(
      'assessment-456',
      enquiry.creditAssessmentId,
      'enquiry.creditAssessmentId should match "assessment-456"'
    );
  }

  @isTest
  static void testDocument() {
    LexSettlementV1b1SettlementTypes.Document doc = new LexSettlementV1b1SettlementTypes.Document();
    doc.id = 'doc-123';
    doc.createTime = '2023-08-10T09:00:00Z';
    doc.updateTime = '2023-08-11T09:00:00Z';
    doc.state = 'STATE_ACCEPTED';
    doc.documentStorageId = 'storage-999';
    doc.documentStorageStatus = 'DOCUMENT_STORAGE_STATUS_ACTIVE';
    doc.source = 'DOCUMENT_SOURCE_CUSTOMER_UPLOADED';
    doc.documentFileDetails = new List<LexSettlementV1b1SettlementTypes.DocumentFileDetails>();

    Assert.areEqual('doc-123', doc.id, 'doc.id should match "doc-123"');
    Assert.areEqual(
      '2023-08-10T09:00:00Z',
      doc.createTime,
      'doc.createTime should match "2023-08-10T09:00:00Z"'
    );
    Assert.areEqual(
      '2023-08-11T09:00:00Z',
      doc.updateTime,
      'doc.updateTime should match "2023-08-11T09:00:00Z"'
    );
    Assert.areEqual(
      'STATE_ACCEPTED',
      doc.state,
      'doc.state should match "STATE_ACCEPTED"'
    );
    Assert.areEqual(
      'storage-999',
      doc.documentStorageId,
      'doc.documentStorageId should match "storage-999"'
    );
    Assert.areEqual(
      'DOCUMENT_STORAGE_STATUS_ACTIVE',
      doc.documentStorageStatus,
      'doc.documentStorageStatus should match "DOCUMENT_STORAGE_STATUS_ACTIVE"'
    );
    Assert.areEqual(
      'DOCUMENT_SOURCE_CUSTOMER_UPLOADED',
      doc.source,
      'doc.source should match "DOCUMENT_SOURCE_CUSTOMER_UPLOADED"'
    );
    Assert.areEqual(
      0,
      doc.documentFileDetails.size(),
      'doc.documentFileDetails.size should be 0'
    );
  }

  @isTest
  static void testDocumentDownloadUri() {
    LexSettlementV1b1SettlementTypes.DocumentDownloadUri downloadUri = new LexSettlementV1b1SettlementTypes.DocumentDownloadUri();
    downloadUri.filename = 'document.pdf';
    downloadUri.url = 'https://example.com/download';
    downloadUri.otp = '123456';
    downloadUri.extensionType = 'EXTENSION_TYPE_PDF';
    downloadUri.createTime = '2023-09-01T12:00:00Z';

    Assert.areEqual(
      'document.pdf',
      downloadUri.filename,
      'downloadUri.filename should match "document.pdf"'
    );
    Assert.areEqual(
      'https://example.com/download',
      downloadUri.url,
      'downloadUri.url should match "https://example.com/download"'
    );
    Assert.areEqual(
      '123456',
      downloadUri.otp,
      'downloadUri.otp should match "123456"'
    );
    Assert.areEqual(
      'EXTENSION_TYPE_PDF',
      downloadUri.extensionType,
      'downloadUri.extensionType should match "EXTENSION_TYPE_PDF"'
    );
    Assert.areEqual(
      '2023-09-01T12:00:00Z',
      downloadUri.createTime,
      'downloadUri.createTime should match "2023-09-01T12:00:00Z"'
    );
  }

  @isTest
  static void testDocumentFileDetails() {
    LexSettlementV1b1SettlementTypes.DocumentFileDetails fileDetails = new LexSettlementV1b1SettlementTypes.DocumentFileDetails();
    fileDetails.documentFileId = 'file-123';
    fileDetails.documentFileVersion = 3L;
    fileDetails.documentFileStatus = 'DOCUMENT_FILE_STATUS_ACTIVE';
    fileDetails.fileChecksum = 'abc123checksum';

    Assert.areEqual(
      'file-123',
      fileDetails.documentFileId,
      'fileDetails.documentFileId should match "file-123"'
    );
    Assert.areEqual(
      3L,
      fileDetails.documentFileVersion,
      'fileDetails.documentFileVersion should be 3L'
    );
    Assert.areEqual(
      'DOCUMENT_FILE_STATUS_ACTIVE',
      fileDetails.documentFileStatus,
      'fileDetails.documentFileStatus should match "DOCUMENT_FILE_STATUS_ACTIVE"'
    );
    Assert.areEqual(
      'abc123checksum',
      fileDetails.fileChecksum,
      'fileDetails.fileChecksum should match "abc123checksum"'
    );
  }

  @isTest
  static void testDocumentStatusDetail() {
    LexSettlementV1b1SettlementTypes.DocumentStatusDetail statusDetail = new LexSettlementV1b1SettlementTypes.DocumentStatusDetail();
    statusDetail.status = 'STATUS_ACCEPTED';
    statusDetail.statusTime = '2023-08-20T15:00:00Z';
    Assert.areEqual(
      'STATUS_ACCEPTED',
      statusDetail.status,
      'statusDetail.status should match "STATUS_ACCEPTED"'
    );
    Assert.areEqual(
      '2023-08-20T15:00:00Z',
      statusDetail.statusTime,
      'statusDetail.statusTime should match "2023-08-20T15:00:00Z"'
    );
  }

  @isTest
  static void testDocumentReference() {
    LexSettlementV1b1SettlementTypes.DocumentReference reference = new LexSettlementV1b1SettlementTypes.DocumentReference();
    reference.id = 'doc-ref-123';
    reference.type = 'TYPE_PRIMARY';
    reference.documentStatusDetails = new List<LexSettlementV1b1SettlementTypes.DocumentStatusDetail>();

    Assert.areEqual(
      'doc-ref-123',
      reference.id,
      'reference.id should match "doc-ref-123"'
    );
    Assert.areEqual(
      'TYPE_PRIMARY',
      reference.type,
      'reference.type should match "TYPE_PRIMARY"'
    );
    Assert.areEqual(
      0,
      reference.documentStatusDetails.size(),
      'reference.documentStatusDetails.size should be 0'
    );
  }

  @isTest
  static void testDocumentUploadUri() {
    LexSettlementV1b1SettlementTypes.DocumentUploadUri docUri = new LexSettlementV1b1SettlementTypes.DocumentUploadUri();
    docUri.url = 'https://signed-url.com/upload';
    docUri.otp = '123456';
    docUri.traceId = 'trace-abc-123';
    docUri.contentDisposition = 'attachment; filename="file.pdf"';

    Assert.areEqual(
      'https://signed-url.com/upload',
      docUri.url,
      'docUri.url should match "https://signed-url.com/upload"'
    );
    Assert.areEqual('123456', docUri.otp, 'docUri.otp should match "123456"');
    Assert.areEqual(
      'trace-abc-123',
      docUri.traceId,
      'docUri.traceId should match "trace-abc-123"'
    );
    Assert.areEqual(
      'attachment; filename="file.pdf"',
      docUri.contentDisposition,
      'docUri.contentDisposition should match "attachment; filename=\"file.pdf\""'
    );
  }

  @isTest
  static void testDrawdown() {
    LexSettlementV1b1SettlementTypes.Drawdown drawdown = new LexSettlementV1b1SettlementTypes.Drawdown();
    drawdown.id = 'drawdown-123';
    drawdown.settlementId = 'settlement-456';
    drawdown.state = 'STATE_COMPLETED';
    drawdown.loanFacilityConfigId = 'loan-config-789';
    drawdown.drawdownDateTime = '2023-10-10T10:00:00Z';
    drawdown.drawdownType = 'TYPE_SURPLUS';
    drawdown.loanFacility = new List<LexSettlementV1b1SettlementTypes.LoanFacility>();
    drawdown.loanFacility.add(
      new LexSettlementV1b1SettlementTypes.LoanFacility()
    );
    drawdown.estimatedProcessingStartTime = '2023-10-10T09:30:00Z';
    drawdown.scheduledReason = 'SCHEDULED_REASON_NON_PROCESSING_TIME';

    Assert.areEqual(
      'drawdown-123',
      drawdown.id,
      'drawdown.id should match "drawdown-123"'
    );
    Assert.areEqual(
      'settlement-456',
      drawdown.settlementId,
      'drawdown.settlementId should match "settlement-456"'
    );
    Assert.areEqual(
      'STATE_COMPLETED',
      drawdown.state,
      'drawdown.state should match "STATE_COMPLETED"'
    );
    Assert.areEqual(
      'loan-config-789',
      drawdown.loanFacilityConfigId,
      'drawdown.loanFacilityConfigId should match "loan-config-789"'
    );
    Assert.areEqual(
      '2023-10-10T10:00:00Z',
      drawdown.drawdownDateTime,
      'drawdown.drawdownDateTime should match "2023-10-10T10:00:00Z"'
    );
    Assert.areEqual(
      'TYPE_SURPLUS',
      drawdown.drawdownType,
      'drawdown.drawdownType should match "TYPE_SURPLUS"'
    );
    Assert.areEqual(
      true,
      drawdown.loanFacility.size() > 0,
      'drawdown.loanFacility.size should be > 0'
    );
    Assert.areEqual(
      '2023-10-10T09:30:00Z',
      drawdown.estimatedProcessingStartTime,
      'drawdown.estimatedProcessingStartTime should match "2023-10-10T09:30:00Z"'
    );
    Assert.areEqual(
      'SCHEDULED_REASON_NON_PROCESSING_TIME',
      drawdown.scheduledReason,
      'drawdown.scheduledReason should match "SCHEDULED_REASON_NON_PROCESSING_TIME"'
    );
  }

  @isTest
  static void testDrawdownOutcome() {
    LexSettlementV1b1SettlementTypes.DrawdownOutcome outcome = new LexSettlementV1b1SettlementTypes.DrawdownOutcome();
    outcome.id = 'outcome-123';
    outcome.loanFacilityId = 'loan-facility-456';
    outcome.loanAccountStatus = 'ACTIVE';
    outcome.drawdownTransactionSequence = 'TXN-001';
    outcome.drawdownAccountSequence = 'ACC-001';
    outcome.drawdownPcdSequence = 'PCD-001';
    outcome.drawdownTrace = 'trace-xyz';
    outcome.drawdownIdempotencyKey = 'idempotency-key-abc';
    outcome.drawdownIdempotencyFirstSent = 'first-sent-123';
    outcome.packageNumber = 'PKG-001';

    Assert.areEqual(
      'outcome-123',
      outcome.id,
      'outcome.id should match "outcome-123"'
    );
    Assert.areEqual(
      'loan-facility-456',
      outcome.loanFacilityId,
      'outcome.loanFacilityId should match "loan-facility-456"'
    );
    Assert.areEqual(
      'ACTIVE',
      outcome.loanAccountStatus,
      'outcome.loanAccountStatus should match "ACTIVE"'
    );
    Assert.areEqual(
      'TXN-001',
      outcome.drawdownTransactionSequence,
      'outcome.drawdownTransactionSequence should match "TXN-001"'
    );
    Assert.areEqual(
      'ACC-001',
      outcome.drawdownAccountSequence,
      'outcome.drawdownAccountSequence should match "ACC-001"'
    );
    Assert.areEqual(
      'PCD-001',
      outcome.drawdownPcdSequence,
      'outcome.drawdownPcdSequence should match "PCD-001"'
    );
    Assert.areEqual(
      'trace-xyz',
      outcome.drawdownTrace,
      'outcome.drawdownTrace should match "trace-xyz"'
    );
    Assert.areEqual(
      'idempotency-key-abc',
      outcome.drawdownIdempotencyKey,
      'outcome.drawdownIdempotencyKey should match "idempotency-key-abc"'
    );
    Assert.areEqual(
      'first-sent-123',
      outcome.drawdownIdempotencyFirstSent,
      'outcome.drawdownIdempotencyFirstSent should match "first-sent-123"'
    );
    Assert.areEqual(
      'PKG-001',
      outcome.packageNumber,
      'outcome.packageNumber should match "PKG-001"'
    );
  }

  @isTest
  static void testDrawdownTransaction() {
    LexSettlementV1b1SettlementTypes.DrawdownTransaction txn = new LexSettlementV1b1SettlementTypes.DrawdownTransaction();
    txn.id = 'txn-123';
    txn.settlementId = 'settlement-456';
    txn.drawdownId = 'drawdown-789';
    txn.drawdownTransactionType = 'DRAWDOWN_TRANSACTION_TYPE_DRAW';
    txn.accounts = new List<LexSettlementV1b1SettlementTypes.DrawdownTransactionAccount>();
    LexSettlementV1b1SettlementTypes.DrawdownTransactionAccount account = new LexSettlementV1b1SettlementTypes.DrawdownTransactionAccount();
    account.accounts = new LexSettlementV1b1SettlementTypes.AccountId();
    account.accounts.apxrsvdNumber = '987654321';
    account.accounts.bsbNumber = '654-321';
    account.drawdownTransactionAccountType = 'DRAWDOWN_TRANSACTION_ACCOUNT_TYPE_CREDIT';
    txn.accounts.add(account);

    Assert.areEqual('txn-123', txn.id, 'txn.id should match "txn-123"');
    Assert.areEqual(
      'settlement-456',
      txn.settlementId,
      'txn.settlementId should match "settlement-456"'
    );
    Assert.areEqual(
      'drawdown-789',
      txn.drawdownId,
      'txn.drawdownId should match "drawdown-789"'
    );
    Assert.areEqual(
      'DRAWDOWN_TRANSACTION_TYPE_DRAW',
      txn.drawdownTransactionType,
      'txn.drawdownTransactionType should match "DRAWDOWN_TRANSACTION_TYPE_DRAW"'
    );
    Assert.areEqual(1, txn.accounts.size(), 'txn.accounts.size should be 1');
    Assert.areEqual(
      '987654321',
      txn.accounts[0].accounts.apxrsvdNumber,
      'txn.accounts[0].accounts.apxrsvdNumber should match "987654321"'
    );
    Assert.areEqual(
      '654-321',
      txn.accounts[0].accounts.bsbNumber,
      'txn.accounts[0].accounts.bsbNumber should match "654-321"'
    );
    Assert.areEqual(
      'DRAWDOWN_TRANSACTION_ACCOUNT_TYPE_CREDIT',
      txn.accounts[0].drawdownTransactionAccountType,
      'txn.accounts[0].drawdownTransactionAccountType should match "DRAWDOWN_TRANSACTION_ACCOUNT_TYPE_CREDIT"'
    );
  }

  @isTest
  static void testEConveyancingWorkspace() {
    LexSettlementV1b1SettlementTypes.EConveyancingWorkspace ws = new LexSettlementV1b1SettlementTypes.EConveyancingWorkspace();
    ws.id = 'WS-001';
    ws.settlementId = 'SETT-123';
    ws.econveyancingSystemType = 'ECONVEYANCING_SYSTEM_TYPE_PEXA';
    ws.workspaceId = 'PEXA-999';
    ws.mortgageContractIds = new List<String>{ 'MC-001', 'MC-002' };
    ws.workspaceCreateTime = '2025-08-18T10:00:00Z';
    ws.workspaceUpdateTime = '2025-08-18T12:00:00Z';
    ws.totalUnreadConversations = 5;
    ws.conversations = new List<LexSettlementV1b1SettlementTypes.Conversation>{
      new LexSettlementV1b1SettlementTypes.Conversation()
    };
    Assert.areEqual('WS-001', ws.id, 'ws.id should match "WS-001"');
  }

  @isTest
  static void testEligibleNominatingAccount() {
    LexSettlementV1b1SettlementTypes.EligibleNominatingAccount ena = new LexSettlementV1b1SettlementTypes.EligibleNominatingAccount();
    ena.account = '123456789';
    ena.usageType = new List<String>{
      'USAGE_TYPE_SETTLEMENT',
      'USAGE_TYPE_LOAN_REPAYMENT'
    };
    Assert.areEqual(
      '123456789',
      ena.account,
      'ena.account should match "123456789"'
    );
  }

  @isTest
  static void testFee() {
    LexSettlementV1b1SettlementTypes.Fee fee = new LexSettlementV1b1SettlementTypes.Fee();
    fee.feeId = 'FEE-101';
    fee.code = 'CODE_REGISTRATION_OF_MORTGAGE';
    fee.feeSource = 'SOURCE_ANZ';
    Assert.areEqual('FEE-101', fee.feeId, 'fee.feeId should match "FEE-101"');
  }

  @isTest
  static void testFinancialDestination() {
    LexSettlementV1b1SettlementTypes.FinancialDestination fd = new LexSettlementV1b1SettlementTypes.FinancialDestination();
    fd.id = 'FD-001';
    fd.lineNumber = 10;
    fd.category = 'FINANCIAL_DESTINATION_CATEGORY_STAMP_DUTY_DISBURSEMENT';
    fd.lineNumberDestination = 'D01';

    Assert.areEqual('FD-001', fd.id, 'fd.id should match "FD-001"');
    Assert.areEqual(10, fd.lineNumber, 'fd.lineNumber should be 10');
    Assert.areEqual(
      'FINANCIAL_DESTINATION_CATEGORY_STAMP_DUTY_DISBURSEMENT',
      fd.category,
      'fd.category should match "FINANCIAL_DESTINATION_CATEGORY_STAMP_DUTY_DISBURSEMENT"'
    );
    Assert.areEqual(
      'D01',
      fd.lineNumberDestination,
      'fd.lineNumberDestination should match "D01"'
    );
  }

  @isTest
  static void testFinancialSource() {
    LexSettlementV1b1SettlementTypes.FinancialSource fs = new LexSettlementV1b1SettlementTypes.FinancialSource();
    fs.id = 'FS-001';
    fs.lineNumber = 20;
    fs.category = 'FINANCIAL_SOURCE_CATEGORY_VENDOR_TO_PAY_SOURCE';
    fs.state = 'FINANCIAL_SOURCE_FUND_STATE_READY';
    fs.lineNumberSource = 'S01';

    Assert.areEqual('FS-001', fs.id, 'fs.id should match "FS-001"');
    Assert.areEqual(20, fs.lineNumber, 'fs.lineNumber should be 20');
    Assert.areEqual(
      'FINANCIAL_SOURCE_CATEGORY_VENDOR_TO_PAY_SOURCE',
      fs.category,
      'fs.category should match "FINANCIAL_SOURCE_CATEGORY_VENDOR_TO_PAY_SOURCE"'
    );
    Assert.areEqual(
      'FINANCIAL_SOURCE_FUND_STATE_READY',
      fs.state,
      'fs.state should match "FINANCIAL_SOURCE_FUND_STATE_READY"'
    );
    Assert.areEqual(
      'S01',
      fs.lineNumberSource,
      'fs.lineNumberSource should match "S01"'
    );
  }

  @isTest
  static void testFinancialSettlement() {
    LexSettlementV1b1SettlementTypes.FinancialSettlement fs = new LexSettlementV1b1SettlementTypes.FinancialSettlement();
    fs.id = 'FSET-001';
    fs.settlementId = 'SETT-123';
    fs.state = 'STATE_SETTLED';
    fs.financialSources = new List<LexSettlementV1b1SettlementTypes.FinancialSource>{
      new LexSettlementV1b1SettlementTypes.FinancialSource()
    };
    fs.financialDestinations = new List<LexSettlementV1b1SettlementTypes.FinancialDestination>{
      new LexSettlementV1b1SettlementTypes.FinancialDestination()
    };
    fs.signingActivity = new List<LexSettlementV1b1SettlementTypes.SigningActivity>();
    fs.signaturesRequired = 2;
    fs.signaturesReceived = 1;

    Assert.areEqual('FSET-001', fs.id, 'fs.id should match "FSET-001"');
    Assert.areEqual(
      'SETT-123',
      fs.settlementId,
      'fs.settlementId should match "SETT-123"'
    );
    Assert.areEqual(
      'STATE_SETTLED',
      fs.state,
      'fs.state should match "STATE_SETTLED"'
    );
    Assert.areEqual(
      2,
      fs.signaturesRequired,
      'fs.signaturesRequired should be 2'
    );
    Assert.areEqual(
      1,
      fs.signaturesReceived,
      'fs.signaturesReceived should be 1'
    );
  }

  @isTest
  static void testLoan() {
    LexSettlementV1b1SettlementTypes.Loan loan = new LexSettlementV1b1SettlementTypes.Loan();
    loan.settlementId = 'SETT-001';
    loan.loanApplicationId = 'APP-123456';
    loan.loanApplicationTime = '2023-10-10T10:00:00Z';
    loan.loanPurposeCode = 'LOAN_PURPOSE_CODE_REFINANCE_EXTERNAL';
    loan.documents = new List<LexSettlementV1b1SettlementTypes.LoanDocument>{
      new LexSettlementV1b1SettlementTypes.LoanDocument()
    };
    loan.state = 'STATE_COMMITTED';
    loan.loanContractAcceptances = new List<LexSettlementV1b1SettlementTypes.LoanContractAcceptance>{
      new LexSettlementV1b1SettlementTypes.LoanContractAcceptance()
    };
    loan.offerExpireTime = '2023-12-01T12:00:00Z';
    loan.loanProperties = new List<LexSettlementV1b1SettlementTypes.LoanProperty>{
      new LexSettlementV1b1SettlementTypes.LoanProperty()
    };
    loan.originator = new LexSettlementV1b1SettlementTypes.Originator();

    Assert.areEqual(
      'SETT-001',
      loan.settlementId,
      'loan.settlementId should match "SETT-001"'
    );
    Assert.areEqual(
      'APP-123456',
      loan.loanApplicationId,
      'loan.loanApplicationId should match "APP-123456"'
    );
    Assert.areEqual(
      'STATE_COMMITTED',
      loan.state,
      'loan.state should match "STATE_COMMITTED"'
    );
    Assert.areEqual(
      1,
      loan.documents.size(),
      'loan.documents.size should be 1'
    );
    Assert.areEqual(
      1,
      loan.loanContractAcceptances.size(),
      'loan.loanContractAcceptances.size should be 1'
    );
  }

  @isTest
  static void testLoanContractAcceptance() {
    LexSettlementV1b1SettlementTypes.LoanContractAcceptance acceptance = new LexSettlementV1b1SettlementTypes.LoanContractAcceptance();
    acceptance.id = 'LCA-001';
    acceptance.partyId = 'PARTY-123';
    acceptance.createTime = '2023-09-15T09:00:00Z';
    acceptance.documentReferences = new List<LexSettlementV1b1SettlementTypes.AcceptedDocument>{
      new LexSettlementV1b1SettlementTypes.AcceptedDocument()
    };
    acceptance.termsAndConditionsVersion = 'v1.0';
    acceptance.acceptanceId = 'ACC-789';
    acceptance.state = 'STATE_ACTIVE';
    acceptance.personaId = 'PERSONA-999';

    Assert.areEqual(
      'LCA-001',
      acceptance.id,
      'acceptance.id should match "LCA-001"'
    );
    Assert.areEqual(
      'PARTY-123',
      acceptance.partyId,
      'acceptance.partyId should match "PARTY-123"'
    );
    Assert.areEqual(
      'ACC-789',
      acceptance.acceptanceId,
      'acceptance.acceptanceId should match "ACC-789"'
    );
    Assert.areEqual(
      'STATE_ACTIVE',
      acceptance.state,
      'acceptance.state should match "STATE_ACTIVE"'
    );
    Assert.areEqual(
      1,
      acceptance.documentReferences.size(),
      'acceptance.documentReferences.size should be 1'
    );
  }

  @isTest
  static void testLoanDocument() {
    LexSettlementV1b1SettlementTypes.LoanDocument loanDoc = new LexSettlementV1b1SettlementTypes.LoanDocument();
    loanDoc.settlementId = 'settlement-123';
    loanDoc.documentSubtype = 'SUBTYPE_SIGNED';

    Assert.areEqual(
      'settlement-123',
      loanDoc.settlementId,
      'loanDoc.settlementId should match "settlement-123"'
    );
    Assert.areEqual(
      'SUBTYPE_SIGNED',
      loanDoc.documentSubtype,
      'loanDoc.documentSubtype should match "SUBTYPE_SIGNED"'
    );
  }

  @isTest
  static void testLoanFacility() {
    LexSettlementV1b1SettlementTypes.LoanFacility facility = new LexSettlementV1b1SettlementTypes.LoanFacility();
    facility.id = 'facility-789';
    facility.loanAccount = new LexSettlementV1b1SettlementTypes.AccountId();
    facility.loanAccount.apxrsvdNumber = '987654321';
    facility.loanAccount.bsbNumber = '321-654';
    facility.loanAccountStatus = 'ACTIVE';

    Assert.areEqual(
      'facility-789',
      facility.id,
      'facility.id should match "facility-789"'
    );
    Assert.areEqual(
      '987654321',
      facility.loanAccount.apxrsvdNumber,
      'facility.loanAccount.apxrsvdNumber should match "987654321"'
    );
    Assert.areEqual(
      '321-654',
      facility.loanAccount.bsbNumber,
      'facility.loanAccount.bsbNumber should match "321-654"'
    );
    Assert.areEqual(
      'ACTIVE',
      facility.loanAccountStatus,
      'facility.loanAccountStatus should match "ACTIVE"'
    );
  }

  @isTest
  static void testLoanFacilityConfig() {
    LexSettlementV1b1SettlementTypes.LoanFacilityConfig config = new LexSettlementV1b1SettlementTypes.LoanFacilityConfig();
    config.id = 'config-101112';
    config.settlementId = 'settlement-131415';
    config.productMarketingCode = 'HLVAR01';
    config.loanTermMonths = 360;
    config.initialMargin = 150;
    config.initialInterestRate = 450;
    config.propertyUsageType = 'OWNER_OCCUPIED';
    config.offset = true;
    config.capLoanPurposeCode = '370';
    config.account = 'account-161718';
    config.initialTermMonths = 24;
    config.repaymentType = 'REPAYMENT_TYPE_INTEREST_ONLY';
    config.productType = 'HomeLoan';

    Assert.areEqual(
      'config-101112',
      config.id,
      'config.id should match "config-101112"'
    );
    Assert.areEqual(
      'settlement-131415',
      config.settlementId,
      'config.settlementId should match "settlement-131415"'
    );
    Assert.areEqual(
      'HLVAR01',
      config.productMarketingCode,
      'config.productMarketingCode should match "HLVAR01"'
    );
    Assert.areEqual(
      360,
      config.loanTermMonths,
      'config.loanTermMonths should be 360'
    );
    Assert.areEqual(
      150,
      config.initialMargin,
      'config.initialMargin should be 150'
    );
    Assert.areEqual(
      450,
      config.initialInterestRate,
      'config.initialInterestRate should be 450'
    );
    Assert.areEqual(
      'OWNER_OCCUPIED',
      config.propertyUsageType,
      'config.propertyUsageType should match "OWNER_OCCUPIED"'
    );
    Assert.areEqual(true, config.offset, 'config.offset should be true');
    Assert.areEqual(
      '370',
      config.capLoanPurposeCode,
      'config.capLoanPurposeCode should match "370"'
    );
    Assert.areEqual(
      'account-161718',
      config.account,
      'config.account should match "account-161718"'
    );
    Assert.areEqual(
      24,
      config.initialTermMonths,
      'config.initialTermMonths should be 24'
    );
    Assert.areEqual(
      'REPAYMENT_TYPE_INTEREST_ONLY',
      config.repaymentType,
      'config.repaymentType should match "REPAYMENT_TYPE_INTEREST_ONLY"'
    );
    Assert.areEqual(
      'HomeLoan',
      config.productType,
      'config.productType should match "HomeLoan"'
    );
  }

  @isTest
  static void testLoanOffset() {
    LexSettlementV1b1SettlementTypes.LoanOffset loanOffset = new LexSettlementV1b1SettlementTypes.LoanOffset();
    loanOffset.name = 'settlements/12345/loan/loan-facility-configs/67890/loan-offset';
    loanOffset.settlementId = 'settlement-12345';
    loanOffset.loanFacilityConfigId = 'config-67890';
    loanOffset.loanOffsetAccounts = new List<String>{
      'account-111',
      'account-222'
    };
    loanOffset.state = 'STATE_PENDING_CONFIRMATION';
    loanOffset.offsetPreference = 'OFFSET_PREFERENCE_ON';
    loanOffset.createTime = '2023-09-01T10:00:00Z';
    loanOffset.updateTime = '2023-09-02T12:00:00Z';
    loanOffset.confirmation = new List<LexSettlementV1b1SettlementTypes.Confirmation>{
      new LexSettlementV1b1SettlementTypes.Confirmation()
    };
    loanOffset.etag = 'etag-123';
    loanOffset.offsetFulfillment = new LexSettlementV1b1SettlementTypes.OffsetFulfillment();
    loanOffset.nominatedOffsetAccounts = new List<LexSettlementV1b1SettlementTypes.NominatedAccount>{
      new LexSettlementV1b1SettlementTypes.NominatedAccount()
    };

    Assert.areEqual(
      'settlements/12345/loan/loan-facility-configs/67890/loan-offset',
      loanOffset.name,
      'loanOffset.name should match "settlements/12345/loan/loan-facility-configs/67890/loan-offset"'
    );
    Assert.areEqual(
      'settlement-12345',
      loanOffset.settlementId,
      'loanOffset.settlementId should match "settlement-12345"'
    );
    Assert.areEqual(
      'config-67890',
      loanOffset.loanFacilityConfigId,
      'loanOffset.loanFacilityConfigId should match "config-67890"'
    );
    Assert.areEqual(
      2,
      loanOffset.loanOffsetAccounts.size(),
      'loanOffset.loanOffsetAccounts.size should be 2'
    );
    Assert.areEqual(
      'STATE_PENDING_CONFIRMATION',
      loanOffset.state,
      'loanOffset.state should match "STATE_PENDING_CONFIRMATION"'
    );
    Assert.areEqual(
      'OFFSET_PREFERENCE_ON',
      loanOffset.offsetPreference,
      'loanOffset.offsetPreference should match "OFFSET_PREFERENCE_ON"'
    );
    Assert.areEqual(
      '2023-09-01T10:00:00Z',
      loanOffset.createTime,
      'loanOffset.createTime should match "2023-09-01T10:00:00Z"'
    );
    Assert.areEqual(
      '2023-09-02T12:00:00Z',
      loanOffset.updateTime,
      'loanOffset.updateTime should match "2023-09-02T12:00:00Z"'
    );
    Assert.areEqual(
      1,
      loanOffset.confirmation.size(),
      'loanOffset.confirmation.size should be 1'
    );
    Assert.areEqual(
      'etag-123',
      loanOffset.etag,
      'loanOffset.etag should match "etag-123"'
    );
    Assert.areNotEqual(
      null,
      loanOffset.offsetFulfillment,
      'loanOffset.offsetFulfillment should not be null'
    );
    Assert.areEqual(
      1,
      loanOffset.nominatedOffsetAccounts.size(),
      'loanOffset.nominatedOffsetAccounts.size should be 1'
    );
  }

  @isTest
  static void testLoanProperty() {
    LexSettlementV1b1SettlementTypes.LoanProperty loanProperty = new LexSettlementV1b1SettlementTypes.LoanProperty();
    loanProperty.propertyId = 'property-98765';
    loanProperty.propertyUsage = 'PROPERTY_USAGE_OWNER_OCCUPIED';

    Assert.areEqual(
      'property-98765',
      loanProperty.propertyId,
      'loanProperty.propertyId should match "property-98765"'
    );
    Assert.areEqual(
      'PROPERTY_USAGE_OWNER_OCCUPIED',
      loanProperty.propertyUsage,
      'loanProperty.propertyUsage should match "PROPERTY_USAGE_OWNER_OCCUPIED"'
    );
  }

  @isTest
  static void testLoanTermDetails() {
    LexSettlementV1b1SettlementTypes.LoanTermDetails termDetails = new LexSettlementV1b1SettlementTypes.LoanTermDetails();
    termDetails.loanTermMonths = 360;
    termDetails.indexInterestRate = 250;
    termDetails.margin = 150;
    termDetails.offeredInterestRate = 400;
    termDetails.type = 'REPAYMENT_TYPE_INTEREST_ONLY';

    Assert.areEqual(
      360,
      termDetails.loanTermMonths,
      'termDetails.loanTermMonths should be 360'
    );
    Assert.areEqual(
      250,
      termDetails.indexInterestRate,
      'termDetails.indexInterestRate should be 250'
    );
    Assert.areEqual(
      150,
      termDetails.margin,
      'termDetails.margin should be 150'
    );
    Assert.areEqual(
      400,
      termDetails.offeredInterestRate,
      'termDetails.offeredInterestRate should be 400'
    );
    Assert.areEqual(
      'REPAYMENT_TYPE_INTEREST_ONLY',
      termDetails.type,
      'termDetails.type should match "REPAYMENT_TYPE_INTEREST_ONLY"'
    );
  }

  @isTest
  static void testMortgageContract() {
    LexSettlementV1b1SettlementTypes.MortgageContract mortgageContract = new LexSettlementV1b1SettlementTypes.MortgageContract();
    mortgageContract.id = 'mortgage-001';
    mortgageContract.settlementId = 'settlement-123';
    mortgageContract.propertyIds = new List<String>{
      'property-111',
      'property-222'
    };
    mortgageContract.state = 'STATE_ACCEPTED';
    mortgageContract.mortgageLodgementId = 'lodgement-xyz';
    mortgageContract.settlementTime = '2023-09-15T10:00:00Z';
    mortgageContract.documents = new List<LexSettlementV1b1SettlementTypes.MortgageContractDocument>{
      new LexSettlementV1b1SettlementTypes.MortgageContractDocument()
    };
    mortgageContract.fees = new List<LexSettlementV1b1SettlementTypes.Fee>{
      new LexSettlementV1b1SettlementTypes.Fee()
    };
    mortgageContract.mortgageReleaseAuthority = new LexSettlementV1b1SettlementTypes.MortgageReleaseAuthority();
    mortgageContract.mortgageContractAcceptances = new List<LexSettlementV1b1SettlementTypes.MortgageContractAcceptance>{
      new LexSettlementV1b1SettlementTypes.MortgageContractAcceptance()
    };
    mortgageContract.jurisdiction = 'JURISDICTION_VIC';
    mortgageContract.titleActivity = new List<LexSettlementV1b1SettlementTypes.TitleActivity>{
      new LexSettlementV1b1SettlementTypes.TitleActivity()
    };
    mortgageContract.settlementTimeState = 'SETTLEMENT_TIME_STATE_ACCEPTED';

    Assert.areEqual(
      'mortgage-001',
      mortgageContract.id,
      'mortgageContract.id should match "mortgage-001"'
    );
    Assert.areEqual(
      'settlement-123',
      mortgageContract.settlementId,
      'mortgageContract.settlementId should match "settlement-123"'
    );
    Assert.areEqual(
      2,
      mortgageContract.propertyIds.size(),
      'mortgageContract.propertyIds.size should be 2'
    );
    Assert.areEqual(
      'STATE_ACCEPTED',
      mortgageContract.state,
      'mortgageContract.state should match "STATE_ACCEPTED"'
    );
    Assert.areEqual(
      'lodgement-xyz',
      mortgageContract.mortgageLodgementId,
      'mortgageContract.mortgageLodgementId should match "lodgement-xyz"'
    );
    Assert.areEqual(
      '2023-09-15T10:00:00Z',
      mortgageContract.settlementTime,
      'mortgageContract.settlementTime should match "2023-09-15T10:00:00Z"'
    );
    Assert.areEqual(
      1,
      mortgageContract.documents.size(),
      'mortgageContract.documents.size should be 1'
    );
    Assert.areEqual(
      1,
      mortgageContract.fees.size(),
      'mortgageContract.fees.size should be 1'
    );
    Assert.areNotEqual(
      null,
      mortgageContract.mortgageReleaseAuthority,
      'mortgageContract.mortgageReleaseAuthority should not be null'
    );
    Assert.areEqual(
      1,
      mortgageContract.mortgageContractAcceptances.size(),
      'mortgageContract.mortgageContractAcceptances.size should be 1'
    );
    Assert.areEqual(
      'JURISDICTION_VIC',
      mortgageContract.jurisdiction,
      'mortgageContract.jurisdiction should match "JURISDICTION_VIC"'
    );
    Assert.areEqual(
      1,
      mortgageContract.titleActivity.size(),
      'mortgageContract.titleActivity.size should be 1'
    );
    Assert.areEqual(
      'SETTLEMENT_TIME_STATE_ACCEPTED',
      mortgageContract.settlementTimeState,
      'mortgageContract.settlementTimeState should match "SETTLEMENT_TIME_STATE_ACCEPTED"'
    );
  }

  @isTest
  static void testMortgageContractAcceptance() {
    LexSettlementV1b1SettlementTypes.MortgageContractAcceptance acceptance = new LexSettlementV1b1SettlementTypes.MortgageContractAcceptance();
    acceptance.id = 'acceptance-001';
    acceptance.partyId = 'party-xyz';
    acceptance.createTime = '2023-09-10T11:00:00Z';
    acceptance.documentReferences = new List<LexSettlementV1b1SettlementTypes.AcceptedDocument>{
      new LexSettlementV1b1SettlementTypes.AcceptedDocument()
    };
    acceptance.mocpVersion = 'v1.0';
    acceptance.acceptanceId = 'ocv-123';
    acceptance.personaId = 'persona-999';

    Assert.areEqual(
      'acceptance-001',
      acceptance.id,
      'acceptance.id should match "acceptance-001"'
    );
    Assert.areEqual(
      'party-xyz',
      acceptance.partyId,
      'acceptance.partyId should match "party-xyz"'
    );
    Assert.areEqual(
      '2023-09-10T11:00:00Z',
      acceptance.createTime,
      'acceptance.createTime should match "2023-09-10T11:00:00Z"'
    );
    Assert.areEqual(
      1,
      acceptance.documentReferences.size(),
      'acceptance.documentReferences.size should be 1'
    );
    Assert.areEqual(
      'v1.0',
      acceptance.mocpVersion,
      'acceptance.mocpVersion should match "v1.0"'
    );
    Assert.areEqual(
      'ocv-123',
      acceptance.acceptanceId,
      'acceptance.acceptanceId should match "ocv-123"'
    );
    Assert.areEqual(
      'persona-999',
      acceptance.personaId,
      'acceptance.personaId should match "persona-999"'
    );
  }

  @isTest
  static void testMortgageContractDocument() {
    LexSettlementV1b1SettlementTypes.MortgageContractDocument mortgageDoc = new LexSettlementV1b1SettlementTypes.MortgageContractDocument();
    mortgageDoc.settlementId = 'settlement-123';
    mortgageDoc.mortgageContractId = 'mortgage-001';
    mortgageDoc.document = new LexSettlementV1b1SettlementTypes.Document();
    mortgageDoc.documentType = 'TYPE_MORTGAGE';
    mortgageDoc.documentSubtype = 'SUBTYPE_PDF';

    Assert.areEqual(
      'settlement-123',
      mortgageDoc.settlementId,
      'mortgageDoc.settlementId should match "settlement-123"'
    );
    Assert.areEqual(
      'mortgage-001',
      mortgageDoc.mortgageContractId,
      'mortgageDoc.mortgageContractId should match "mortgage-001"'
    );
    Assert.areNotEqual(
      null,
      mortgageDoc.document,
      'mortgageDoc.document should not be null'
    );
    Assert.areEqual(
      'TYPE_MORTGAGE',
      mortgageDoc.documentType,
      'mortgageDoc.documentType should match "TYPE_MORTGAGE"'
    );
    Assert.areEqual(
      'SUBTYPE_PDF',
      mortgageDoc.documentSubtype,
      'mortgageDoc.documentSubtype should match "SUBTYPE_PDF"'
    );
  }

  @isTest
  static void testMortgageReleaseAuthority() {
    LexSettlementV1b1SettlementTypes.MortgageReleaseAuthority authority = new LexSettlementV1b1SettlementTypes.MortgageReleaseAuthority();
    authority.id = 'release-001';
    authority.settlementId = 'settlement-001';
    authority.mortgageContractId = 'mortgage-001';
    authority.createTime = '2023-09-10T11:00:00Z';
    authority.createdBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    authority.createdBy.type = 'TYPE_PARTY';
    authority.createdBy.id = 'party-123';

    Assert.areEqual(
      'release-001',
      authority.id,
      'authority.id should match "release-001"'
    );
    Assert.areEqual(
      'settlement-001',
      authority.settlementId,
      'authority.settlementId should match "settlement-001"'
    );
    Assert.areEqual(
      'mortgage-001',
      authority.mortgageContractId,
      'authority.mortgageContractId should match "mortgage-001"'
    );
    Assert.areEqual(
      '2023-09-10T11:00:00Z',
      authority.createTime,
      'authority.createTime should match "2023-09-10T11:00:00Z"'
    );
    Assert.areNotEqual(
      null,
      authority.createdBy,
      'authority.createdBy should not be null'
    );
    Assert.areEqual(
      'TYPE_PARTY',
      authority.createdBy.type,
      'authority.createdBy.type should match "TYPE_PARTY"'
    );
    Assert.areEqual(
      'party-123',
      authority.createdBy.id,
      'authority.createdBy.id should match "party-123"'
    );
  }

  @isTest
  static void testNominatedAccount() {
    LexSettlementV1b1SettlementTypes.NominatedAccount nominatedAccount = new LexSettlementV1b1SettlementTypes.NominatedAccount();
    nominatedAccount.name = '123456789012345';
    nominatedAccount.bsb = '123456';
    nominatedAccount.accountName = 'John Doe';
    nominatedAccount.productDetails = new LexSettlementV1b1SettlementTypes.ProductDetails();
    nominatedAccount.productDetails.name = 'ANZ Everyday';

    Assert.areEqual(
      '123456789012345',
      nominatedAccount.name,
      'nominatedAccount.name should match "123456789012345"'
    );
    Assert.areEqual(
      '123456',
      nominatedAccount.bsb,
      'nominatedAccount.bsb should match "123456"'
    );
    Assert.areEqual(
      'John Doe',
      nominatedAccount.accountName,
      'nominatedAccount.accountName should match "John Doe"'
    );
    Assert.areNotEqual(
      null,
      nominatedAccount.productDetails,
      'nominatedAccount.productDetails should not be null'
    );
    Assert.areEqual(
      'ANZ Everyday',
      nominatedAccount.productDetails.name,
      'nominatedAccount.productDetails.name should match "ANZ Everyday"'
    );
  }

  @isTest
  static void testOffsetFulfillment() {
    LexSettlementV1b1SettlementTypes.OffsetFulfillment offsetFulfillment = new LexSettlementV1b1SettlementTypes.OffsetFulfillment();
    offsetFulfillment.failureReason = 'FAILURE_REASON_REQUEST_NOT_ACCEPTED';
    offsetFulfillment.loanOffsetChange = 'accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa-a717-d0de72971ace';

    Assert.areEqual(
      'FAILURE_REASON_REQUEST_NOT_ACCEPTED',
      offsetFulfillment.failureReason,
      'offsetFulfillment.failureReason should match "FAILURE_REASON_REQUEST_NOT_ACCEPTED"'
    );
    Assert.areEqual(
      'accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa-a717-d0de72971ace',
      offsetFulfillment.loanOffsetChange,
      'offsetFulfillment.loanOffsetChange should match "accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa-a717-d0de72971ace"'
    );
  }

  @isTest
  static void testOriginator() {
    LexSettlementV1b1SettlementTypes.Originator originator = new LexSettlementV1b1SettlementTypes.Originator();
    originator.tpmi = '4002';
    originator.sao = '002';

    Assert.areEqual(
      '4002',
      originator.tpmi,
      'originator.tpmi should match "4002"'
    );
    Assert.areEqual('002', originator.sao, 'originator.sao should match "002"');
  }

  @isTest
  static void testPartyIdentifier() {
    LexSettlementV1b1SettlementTypes.PartyIdentifier partyIdentifier = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    partyIdentifier.type = 'TYPE_PERSONA';
    partyIdentifier.id = 'persona-001';

    Assert.areEqual(
      'TYPE_PERSONA',
      partyIdentifier.type,
      'partyIdentifier.type should match "TYPE_PERSONA"'
    );
    Assert.areEqual(
      'persona-001',
      partyIdentifier.id,
      'partyIdentifier.id should match "persona-001"'
    );
  }

  @isTest
  static void testProductDetails() {
    LexSettlementV1b1SettlementTypes.ProductDetails productDetails = new LexSettlementV1b1SettlementTypes.ProductDetails();
    productDetails.name = 'ANZ Save';

    Assert.areEqual(
      'ANZ Save',
      productDetails.name,
      'productDetails.name should match "ANZ Save"'
    );
  }

  @isTest
  static void testProofOfInsuranceDocument() {
    LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument obj = new LexSettlementV1b1SettlementTypes.ProofOfInsuranceDocument();
    obj.settlementId = 'SETTLE-001';
    obj.mortgageContractId = 'MORT-002';
    obj.propertyId = 'PROP-003';
    LexSettlementV1b1SettlementTypes.Document doc = new LexSettlementV1b1SettlementTypes.Document();
    doc.id = 'DOC-100';
    obj.document = doc;
    LexSettlementV1b1SettlementTypes.ProofOfInsuranceVerification verification = new LexSettlementV1b1SettlementTypes.ProofOfInsuranceVerification();
    verification.state = 'STATE_VERIFIED';
    verification.documentId = 'DOC-100';
    obj.proofOfInsuranceVerification = verification;

    Assert.areEqual(
      'SETTLE-001',
      obj.settlementId,
      'obj.settlementId should match "SETTLE-001"'
    );
    Assert.areEqual(
      'MORT-002',
      obj.mortgageContractId,
      'obj.mortgageContractId should match "MORT-002"'
    );
    Assert.areEqual(
      'PROP-003',
      obj.propertyId,
      'obj.propertyId should match "PROP-003"'
    );
    Assert.areEqual(
      'DOC-100',
      obj.document.id,
      'obj.document.id should match "DOC-100"'
    );
    Assert.areEqual(
      'STATE_VERIFIED',
      obj.proofOfInsuranceVerification.state,
      'obj.proofOfInsuranceVerification.state should match "STATE_VERIFIED"'
    );
  }

  @isTest
  static void testProofOfInsuranceVerification() {
    LexSettlementV1b1SettlementTypes.ProofOfInsuranceVerification obj = new LexSettlementV1b1SettlementTypes.ProofOfInsuranceVerification();
    obj.state = 'STATE_REJECTED';
    obj.documentId = 'DOC-200';
    obj.documentFileVersion = 3L;
    obj.createTime = '2025-08-18T09:00:00Z';
    obj.updateTime = '2025-08-18T10:00:00Z';
    obj.rejectionReason = 'REJECTION_REASON_EXPIRED_BUILDING_INSURANCE_DOCUMENT_UPLOADED';
    LexSettlementV1b1SettlementTypes.PartyIdentifier createdBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    createdBy.type = 'TYPE_PARTY';
    createdBy.id = 'OCVID-11111';
    obj.createBy = createdBy;
    LexSettlementV1b1SettlementTypes.PartyIdentifier updatedBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    updatedBy.type = 'TYPE_PARTY';
    updatedBy.id = 'OCVID-22222';
    obj.updateBy = updatedBy;

    Assert.areEqual(
      'STATE_REJECTED',
      obj.state,
      'obj.state should match "STATE_REJECTED"'
    );
    Assert.areEqual(
      'DOC-200',
      obj.documentId,
      'obj.documentId should match "DOC-200"'
    );
    Assert.areEqual(
      3L,
      obj.documentFileVersion,
      'obj.documentFileVersion should be 3L'
    );
    Assert.areEqual(
      '2025-08-18T09:00:00Z',
      obj.createTime,
      'obj.createTime should match "2025-08-18T09:00:00Z"'
    );
    Assert.areEqual(
      '2025-08-18T10:00:00Z',
      obj.updateTime,
      'obj.updateTime should match "2025-08-18T10:00:00Z"'
    );
    Assert.areEqual(
      'REJECTION_REASON_EXPIRED_BUILDING_INSURANCE_DOCUMENT_UPLOADED',
      obj.rejectionReason,
      'obj.rejectionReason should match "REJECTION_REASON_EXPIRED_BUILDING_INSURANCE_DOCUMENT_UPLOADED"'
    );
    Assert.areEqual(
      'OCVID-11111',
      obj.createBy.id,
      'obj.createBy.id should match "OCVID-11111"'
    );
    Assert.areEqual(
      'OCVID-22222',
      obj.updateBy.id,
      'obj.updateBy.id should match "OCVID-22222"'
    );
  }

  @isTest
  static void testPropertyIdentifier() {
    LexSettlementV1b1SettlementTypes.PropertyIdentifier obj = new LexSettlementV1b1SettlementTypes.PropertyIdentifier();
    Assert.areNotEqual(null, obj, 'obj should not be null');
  }

  @isTest
  static void testPropertyIdentifierEligibility() {
    LexSettlementV1b1SettlementTypes.PropertyIdentifierEligibility obj = new LexSettlementV1b1SettlementTypes.PropertyIdentifierEligibility();
    obj.eligible = true;
    LexSettlementV1b1SettlementTypes.PropertyIdentifier identifier = new LexSettlementV1b1SettlementTypes.PropertyIdentifier();
    obj.identifier = identifier;

    Assert.areEqual(true, obj.eligible, 'obj.eligible should be true');
    Assert.areNotEqual(
      null,
      obj.identifier,
      'obj.identifier should not be null'
    );
  }

  @isTest
  static void testDocumentClass() {
    LexSettlementV1b1SettlementTypes.Document doc = new LexSettlementV1b1SettlementTypes.Document();
    doc.id = 'DOC-500';

    Assert.areEqual('DOC-500', doc.id, 'doc.id should match "DOC-500"');
  }

  @isTest
  static void testRepayments() {
    LexSettlementV1b1SettlementTypes.Repayments obj = new LexSettlementV1b1SettlementTypes.Repayments();
    obj.loanId = 'LN-123';
    obj.calculatedDateTime = '2025-08-18T09:30:00Z';
    obj.noRegularRepayments = 24;

    Assert.areEqual('LN-123', obj.loanId, 'obj.loanId should match "LN-123"');
    Assert.areEqual(
      '2025-08-18T09:30:00Z',
      obj.calculatedDateTime,
      'obj.calculatedDateTime should match "2025-08-18T09:30:00Z"'
    );
    Assert.areEqual(
      24,
      obj.noRegularRepayments,
      'obj.noRegularRepayments should be 24'
    );
  }

  @isTest
  static void testSettlement() {
    LexSettlementV1b1SettlementTypes.Settlement obj = new LexSettlementV1b1SettlementTypes.Settlement();
    obj.id = 'SETTLE-999';
    obj.createTime = '2025-08-18T10:00:00Z';
    obj.updateTime = '2025-08-18T10:30:00Z';
    obj.type = 'TYPE_REFINANCE_OFI';
    List<LexSettlementV1b1SettlementTypes.Task> taskList = new List<LexSettlementV1b1SettlementTypes.Task>();
    LexSettlementV1b1SettlementTypes.Task task = new LexSettlementV1b1SettlementTypes.Task();
    task.id = 'TASK-01';
    taskList.add(task);
    obj.tasks = taskList;

    Assert.areEqual('SETTLE-999', obj.id, 'obj.id should match "SETTLE-999"');
    Assert.areEqual(
      '2025-08-18T10:00:00Z',
      obj.createTime,
      'obj.createTime should match "2025-08-18T10:00:00Z"'
    );
    Assert.areEqual(
      'TYPE_REFINANCE_OFI',
      obj.type,
      'obj.type should match "TYPE_REFINANCE_OFI"'
    );
    Assert.areEqual(
      'TASK-01',
      obj.tasks[0].id,
      'obj.tasks[0].id should match "TASK-01"'
    );
  }

  @isTest
  static void testSettlementAccount() {
    LexSettlementV1b1SettlementTypes.SettlementAccount obj = new LexSettlementV1b1SettlementTypes.SettlementAccount();
    obj.settlementId = 'SET-ABC';
    obj.state = 'STATE_PENDING_CONFIRMATION';
    obj.createTime = '2025-08-18T08:00:00Z';
    obj.updateTime = '2025-08-18T09:00:00Z';
    obj.etag = 'etag-12345';
    LexSettlementV1b1SettlementTypes.PartyIdentifier createBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    createBy.type = 'TYPE_PARTY';
    createBy.id = 'OCVID-777';
    obj.createBy = createBy;
    LexSettlementV1b1SettlementTypes.PartyIdentifier updateBy = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    updateBy.type = 'TYPE_PARTY';
    updateBy.id = 'OCVID-888';
    obj.updateBy = updateBy;

    Assert.areEqual(
      'SET-ABC',
      obj.settlementId,
      'obj.settlementId should match "SET-ABC"'
    );
    Assert.areEqual(
      'STATE_PENDING_CONFIRMATION',
      obj.state,
      'obj.state should match "STATE_PENDING_CONFIRMATION"'
    );
    Assert.areEqual(
      'etag-12345',
      obj.etag,
      'obj.etag should match "etag-12345"'
    );
    Assert.areEqual(
      'OCVID-777',
      obj.createBy.id,
      'obj.createBy.id should match "OCVID-777"'
    );
    Assert.areEqual(
      'OCVID-888',
      obj.updateBy.id,
      'obj.updateBy.id should match "OCVID-888"'
    );
  }

  @isTest
  static void testSettlementState() {
    LexSettlementV1b1SettlementTypes.SettlementState obj = new LexSettlementV1b1SettlementTypes.SettlementState();
    obj.updateTime = '2025-08-18T10:00:00Z';
    obj.state = 'PENDING';
    obj.cancellable = true;

    Assert.areEqual(
      '2025-08-18T10:00:00Z',
      obj.updateTime,
      'obj.updateTime should match "2025-08-18T10:00:00Z"'
    );
    Assert.areEqual('PENDING', obj.state, 'obj.state should match "PENDING"');
    Assert.areEqual(true, obj.cancellable, 'obj.cancellable should be true');
  }

  @isTest
  static void testSettlementTimeAcceptance() {
    LexSettlementV1b1SettlementTypes.SettlementTimeAcceptance obj = new LexSettlementV1b1SettlementTypes.SettlementTimeAcceptance();
    obj.role = 'BORROWER';
    obj.state = 'ACCEPTED';

    Assert.areEqual('BORROWER', obj.role, 'obj.role should match "BORROWER"');
    Assert.areEqual('ACCEPTED', obj.state, 'obj.state should match "ACCEPTED"');
  }

  @isTest
  static void testSigningActivity() {
    LexSettlementV1b1SettlementTypes.SigningActivity obj = new LexSettlementV1b1SettlementTypes.SigningActivity();
    obj.apxrsvdDateTime = '2025-08-18T11:00:00Z';
    obj.detail = 'Signed by Lender';

    Assert.areEqual(
      '2025-08-18T11:00:00Z',
      obj.apxrsvdDateTime,
      'obj.apxrsvdDateTime should match "2025-08-18T11:00:00Z"'
    );
    Assert.areEqual(
      'Signed by Lender',
      obj.detail,
      'obj.detail should match "Signed by Lender"'
    );
  }

  @isTest
  static void testTask() {
    LexSettlementV1b1SettlementTypes.Task obj = new LexSettlementV1b1SettlementTypes.Task();
    obj.id = 'TASK-001';
    obj.relatedResourceName = 'settlement/1234/loan/document/1234';
    obj.type = 'DOCUMENT';
    obj.category = 'CATEGORY_DOCUMENT';
    obj.state = 'STATE_PENDING';
    obj.createTime = '2025-08-18T09:00:00Z';
    obj.completeTime = '2025-08-18T10:30:00Z';

    Assert.areEqual('TASK-001', obj.id, 'obj.id should match "TASK-001"');
    Assert.areEqual(
      'settlement/1234/loan/document/1234',
      obj.relatedResourceName,
      'obj.relatedResourceName should match "settlement/1234/loan/document/1234"'
    );
    Assert.areEqual('DOCUMENT', obj.type, 'obj.type should match "DOCUMENT"');
    Assert.areEqual(
      'CATEGORY_DOCUMENT',
      obj.category,
      'obj.category should match "CATEGORY_DOCUMENT"'
    );
    Assert.areEqual(
      'STATE_PENDING',
      obj.state,
      'obj.state should match "STATE_PENDING"'
    );
    Assert.areEqual(
      '2025-08-18T09:00:00Z',
      obj.createTime,
      'obj.createTime should match "2025-08-18T09:00:00Z"'
    );
  }
  @isTest
  static void testTaskEligibility() {
    LexSettlementV1b1SettlementTypes.PartyIdentifier party = new LexSettlementV1b1SettlementTypes.PartyIdentifier();
    party.type = 'PARTY';
    LexSettlementV1b1SettlementTypes.TaskEligibility obj = new LexSettlementV1b1SettlementTypes.TaskEligibility();
    obj.role = 'LENDER';
    obj.party = party;
    obj.partyIdentifiers = new List<LexSettlementV1b1SettlementTypes.PartyIdentifier>{
      party
    };

    Assert.areEqual('LENDER', obj.role, 'obj.role should match "LENDER"');
    Assert.areEqual(
      1,
      obj.partyIdentifiers.size(),
      'obj.partyIdentifiers.size should be 1'
    );
  }

  @isTest
  static void testTitleActivity() {
    LexSettlementV1b1SettlementTypes.TitleActivity obj = new LexSettlementV1b1SettlementTypes.TitleActivity();
    obj.apxrsvdDateTime = '2025-08-18T12:00:00Z';
    obj.detail = 'Title transferred successfully';

    Assert.areEqual(
      '2025-08-18T12:00:00Z',
      obj.apxrsvdDateTime,
      'obj.apxrsvdDateTime should match "2025-08-18T12:00:00Z"'
    );
    Assert.areEqual(
      'Title transferred successfully',
      obj.detail,
      'obj.detail should match "Title transferred successfully"'
    );
  }
}
