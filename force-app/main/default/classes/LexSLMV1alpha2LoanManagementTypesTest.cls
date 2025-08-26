/**
 * @description Test class for LexSLMV1alpha2LoanManagementTypes.
 * @author Mohit Tripathi
 * @since 08/2025
 */
@isTest
public class LexSLMV1alpha2LoanManagementTypesTest {
  @IsTest
  static void testAccountFields() {
    LexSLMV1alpha2LoanManagementTypes.Account account = new LexSLMV1alpha2LoanManagementTypes.Account();
    account.apxrsvdNumber = '123456789';
    account.bsb = '123456';
    Assert.areEqual(
      '123456789',
      account.apxrsvdNumber,
      'account.apxrsvdNumber should match "123456789"'
    );
    Assert.areEqual('123456', account.bsb, 'account.bsb should match "123456"');
  }
  @IsTest
  static void testApprovalFields() {
    LexSLMV1alpha2LoanManagementTypes.Approval approval = new LexSLMV1alpha2LoanManagementTypes.Approval();
    approval.state = 'STATE_APPROVED';
    approval.updatedTime = '2025-08-18T10:30:00Z';
    Assert.areEqual(
      'STATE_APPROVED',
      approval.state,
      'approval.state should match "STATE_APPROVED"'
    );
    Assert.areEqual(
      '2025-08-18T10:30:00Z',
      approval.updatedTime,
      'approval.updatedTime should match "2025-08-18T10:30:00Z"'
    );
  }
  @IsTest
  static void testAutomaticRepaymentPreferencesBasicFields() {
    LexSLMV1alpha2LoanManagementTypes.AutomaticRepaymentPreferences autoRepay = new LexSLMV1alpha2LoanManagementTypes.AutomaticRepaymentPreferences();
    autoRepay.accountNumber = 'ACC123';
    autoRepay.fromAccountNumber = 'FROM123';
    autoRepay.repaymentFrequency = 'REPAYMENT_FREQUENCY_MONTHLY';
    autoRepay.repaymentDate = '2025-09-01';
    autoRepay.pendingBillingChange = true;
    autoRepay.endOfMonth = true;
    Assert.areEqual(
      'ACC123',
      autoRepay.accountNumber,
      'autoRepay.accountNumber should match "ACC123"'
    );
    Assert.areEqual(
      'FROM123',
      autoRepay.fromAccountNumber,
      'autoRepay.fromAccountNumber should match "FROM123"'
    );
    Assert.areEqual(
      'REPAYMENT_FREQUENCY_MONTHLY',
      autoRepay.repaymentFrequency,
      'autoRepay.repaymentFrequency should match "REPAYMENT_FREQUENCY_MONTHLY"'
    );
    Assert.areEqual(
      '2025-09-01',
      autoRepay.repaymentDate,
      'autoRepay.repaymentDate should match "2025-09-01"'
    );
    Assert.areEqual(
      true,
      autoRepay.pendingBillingChange,
      'autoRepay.pendingBillingChange should be true'
    );
    Assert.areEqual(
      true,
      autoRepay.endOfMonth,
      'autoRepay.endOfMonth should be true'
    );
  }
  @IsTest
  static void testCollateralFields() {
    LexSLMV1alpha2LoanManagementTypes.Collateral collateral = new LexSLMV1alpha2LoanManagementTypes.Collateral();
    collateral.name = 'COLLATERAL_001';
    collateral.property = 'PROPERTY_123';
    Assert.areEqual(
      'COLLATERAL_001',
      collateral.name,
      'collateral.name should match "COLLATERAL_001"'
    );
    Assert.areEqual(
      'PROPERTY_123',
      collateral.property,
      'collateral.property should match "PROPERTY_123"'
    );
  }
  @IsTest
  static void testDocumentUploadUriFields() {
    LexSLMV1alpha2LoanManagementTypes.DocumentUploadUri docUri = new LexSLMV1alpha2LoanManagementTypes.DocumentUploadUri();
    docUri.url = 'https://signed-url.com/upload';
    docUri.otp = '123456';
    docUri.traceId = 'TRACE_ABC';
    docUri.contentDisposition = 'attachment; filename="doc.pdf"';
    Assert.areEqual(
      'https://signed-url.com/upload',
      docUri.url,
      'docUri.url should match "https://signed-url.com/upload"'
    );
    Assert.areEqual('123456', docUri.otp, 'docUri.otp should match "123456"');
    Assert.areEqual(
      'TRACE_ABC',
      docUri.traceId,
      'docUri.traceId should match "TRACE_ABC"'
    );
    Assert.areEqual(
      'attachment; filename="doc.pdf"',
      docUri.contentDisposition,
      'docUri.contentDisposition should match "attachment; filename=\"doc.pdf\""'
    );
  }
  @IsTest
  static void testDrawdownBasicFields() {
    LexSLMV1alpha2LoanManagementTypes.Drawdown drawdown = new LexSLMV1alpha2LoanManagementTypes.Drawdown();
    drawdown.name = 'DRAW001';
    drawdown.id = 'ID001';
    drawdown.state = 'STATE_PENDING';
    drawdown.drawdownType = 'TYPE_SURPLUS';
    drawdown.createTime = '2025-08-01T10:00:00Z';
    drawdown.updateTime = '2025-08-10T10:00:00Z';
    drawdown.processedTime = '2025-08-18T10:00:00Z';
    drawdown.scheduledReason = 'Scheduled due to refinance';
    drawdown.settlementAccount = 'ACC987654';
    Assert.areEqual(
      'DRAW001',
      drawdown.name,
      'drawdown.name should match "DRAW001"'
    );
    Assert.areEqual('ID001', drawdown.id, 'drawdown.id should match "ID001"');
    Assert.areEqual(
      'STATE_PENDING',
      drawdown.state,
      'drawdown.state should match "STATE_PENDING"'
    );
    Assert.areEqual(
      'TYPE_SURPLUS',
      drawdown.drawdownType,
      'drawdown.drawdownType should match "TYPE_SURPLUS"'
    );
    Assert.areEqual(
      '2025-08-01T10:00:00Z',
      drawdown.createTime,
      'drawdown.createTime should match "2025-08-01T10:00:00Z"'
    );
    Assert.areEqual(
      '2025-08-10T10:00:00Z',
      drawdown.updateTime,
      'drawdown.updateTime should match "2025-08-10T10:00:00Z"'
    );
    Assert.areEqual(
      '2025-08-18T10:00:00Z',
      drawdown.processedTime,
      'drawdown.processedTime should match "2025-08-18T10:00:00Z"'
    );
    Assert.areEqual(
      'Scheduled due to refinance',
      drawdown.scheduledReason,
      'drawdown.scheduledReason should match "Scheduled due to refinance"'
    );
    Assert.areEqual(
      'ACC987654',
      drawdown.settlementAccount,
      'drawdown.settlementAccount should match "ACC987654"'
    );
  }
  static void testDrawdownWithNestedObjects() {
    LexSLMV1alpha2LoanManagementTypes.Drawdown drawdown = new LexSLMV1alpha2LoanManagementTypes.Drawdown();
    drawdown.drawdownTransactions = new List<LexSLMV1alpha2LoanManagementTypes.DrawdownTransaction>();
    // Set Error
    LexSLMV1alpha2LoanManagementTypes.Error errorObj = new LexSLMV1alpha2LoanManagementTypes.Error();
    errorObj.code = 'ERROR_001';
    drawdown.error = errorObj;
    Assert.areEqual(
      0,
      drawdown.drawdownTransactions.size(),
      'drawdown.drawdownTransactions.size should be 0'
    );
    Assert.areEqual(
      'ERROR_001',
      drawdown.error.code,
      'drawdown.error.code should match "ERROR_001"'
    );
  }

  @IsTest
  static void testDrawdownTransaction() {
    LexSLMV1alpha2LoanManagementTypes.DrawdownTransaction obj = new LexSLMV1alpha2LoanManagementTypes.DrawdownTransaction();
    obj.id = 'TXN-12345';
    obj.type = 'TYPE_DRAW';
    obj.createTime = '2025-08-18T10:00:00Z';
    obj.updateTime = '2025-08-18T12:00:00Z';
    obj.accounts = new List<LexSLMV1alpha2LoanManagementTypes.DrawdownTransactionAccount>();
    LexSLMV1alpha2LoanManagementTypes.DrawdownTransactionAccount acc = new LexSLMV1alpha2LoanManagementTypes.DrawdownTransactionAccount();
    acc.type = 'TYPE_DEBIT';
    acc.account = new LexSLMV1alpha2LoanManagementTypes.Account();
    acc.account.apxrsvdNumber = 'Account-001';
    acc.account.bsb = '123456789';
    obj.accounts.add(acc);
    Assert.areEqual(
      'TXN-12345',
      obj.id,
      'drawdownTransaction.id should match "TXN-12345"'
    );
  }
  @IsTest
  static void testDrawdownTransactionAccount() {
    LexSLMV1alpha2LoanManagementTypes.DrawdownTransactionAccount obj = new LexSLMV1alpha2LoanManagementTypes.DrawdownTransactionAccount();
    obj.type = 'TYPE_CREDIT';
    obj.account = new LexSLMV1alpha2LoanManagementTypes.Account();
    obj.account.apxrsvdNumber = 'Account-XYZ';
    obj.account.bsb = '987654321';
    Assert.areEqual(
      'TYPE_CREDIT',
      obj.type,
      'drawdownTransactionAccount.type should match "TYPE_CREDIT"'
    );
  }
  @IsTest
  static void testExposure() {
    LexSLMV1alpha2LoanManagementTypes.Exposure obj = new LexSLMV1alpha2LoanManagementTypes.Exposure();
    obj.loanAccount = 'LN-12345';
    obj.properties = new List<String>{ 'Property-001', 'Property-002' };
    obj.applicationTime = '2025-08-18T09:00:00Z';
    Assert.areEqual(
      'LN-12345',
      obj.loanAccount,
      'exposure.loanAccount should match "LN-12345"'
    );
  }
  @IsTest
  static void testCollateral() {
    LexSLMV1alpha2LoanManagementTypes.Collateral obj = new LexSLMV1alpha2LoanManagementTypes.Collateral();
    obj.name = 'Collateral-001';
    obj.property = 'Property-ABC';
    Assert.areEqual(
      'Collateral-001',
      obj.name,
      'collateral.name should match "Collateral-001"'
    );
  }

  @isTest
  static void testFee() {
    LexSLMV1alpha2LoanManagementTypes.Fee fee = new LexSLMV1alpha2LoanManagementTypes.Fee();
    fee.id = 'fee-123';
    fee.code = 'ROM';
    fee.source = 'ANZ';
    Assert.areEqual('fee-123', fee.id, 'fee.id should match "fee-123"');
    Assert.areEqual('ROM', fee.code, 'fee.code should match "ROM"');
    Assert.areEqual('ANZ', fee.source, 'fee.source should match "ANZ"');
  }
  @isTest
  static void testFile() {
    LexSLMV1alpha2LoanManagementTypes.File file = new LexSLMV1alpha2LoanManagementTypes.File();
    file.id = 'file-001';
    file.title = 'Loan Document';
    file.description = 'Document for loan processing';
    file.name = 'loan_doc';
    file.extension = 'pdf';
    file.mimeType = 'application/pdf';
    file.createTime = '2023-10-02T10:00:00Z';
    Assert.areEqual('file-001', file.id, 'file.id should match "file-001"');
    Assert.areEqual(
      'Loan Document',
      file.title,
      'file.title should match "Loan Document"'
    );
    Assert.areEqual(
      'Document for loan processing',
      file.description,
      'file.description should match "Document for loan processing"'
    );
    Assert.areEqual('loan_doc', file.name, 'file.name should match "loan_doc"');
    Assert.areEqual('pdf', file.extension, 'file.extension should match "pdf"');
    Assert.areEqual(
      'application/pdf',
      file.mimeType,
      'file.mimeType should match "application/pdf"'
    );
    Assert.areEqual(
      '2023-10-02T10:00:00Z',
      file.createTime,
      'file.createTime should match "2023-10-02T10:00:00Z"'
    );
  }
  @isTest
  static void testListLoanOffsetChangesFilter() {
    LexSLMV1alpha2LoanManagementTypes.ListLoanOffsetChangesFilter filter = new LexSLMV1alpha2LoanManagementTypes.ListLoanOffsetChangesFilter();
    filter.operationStates = new List<String>{ 'PENDING', 'COMPLETED' };
    Assert.areEqual(
      2,
      filter.operationStates.size(),
      'filter.operationStates.size should be 2'
    );
    Assert.areEqual(
      'PENDING',
      filter.operationStates[0],
      'filter.operationStates[0] should match "PENDING"'
    );
    Assert.areEqual(
      'COMPLETED',
      filter.operationStates[1],
      'filter.operationStates[1] should match "COMPLETED"'
    );
  }

  @isTest
  static void testLoanAccount() {
    LexSLMV1alpha2LoanManagementTypes.LoanAccount account = new LexSLMV1alpha2LoanManagementTypes.LoanAccount();
    account.name = 'loan-acc-001';
    account.account = 'real-acc-123';
    account.productType = 'Owner Occupied';
    account.termMonths = 360;
    account.initialTerm = new LexSLMV1alpha2LoanManagementTypes.LoanTermDetails();
    account.subsequentTerm = new LexSLMV1alpha2LoanManagementTypes.LoanTermDetails();
    account.originatedDate = '2020-01-01';
    Assert.areEqual(
      'loan-acc-001',
      account.name,
      'loanAccount.name should match "loan-acc-001"'
    );
    Assert.areEqual(
      'real-acc-123',
      account.account,
      'loanAccount.account should match "real-acc-123"'
    );
    Assert.areEqual(
      'Owner Occupied',
      account.productType,
      'loanAccount.productType should match "Owner Occupied"'
    );
    Assert.areEqual(
      360,
      account.termMonths,
      'loanAccount.termMonths should be 360'
    );
    Assert.areEqual(
      '2020-01-01',
      account.originatedDate,
      'loanAccount.originatedDate should match "2020-01-01"'
    );
  }
  @isTest
  static void testLoanAccountChange() {
    LexSLMV1alpha2LoanManagementTypes.LoanAccountChange change = new LexSLMV1alpha2LoanManagementTypes.LoanAccountChange();
    change.name = 'change-123';
    change.request = new LexSLMV1alpha2LoanManagementTypes.LoanAccount();
    change.request.name = 'loan-acc-001';
    change.state = 'IN_PROGRESS';
    change.estimatedProcessingStartTime = '2023-11-01T09:00:00Z';
    change.done = false;
    change.response = new LexSLMV1alpha2LoanManagementTypes.LoanAccount();
    change.response.name = 'loan-acc-002';
    change.documents = new List<LexSLMV1alpha2LoanManagementTypes.LoanDocument>();
    change.createdBy = 'user-123';
    change.createTime = '2023-10-10T10:00:00Z';
    change.docUploadRequired = true;
    change.approval = new LexSLMV1alpha2LoanManagementTypes.Approval();
    change.preview = new LexSLMV1alpha2LoanManagementTypes.LoanAccountPreview();
    Assert.areEqual(
      'change-123',
      change.name,
      'loanAccountChange.name should match "change-123"'
    );
    Assert.areEqual(
      'loan-acc-001',
      change.request.name,
      'loanAccountChange.request.name should match "loan-acc-001"'
    );
    Assert.areEqual(
      'IN_PROGRESS',
      change.state,
      'loanAccountChange.state should match "IN_PROGRESS"'
    );
    Assert.areEqual(
      '2023-11-01T09:00:00Z',
      change.estimatedProcessingStartTime,
      'loanAccountChange.estimatedProcessingStartTime should match "2023-11-01T09:00:00Z"'
    );
    Assert.areEqual(
      false,
      change.done,
      'loanAccountChange.done should be false'
    );
    Assert.areEqual(
      'loan-acc-002',
      change.response.name,
      'loanAccountChange.response.name should match "loan-acc-002"'
    );
    Assert.areEqual(
      'user-123',
      change.createdBy,
      'loanAccountChange.createdBy should match "user-123"'
    );
    Assert.areEqual(
      '2023-10-10T10:00:00Z',
      change.createTime,
      'loanAccountChange.createTime should match "2023-10-10T10:00:00Z"'
    );
    Assert.areEqual(
      true,
      change.docUploadRequired,
      'loanAccountChange.docUploadRequired should be true'
    );
  }
  @isTest
  static void testLoanAccountPreview() {
    LexSLMV1alpha2LoanManagementTypes.LoanAccountPreview preview = new LexSLMV1alpha2LoanManagementTypes.LoanAccountPreview();
    preview.name = 'accounts/1234567/previews/uuid-1234';
    preview.preview = new LexSLMV1alpha2LoanManagementTypes.LoanAccount();
    preview.createTime = '2023-10-10T10:10:10Z';
    preview.previewId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
    Assert.areEqual(
      'accounts/1234567/previews/uuid-1234',
      preview.name,
      'loanAccountPreview.name should match "accounts/1234567/previews/uuid-1234"'
    );
    Assert.areNotEqual(null, preview.preview, 'preview should not be null');
    Assert.areEqual(
      '2023-10-10T10:10:10Z',
      preview.createTime,
      'loanAccountPreview.createTime should match "2023-10-10T10:10:10Z"'
    );
    Assert.areEqual(
      'f47ac10b-58cc-4372-a567-0e02b2c3d479',
      preview.previewId,
      'loanAccountPreview.previewId should match "f47ac10b-58cc-4372-a567-0e02b2c3d479"'
    );
  }
  @isTest
  static void testLoanApplication() {
    LexSLMV1alpha2LoanManagementTypes.LoanApplication application = new LexSLMV1alpha2LoanManagementTypes.LoanApplication();
    application.loanApplicationId = 'app-12345';
    application.parties = new List<LexSLMV1alpha2LoanManagementTypes.Party>{
      new LexSLMV1alpha2LoanManagementTypes.Party()
    };
    application.loanApprovalTime = '2023-10-01T12:00:00Z';
    application.loanOfferGeneratedTime = '2023-10-02T12:00:00Z';
    application.loanAcceptanceTime = '2023-10-03T12:00:00Z';
    application.fees = new List<LexSLMV1alpha2LoanManagementTypes.Fee>{
      new LexSLMV1alpha2LoanManagementTypes.Fee()
    };
    application.feeRedirectAccount = '123-456-789';
    application.payoffAccounts = new List<LexSLMV1alpha2LoanManagementTypes.PayoffAccount>{
      new LexSLMV1alpha2LoanManagementTypes.PayoffAccount()
    };
    application.loanPurposeCode = 'REFI';
    Assert.areEqual(
      'app-12345',
      application.loanApplicationId,
      'loanApplication.loanApplicationId should match "app-12345"'
    );
    Assert.areEqual(
      1,
      application.parties.size(),
      'loanApplication.parties.size should be 1'
    );
    Assert.areEqual(
      '2023-10-01T12:00:00Z',
      application.loanApprovalTime,
      'loanApplication.loanApprovalTime should match "2023-10-01T12:00:00Z"'
    );
    Assert.areEqual(
      '2023-10-02T12:00:00Z',
      application.loanOfferGeneratedTime,
      'loanApplication.loanOfferGeneratedTime should match "2023-10-02T12:00:00Z"'
    );
    Assert.areEqual(
      '2023-10-03T12:00:00Z',
      application.loanAcceptanceTime,
      'loanApplication.loanAcceptanceTime should match "2023-10-03T12:00:00Z"'
    );
    Assert.areEqual(
      1,
      application.fees.size(),
      'loanApplication.fees.size should be 1'
    );
    Assert.areEqual(
      '123-456-789',
      application.feeRedirectAccount,
      'loanApplication.feeRedirectAccount should match "123-456-789"'
    );
    Assert.areEqual(
      1,
      application.payoffAccounts.size(),
      'loanApplication.payoffAccounts.size should be 1'
    );
    Assert.areEqual(
      'REFI',
      application.loanPurposeCode,
      'loanApplication.loanPurposeCode should match "REFI"'
    );
  }

  @isTest
  static void testLoanDocument() {
    LexSLMV1alpha2LoanManagementTypes.LoanDocument document = new LexSLMV1alpha2LoanManagementTypes.LoanDocument();
    document.name = 'accounts/123456789/documents/65d69e92';
    document.uid = '65d69e92-785f-4250-a590-8fd659de04df';
    document.loanAccount = 'loan-acc-123';
    document.loanAccountNumber = '123456789';
    document.state = 'UPLOADED';
    document.file = new LexSLMV1alpha2LoanManagementTypes.File();
    document.loanApplicationId = 'app-98765';
    document.loanAccountChangeId = 'change-111';
    Assert.areEqual(
      'accounts/123456789/documents/65d69e92',
      document.name,
      'loanDocument.name should match "accounts/123456789/documents/65d69e92"'
    );
    Assert.areEqual(
      '65d69e92-785f-4250-a590-8fd659de04df',
      document.uid,
      'loanDocument.uid should match "65d69e92-785f-4250-a590-8fd659de04df"'
    );
    Assert.areEqual(
      'loan-acc-123',
      document.loanAccount,
      'loanDocument.loanAccount should match "loan-acc-123"'
    );
    Assert.areEqual(
      '123456789',
      document.loanAccountNumber,
      'loanDocument.loanAccountNumber should match "123456789"'
    );
    Assert.areEqual(
      'UPLOADED',
      document.state,
      'loanDocument.state should match "UPLOADED"'
    );
    Assert.areEqual(
      'app-98765',
      document.loanApplicationId,
      'loanDocument.loanApplicationId should match "app-98765"'
    );
    Assert.areEqual(
      'change-111',
      document.loanAccountChangeId,
      'loanDocument.loanAccountChangeId should match "change-111"'
    );
  }
  @isTest
  static void testLoanEquity() {
    LexSLMV1alpha2LoanManagementTypes.LoanEquity equity = new LexSLMV1alpha2LoanManagementTypes.LoanEquity();
    equity.name = 'loan-equity-123';
    equity.collaterals = new List<LexSLMV1alpha2LoanManagementTypes.Collateral>{
      new LexSLMV1alpha2LoanManagementTypes.Collateral()
    };
    equity.createTime = '2023-09-01T10:00:00Z';
    Assert.areEqual(
      'loan-equity-123',
      equity.name,
      'loanEquity.name should match "loan-equity-123"'
    );
    Assert.areEqual(
      1,
      equity.collaterals.size(),
      'loanEquity.collaterals.size should be 1'
    );
    Assert.areEqual(
      '2023-09-01T10:00:00Z',
      equity.createTime,
      'loanEquity.createTime should match "2023-09-01T10:00:00Z"'
    );
  }

  @IsTest
  static void testLoanFacility() {
    // Create a mock Account object
    LexSLMV1alpha2LoanManagementTypes.Account mockAccount = new LexSLMV1alpha2LoanManagementTypes.Account();
    mockAccount.apxrsvdNumber = 'Test Account';
    mockAccount.bsb = '123456789';
    // Create mock LoanTermDetails object
    LexSLMV1alpha2LoanManagementTypes.LoanTermDetails initialTerm = new LexSLMV1alpha2LoanManagementTypes.LoanTermDetails();
    initialTerm.loanTermMonths = 5;
    initialTerm.indexInterestRate = 5;
    LexSLMV1alpha2LoanManagementTypes.LoanTermDetails subsequentTerm = new LexSLMV1alpha2LoanManagementTypes.LoanTermDetails();
    initialTerm.loanTermMonths = 5;
    initialTerm.indexInterestRate = 5;
    // Create mock ProductPackage object
    LexSLMV1alpha2LoanManagementTypes.ProductPackage mockProduct = new LexSLMV1alpha2LoanManagementTypes.ProductPackage();
    mockProduct.packageId = 'Home Loan Package';
    mockProduct.packageCode = 'PKG123';
    // Create mock Referrer object
    LexSLMV1alpha2LoanManagementTypes.Referrer mockReferrer = new LexSLMV1alpha2LoanManagementTypes.Referrer();
    mockReferrer.ao = 'REF123';
    mockReferrer.sao = 'John Broker';
    // Create LoanFacility instance
    LexSLMV1alpha2LoanManagementTypes.LoanFacility facility = new LexSLMV1alpha2LoanManagementTypes.LoanFacility();
    facility.id = 'LF123';
    facility.loanAccount = mockAccount;
    facility.initialLoanTermDetails = initialTerm;
    facility.subsequentLoanTermDetails = subsequentTerm;
    facility.productPackage = mockProduct;
    facility.interestChargeFrequency = 'MONTHLY';
    facility.interestChargeMethod = 'IN_ARREARS';
    facility.referrer = mockReferrer;
    Assert.areEqual(
      'LF123',
      facility.id,
      'loanFacility.id should match "LF123"'
    );
    Assert.areEqual(
      'Test Account',
      facility.loanAccount.apxrsvdNumber,
      'loanFacility.loanAccount.apxrsvdNumber should match "Test Account"'
    );
    Assert.areEqual(
      'Home Loan Package',
      facility.productPackage.packageId,
      'loanFacility.productPackage.packageId should match "Home Loan Package"'
    );
    Assert.areEqual(
      'MONTHLY',
      facility.interestChargeFrequency,
      'loanFacility.interestChargeFrequency should match "MONTHLY"'
    );
    Assert.areEqual(
      'IN_ARREARS',
      facility.interestChargeMethod,
      'loanFacility.interestChargeMethod should match "IN_ARREARS"'
    );
    Assert.areEqual(
      'REF123',
      facility.referrer.ao,
      'loanFacility.referrer.ao should match "REF123"'
    );
  }

  @IsTest
  static void testLoanOffset() {
    // Create LoanOffset instance
    LexSLMV1alpha2LoanManagementTypes.LoanOffset loanOffset = new LexSLMV1alpha2LoanManagementTypes.LoanOffset();
    loanOffset.name = 'accounts/123456789/loanoffset';
    loanOffset.loanAccount = 'accounts/123456789';
    loanOffset.offsetAccounts = new List<String>{ 'accounts/987654321' };
    loanOffset.hasPendingChange = true;
    loanOffset.subscriptionId = 'SUB123';
    loanOffset.changesRemaining = 3;
    loanOffset.startDate = '2024-01-01';
    loanOffset.endDate = '2025-01-01';
    Assert.areEqual(
      'accounts/123456789/loanoffset',
      loanOffset.name,
      'loanOffset.name should match "accounts/123456789/loanoffset"'
    );
    Assert.areEqual(
      'accounts/123456789',
      loanOffset.loanAccount,
      'loanOffset.loanAccount should match "accounts/123456789"'
    );
    Assert.areEqual(
      true,
      loanOffset.hasPendingChange,
      'loanOffset.hasPendingChange should be true'
    );
    Assert.areEqual(
      'SUB123',
      loanOffset.subscriptionId,
      'loanOffset.subscriptionId should match "SUB123"'
    );
    Assert.areEqual(
      3,
      loanOffset.changesRemaining,
      'loanOffset.changesRemaining should be 3'
    );
    Assert.areEqual(
      '2024-01-01',
      loanOffset.startDate,
      'loanOffset.startDate should match "2024-01-01"'
    );
    Assert.areEqual(
      '2025-01-01',
      loanOffset.endDate,
      'loanOffset.endDate should match "2025-01-01"'
    );
  }

  @IsTest
  static void testLoanOffsetChange() {
    // Create LoanOffset mock
    LexSLMV1alpha2LoanManagementTypes.LoanOffset loanOffsetResponse = new LexSLMV1alpha2LoanManagementTypes.LoanOffset();
    loanOffsetResponse.name = 'accounts/123456789/loanoffset';
    loanOffsetResponse.loanAccount = 'accounts/123456789';
    // Create LoanOffsetChange instance
    LexSLMV1alpha2LoanManagementTypes.LoanOffsetChange offsetChange = new LexSLMV1alpha2LoanManagementTypes.LoanOffsetChange();
    offsetChange.name = 'accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa';
    offsetChange.request = loanOffsetResponse;
    offsetChange.operationState = 'IN_PROGRESS';
    offsetChange.estimatedProcessingStartTime = '2024-01-10T10:00:00Z';
    offsetChange.done = false;
    offsetChange.response = loanOffsetResponse;
    offsetChange.operationType = 'OFFSET_CHANGE_OPERATION_TYPE_CREATE';
    Assert.areEqual(
      'accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa',
      offsetChange.name,
      'loanOffsetChange.name should match "accounts/123456789/loanoffsetchanges/a29434f7-7c77-42aa"'
    );
    Assert.areEqual(
      'accounts/123456789/loanoffset',
      offsetChange.request.name,
      'loanOffsetChange.request.name should match "accounts/123456789/loanoffset"'
    );
    Assert.areEqual(
      'IN_PROGRESS',
      offsetChange.operationState,
      'loanOffsetChange.operationState should match "IN_PROGRESS"'
    );
    Assert.areEqual(
      false,
      offsetChange.done,
      'loanOffsetChange.done should be false'
    );
    Assert.areEqual(
      'OFFSET_CHANGE_OPERATION_TYPE_CREATE',
      offsetChange.operationType,
      'loanOffsetChange.operationType should match "OFFSET_CHANGE_OPERATION_TYPE_CREATE"'
    );
  }

  @isTest
  static void testLoanProperty() {
    LexSLMV1alpha2LoanManagementTypes.LoanProperty obj = new LexSLMV1alpha2LoanManagementTypes.LoanProperty();
    obj.property = 'Property123';
    obj.propertyUsage = 'PROPERTY_USAGE_OWNER_OCCUPIED';
    obj.collateralAssessment = 'Collateral123';
    obj.state = 'ACTIVE';
    LexSLMV1alpha2LoanManagementTypes.MortgageContract mortgageContract = new LexSLMV1alpha2LoanManagementTypes.MortgageContract();
    mortgageContract.contractId = 'Contract123';
    mortgageContract.dealingNumber = new List<String>{ 'Deal1', 'Deal2' };
    mortgageContract.mortgageStartDate = '2025-01-01';
    mortgageContract.state = 'STATE_HELD';
    LexSLMV1alpha2LoanManagementTypes.SecurityDocument securityDoc = new LexSLMV1alpha2LoanManagementTypes.SecurityDocument();
    securityDoc.documentId = 'Doc123';
    securityDoc.cfaasDocumentId = 'MORTGAGE_DOC';
    mortgageContract.mortgageDocument = securityDoc;
    obj.mortgageContract = mortgageContract;
    Assert.areEqual(
      'Property123',
      obj.property,
      'loanProperty.property should match "Property123"'
    );
    Assert.areEqual(
      'STATE_HELD',
      obj.mortgageContract.state,
      'loanProperty.mortgageContract.state should match "STATE_HELD"'
    );
  }

  @isTest
  static void testLoanScenario() {
    LexSLMV1alpha2LoanManagementTypes.LoanScenario obj = new LexSLMV1alpha2LoanManagementTypes.LoanScenario();
    obj.loanEndDate = '2035-12-31';
    Assert.areEqual(
      '2035-12-31',
      obj.loanEndDate,
      'loanScenario.loanEndDate should match "2035-12-31"'
    );
  }
  @isTest
  static void testLoanTermDetails() {
    LexSLMV1alpha2LoanManagementTypes.LoanTermDetails obj = new LexSLMV1alpha2LoanManagementTypes.LoanTermDetails();
    obj.loanTermMonths = 360;
    obj.indexInterestRate = 5;
    obj.margin = 2;
    obj.offeredInterestRate = 6;
    LexSLMV1alpha2LoanManagementTypes.Repayments repayments = new LexSLMV1alpha2LoanManagementTypes.Repayments();
    repayments.repaymentFrequency = 'MONTHLY';
    obj.repayments = repayments;
    Assert.areEqual(
      360,
      obj.loanTermMonths,
      'loanTermDetails.loanTermMonths should be 360'
    );
    Assert.areEqual(
      'MONTHLY',
      obj.repayments.repaymentFrequency,
      'loanTermDetails.repayments.repaymentFrequency should match "MONTHLY"'
    );
  }
  @isTest
  static void testMortgageContract() {
    LexSLMV1alpha2LoanManagementTypes.MortgageContract obj = new LexSLMV1alpha2LoanManagementTypes.MortgageContract();
    obj.contractId = 'MC123';
    obj.dealingNumber = new List<String>{ 'D1', 'D2' };
    obj.mortgageStartDate = '2025-01-01';
    obj.state = 'STATE_ACTIVE';
    LexSLMV1alpha2LoanManagementTypes.SecurityDocument doc = new LexSLMV1alpha2LoanManagementTypes.SecurityDocument();
    doc.documentId = 'DOC1';
    obj.mortgageDocument = doc;
    Assert.areEqual(
      'MC123',
      obj.contractId,
      'mortgageContract.contractId should match "MC123"'
    );
  }
  @isTest
  static void testParty() {
    LexSLMV1alpha2LoanManagementTypes.Party obj = new LexSLMV1alpha2LoanManagementTypes.Party();
    obj.id = 'Party123';
    obj.type = 'APPLICANT';
    Assert.areEqual(
      'APPLICANT',
      obj.type,
      'party.type should match "APPLICANT"'
    );
  }
  @isTest
  static void testPayoffAccount() {
    LexSLMV1alpha2LoanManagementTypes.PayoffAccount obj = new LexSLMV1alpha2LoanManagementTypes.PayoffAccount();
    obj.type = 'OFI';
    obj.source = 'EXTERNAL';
    LexSLMV1alpha2LoanManagementTypes.Account acc = new LexSLMV1alpha2LoanManagementTypes.Account();
    acc.apxrsvdNumber = 'Acc123';
    acc.bsb = '12345';
    obj.account = acc;
    Assert.areEqual('OFI', obj.type, 'payoffAccount.type should match "OFI"');
  }
  @IsTest
  static void testProductPackage() {
    LexSLMV1alpha2LoanManagementTypes.ProductPackage pkg = new LexSLMV1alpha2LoanManagementTypes.ProductPackage();
    pkg.packageId = 'PKG001';
    pkg.marketingCode = 'MKT123';
    pkg.packageCode = 'HLVPKG01';
    pkg.productType = 'Home Loan';
    Assert.areEqual(
      'PKG001',
      pkg.packageId,
      'productPackage.packageId should match "PKG001"'
    );
    Assert.areEqual(
      'MKT123',
      pkg.marketingCode,
      'productPackage.marketingCode should match "MKT123"'
    );
    Assert.areEqual(
      'HLVPKG01',
      pkg.packageCode,
      'productPackage.packageCode should match "HLVPKG01"'
    );
    Assert.areEqual(
      'Home Loan',
      pkg.productType,
      'productPackage.productType should match "Home Loan"'
    );
  }

  @IsTest
  static void testReferrer() {
    LexSLMV1alpha2LoanManagementTypes.Referrer ref = new LexSLMV1alpha2LoanManagementTypes.Referrer();
    ref.ao = 'AO123';
    ref.sao = 'SAO456';
    Assert.areEqual('AO123', ref.ao, 'referrer.ao should match "AO123"');
    Assert.areEqual('SAO456', ref.sao, 'referrer.sao should match "SAO456"');
  }
  @IsTest
  static void testRegisteredCollateral() {
    LexSLMV1alpha2LoanManagementTypes.RegisteredCollateral regCol = new LexSLMV1alpha2LoanManagementTypes.RegisteredCollateral();
    regCol.registrationId = 'REG001';
    regCol.settlement = 'SETT001';
    regCol.loanApplication = 'LOANAPP001';
    regCol.partyIds = new List<String>{ 'PARTY001', 'PARTY002' };
    LexSLMV1alpha2LoanManagementTypes.Exposure exp = new LexSLMV1alpha2LoanManagementTypes.Exposure();
    exp.loanAccount = 'ACC123';
    regCol.exposures = new List<LexSLMV1alpha2LoanManagementTypes.Exposure>{
      exp
    };
    LexSLMV1alpha2LoanManagementTypes.LoanProperty prop = new LexSLMV1alpha2LoanManagementTypes.LoanProperty();
    prop.property = 'PROP001';
    regCol.properties = new List<LexSLMV1alpha2LoanManagementTypes.LoanProperty>{
      prop
    };
    LexSLMV1alpha2LoanManagementTypes.SecurityDocument offer = new LexSLMV1alpha2LoanManagementTypes.SecurityDocument();
    offer.documentId = 'DOC001';
    regCol.letterOfOffer = offer;
    regCol.state = 'STATE_APPROVED';
    regCol.error = new LexSLMV1alpha2LoanManagementTypes.Error();
    regCol.parties = new List<LexSLMV1alpha2LoanManagementTypes.Party>{
      new LexSLMV1alpha2LoanManagementTypes.Party()
    };
    LexSLMV1alpha2LoanManagementTypes.SecurityDocument contract = new LexSLMV1alpha2LoanManagementTypes.SecurityDocument();
    contract.documentId = 'CONTRACT001';
    regCol.contractOfSale = contract;
    Assert.areEqual(
      'REG001',
      regCol.registrationId,
      'registeredCollateral.registrationId should match "REG001"'
    );
    Assert.areEqual(
      'SETT001',
      regCol.settlement,
      'registeredCollateral.settlement should match "SETT001"'
    );
    Assert.areEqual(
      'LOANAPP001',
      regCol.loanApplication,
      'registeredCollateral.loanApplication should match "LOANAPP001"'
    );
    Assert.areEqual(
      'STATE_APPROVED',
      regCol.state,
      'registeredCollateral.state should match "STATE_APPROVED"'
    );
    Assert.areEqual(
      'ACC123',
      regCol.exposures[0].loanAccount,
      'registeredCollateral.exposures[0].loanAccount should match "ACC123"'
    );
    Assert.areEqual(
      'PROP001',
      regCol.properties[0].property,
      'registeredCollateral.properties[0].property should match "PROP001"'
    );
    Assert.areEqual(
      'DOC001',
      regCol.letterOfOffer.documentId,
      'registeredCollateral.letterOfOffer.documentId should match "DOC001"'
    );
    Assert.areEqual(
      'CONTRACT001',
      regCol.contractOfSale.documentId,
      'registeredCollateral.contractOfSale.documentId should match "CONTRACT001"'
    );
  }

  @IsTest
  static void testRepaymentScenario() {
    LexSLMV1alpha2LoanManagementTypes.RepaymentScenario scenario = new LexSLMV1alpha2LoanManagementTypes.RepaymentScenario();
    scenario.accountNumber = 'ACC987';
    scenario.estimatedReducedTermMonths = 12;
    LexSLMV1alpha2LoanManagementTypes.LoanScenario baseline = new LexSLMV1alpha2LoanManagementTypes.LoanScenario();
    scenario.baseline = baseline;
    LexSLMV1alpha2LoanManagementTypes.LoanScenario scen = new LexSLMV1alpha2LoanManagementTypes.LoanScenario();
    scenario.scenario = scen;
    Assert.areEqual(
      'ACC987',
      scenario.accountNumber,
      'repaymentScenario.accountNumber should match "ACC987"'
    );
    Assert.areEqual(
      12,
      scenario.estimatedReducedTermMonths,
      'repaymentScenario.estimatedReducedTermMonths should be 12'
    );
    Assert.areNotEqual(
      null,
      scenario.baseline,
      'scenario.baseline should not be null'
    );
    Assert.areNotEqual(
      null,
      scenario.scenario,
      'scenario.scenario should not be null'
    );
  }
  @IsTest
  static void testRepaymentSummary() {
    LexSLMV1alpha2LoanManagementTypes.RepaymentSummary summary = new LexSLMV1alpha2LoanManagementTypes.RepaymentSummary();
    summary.firstInterestDueDate = '2025-09-01';
    summary.firstPrincipalDueDate = '2025-10-01';
    Assert.areEqual(
      '2025-09-01',
      summary.firstInterestDueDate,
      'repaymentSummary.firstInterestDueDate should match "2025-09-01"'
    );
    Assert.areEqual(
      '2025-10-01',
      summary.firstPrincipalDueDate,
      'repaymentSummary.firstPrincipalDueDate should match "2025-10-01"'
    );
  }
  @isTest
  static void testRepayments() {
    LexSLMV1alpha2LoanManagementTypes.Repayments repayments = new LexSLMV1alpha2LoanManagementTypes.Repayments();
    repayments.id = 'repaymentId';
    repayments.type = 'REPAYMENT_TYPE_INTEREST_ONLY';
    repayments.repaymentFrequency = 'REPAYMENT_FREQUENCY_MONTHLY';
    repayments.fromAccount = 'fromAccount123';
    repayments.numberOfRepayments = 36;
    Assert.areEqual(
      'repaymentId',
      repayments.id,
      'repayments.id should match "repaymentId"'
    );
    Assert.areEqual(
      'REPAYMENT_TYPE_INTEREST_ONLY',
      repayments.type,
      'repayments.type should match "REPAYMENT_TYPE_INTEREST_ONLY"'
    );
    Assert.areEqual(
      'REPAYMENT_FREQUENCY_MONTHLY',
      repayments.repaymentFrequency,
      'repayments.repaymentFrequency should match "REPAYMENT_FREQUENCY_MONTHLY"'
    );
    Assert.areEqual(
      36,
      repayments.numberOfRepayments,
      'repayments.numberOfRepayments should be 36'
    );
  }
  @isTest
  static void testRestructureLoanApplication() {
    LexSLMV1alpha2LoanManagementTypes.RestructureLoanApplication restructure = new LexSLMV1alpha2LoanManagementTypes.RestructureLoanApplication();
    restructure.loanAccount = new List<LexSLMV1alpha2LoanManagementTypes.LoanAccount>();
    LexSLMV1alpha2LoanManagementTypes.LoanAccount loanAcc = new LexSLMV1alpha2LoanManagementTypes.LoanAccount();
    loanAcc.name = 'ACC123';
    restructure.loanAccount.add(loanAcc);
    restructure.loanApplication = 'LoanApp123';
    restructure.preview = new LexSLMV1alpha2LoanManagementTypes.LoanAccountPreview();
    restructure.preview.name = 'PREVIEW_ACC';
    Assert.areEqual(
      'LoanApp123',
      restructure.loanApplication,
      'restructureLoanApplication.loanApplication should match "LoanApp123"'
    );
    Assert.areEqual(
      1,
      restructure.loanAccount.size(),
      'restructureLoanApplication.loanAccount.size should be 1'
    );
    Assert.areEqual(
      'ACC123',
      restructure.loanAccount[0].name,
      'restructureLoanApplication.loanAccount[0].name should match "ACC123"'
    );
    Assert.areEqual(
      'PREVIEW_ACC',
      restructure.preview.name,
      'restructureLoanApplication.preview.name should match "PREVIEW_ACC"'
    );
  }
  @isTest
  static void testSecurityDocument() {
    LexSLMV1alpha2LoanManagementTypes.SecurityDocument secDoc = new LexSLMV1alpha2LoanManagementTypes.SecurityDocument();
    secDoc.documentId = 'DOC123';
    secDoc.cfaasDocumentId = 'CFAAS456';
    secDoc.cfaasDocumentVersion = 2L;
    secDoc.acceptanceTime = '2025-08-18T12:00:00Z';
    Assert.areEqual(
      'DOC123',
      secDoc.documentId,
      'securityDocument.documentId should match "DOC123"'
    );
    Assert.areEqual(
      'CFAAS456',
      secDoc.cfaasDocumentId,
      'securityDocument.cfaasDocumentId should match "CFAAS456"'
    );
    Assert.areEqual(
      2L,
      secDoc.cfaasDocumentVersion,
      'securityDocument.cfaasDocumentVersion should be 2L'
    );
    Assert.areEqual(
      '2025-08-18T12:00:00Z',
      secDoc.acceptanceTime,
      'securityDocument.acceptanceTime should match "2025-08-18T12:00:00Z"'
    );
  }
  @isTest
  static void testValidRepaymentPreferences() {
    LexSLMV1alpha2LoanManagementTypes.ValidRepaymentPreferences validPrefs = new LexSLMV1alpha2LoanManagementTypes.ValidRepaymentPreferences();
    validPrefs.accountNumber = 'ACC987';
    validPrefs.operations = new List<String>{
      'OPERATION_TYPE_REPAYMENT_ACCOUNT_UPDATE',
      'OPERATION_TYPE_REPAYMENT_AMOUNT_UPDATE'
    };
    Assert.areEqual(
      'ACC987',
      validPrefs.accountNumber,
      'validRepaymentPreferences.accountNumber should match "ACC987"'
    );
    Assert.areEqual(
      2,
      validPrefs.operations.size(),
      'validRepaymentPreferences.operations.size should be 2'
    );
    Assert.areEqual(
      'OPERATION_TYPE_REPAYMENT_ACCOUNT_UPDATE',
      validPrefs.operations[0],
      'validRepaymentPreferences.operations[0] should match "OPERATION_TYPE_REPAYMENT_ACCOUNT_UPDATE"'
    );
  }
  @isTest
  static void testError() {
    LexSLMV1alpha2LoanManagementTypes.Error errorObj = new LexSLMV1alpha2LoanManagementTypes.Error();
    errorObj.code = '400';
    errorObj.message = 'Invalid Request';
    errorObj.details = new List<String>{ 'Missing field', 'Invalid format' };
    Assert.areEqual('400', errorObj.code, 'error.code should match "400"');
    Assert.areEqual(
      'Invalid Request',
      errorObj.message,
      'error.message should match "Invalid Request"'
    );
    Assert.areEqual(
      2,
      errorObj.details.size(),
      'error.details.size should be 2'
    );
    Assert.areEqual(
      'Missing field',
      errorObj.details[0],
      'error.details[0] should match "Missing field"'
    );
  }
}
