/**
 * @description controller class for cobPidViewAndEdit lwc
 * @author Victor Wang
 * @since 01/2023
 */
public with sharing class COBPIDViewAndEditController {
  private static final COBPIDViewAndEditRepository COB_PID_VIEW_EDIT_REPOSITORY = (COBPIDViewAndEditRepository) Lib_InstanceProvider.forType(
    COBPIDViewAndEditRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final StravinskyAPIRepository STRAVINSKY_API_REPOSITORY = (StravinskyAPIRepository) Lib_InstanceProvider.forType(
    StravinskyAPIRepository.class
  );

  private static final String PASSPORT_TYPE = 'Passport';
  private static final String LICENCE_TYPE = 'Licence';
  private static final String NO_PERSONA_ID = 'Error in detokenizing COB Primary ID Document - No PersonaId';
  private static final String MISSING_PERSONA_ID = 'No Persona Id found. Please ensure a Persona Id has been added to the COB Primary ID Document record. Raise a fault through TechAssist if the problem persists.';
  private static final String FAILED_DETOKENIZATION = 'Failed to perform detokenization. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String FAILED_UPDATE = 'Failed to save tokenized details. Please raise a fault through TechAssist if the problem persists.';
  private static final String FAILED_TOKENIZATION = 'Failed to update details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';
  private static final String ERROR_TOKENIZING_DATA = 'Error tokenizeing COB Primary ID Document data';
  private static final String ERROR_DETOKENIZING_DATA = 'Error detokenizing COB Primary ID Document data';

  @TestVisible
  private static final Set<SObjectField> LICENCE_TOKENIZED_FIELDS = new Set<SObjectField>{
    COBPrimaryIDDocument__c.LicenceNumber__c,
    COBPrimaryIDDocument__c.LicenceNumberOCRClient__c,
    COBPrimaryIDDocument__c.LicenceNumberOCRServer__c,
    COBPrimaryIDDocument__c.LicenceCardNumber__c,
    COBPrimaryIDDocument__c.LicenceCardNumberOCRClient__c,
    COBPrimaryIDDocument__c.LicenceCardNumberOCRServer__c
  };

  @TestVisible
  private static final Set<SObjectField> PASSPORT_TOKENIZED_FIELDS = new Set<SObjectField>{
    COBPrimaryIDDocument__c.PassportNumber__c,
    COBPrimaryIDDocument__c.PassportNumberOCRClient__c,
    COBPrimaryIDDocument__c.PassportNumberOCRServer__c
  };

  /**
   * @description method to retrieve detokenized Customer Onboarding Application data and return to lwc component
   * @param recordId Salesforce ID of the COBPrimaryIDDocument__c record from the lwc component
   * @return `COBPrimaryIDDocument__c` detokenized data structured with COBPrimaryIDDocument__c object
   */
  @AuraEnabled
  public static COBPrimaryIDDocument__c detokenizeCOBPIDData(string recordId) {
    COBPrimaryIDDocument__c cobPid = getCobPidDocument(recordId);

    Set<SObjectField> fields = getTokenizedFields(cobPid.IdDocumentType__c);

    Set<String> fieldValues = getTokenizedFieldValues(cobPid, fields);

    DetokenizeModel detokenizedValues = detokenizeCobPid(cobPid, fieldValues);

    return setDetokenizedFields(detokenizedValues, cobPid, fields);
  }

  /**
   * @description method to retrieve COB Primary ID Document record from database
   * @param recordId Salesforce ID of the COBPrimaryIDDocument__c record from the lwc component
   * @return `COBPrimaryIDDocument__c` detokenized data structured with COBPrimaryIDDocument__c object
   */
  @TestVisible
  private static COBPrimaryIDDocument__c getCobPidDocument(string recordId) {
    COBPrimaryIDDocument__c cobPid = COB_PID_VIEW_EDIT_REPOSITORY.getCOBPIDByRecordId(
      recordId
    );

    if (String.isBlank(cobPid.PersonaId__c)) {
      Logger.error(NO_PERSONA_ID, recordId);
      Logger.saveLog();
      throw new AuraHandledException(MISSING_PERSONA_ID);
    }
    return cobPid;
  }

  /**
   * @description method to retrieve the defined document's tokenized fields
   * @param idDocumentType the COBPrimaryIDDocument__c documentType
   * @return `Set<SObjectField>` tokenized fields according to COB Primary Document type
   */
  @TestVisible
  private static Set<SObjectField> getTokenizedFields(String idDocumentType) {
    if (isPassport(idDocumentType)) {
      return PASSPORT_TOKENIZED_FIELDS;
    }
    if (isLicense(idDocumentType)) {
      return LICENCE_TOKENIZED_FIELDS;
    }

    return null;
  }

  /**
   * @description method to retrieve the defined document's tokenized fields
   * @param cobPid the COBPrimaryIDDocument__c record
   * @param fields the defined tokenized object fields
   * @return `Set<String>` tokenized field values of COB Primary Document record
   */
  @TestVisible
  private static Set<String> getTokenizedFieldValues(
    COBPrimaryIDDocument__c cobPid,
    Set<SObjectField> fields
  ) {
    Set<String> fieldValues = new Set<String>();

    for (SObjectField fieldName : fields) {
      String fieldValue = (String) cobPid.get(fieldName);
      if (String.isBlank(fieldValue)) {
        continue;
      }
      fieldValues.add(fieldValue);
    }

    return fieldValues;
  }

  /**
   * @description method that detokenizes and parses the COB Document
   * @param cobPid the COB Primary Document record to detokenize
   * @param fieldValues the tokenized field values
   * @return `DetokenizeModel` parsed detokenized response retrieved from Stravinsky
   */
  @TestVisible
  private static DetokenizeModel detokenizeCobPid(
    COBPrimaryIDDocument__c cobPid,
    Set<String> fieldValues
  ) {
    try {
      return STRAVINSKY_API_REPOSITORY.detokenize(
        cobPid.PersonaId__c,
        fieldValues,
        COBPrimaryIDDocumentModel.TOKEN_TRANSFORM_VALUE
      );
    } catch (Exception e) {
      Logger.error(ERROR_DETOKENIZING_DATA, cobPid.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(FAILED_DETOKENIZATION);
    }
  }

  /**
   * @description method to retrieve COB Primary ID Document record from database
   * @param response the parsed COB document with detokenized values
   * @param cobPid the COB Primary Document record
   * @param fields the tokenized fields to map with the detokenized ones
   * @return `COBPrimaryIDDocument__c` the COB document record that will be displayed in LWC
   */
  @TestVisible
  private static COBPrimaryIDDocument__c setDetokenizedFields(
    DetokenizeModel response,
    COBPrimaryIDDocument__c cobPid,
    Set<SObjectField> fields
  ) {
    Map<String, String> detokenizedValuesMap = buildDetokenizedMap(response);

    for (SObjectField field : fields) {
      cobPid.put(field, detokenizedValuesMap.get((String) cobPid.get(field)));
    }

    return cobPid;
  }

  /**
   * @description method to save updated data
   * @param record data passed from lwc and in COBPrimaryIDDocument__c entity format
   */
  @AuraEnabled
  public static void updateCOBPIDData(COBPrimaryIDDocument__c record) {
    if (String.isBlank(record.PersonaId__c)) {
      Logger.error(NO_PERSONA_ID, record);
      Logger.saveLog();
      throw new AuraHandledException(MISSING_PERSONA_ID);
    }

    COBPrimaryIDDocumentModel cobPidData = triggerTemporalPIDWorklow(record);

    COBPrimaryIDDocument__c tokenizedData = buildTokenizedData(
      record,
      cobPidData
    );

    PIDDMLOperator dmlOperator = new PIDDMLOperator();
    dmlOperator.updateTokenizedData(tokenizedData);
  }

  /**
   * @description method to build tokenized data wrapped in COBPrimaryIDDocument__c structure
   * @param record COBPrimaryIDDocument__c record contains the origin copy of detokenized data
   * @param response response from temporal workflow callout
   * @return `COBPrimaryIDDocument__c`
   */
  @TestVisible
  private static COBPrimaryIDDocument__c buildTokenizedData(
    COBPrimaryIDDocument__c record,
    COBPrimaryIDDocumentModel response
  ) {
    if (isPassport(record.IdDocumentType__c)) {
      return getCobPidPassport(record.Id, response.passport);
    } else if (isLicense(record.IdDocumentType__c)) {
      return getCobPidLicense(record.Id, response.australianDriverLicence);
    }

    return null;
  }

  /**
   * @description method to build passport tokenized data wrapped in COBPrimaryIDDocument__c structure
   * @param recordId COBPrimaryIDDocument__c record's Id that contains the origin copy of detokenized data
   * @param passport response's Passport object from temporal workflow callout
   * @return `COBPrimaryIDDocument__c`
   */
  private static COBPrimaryIDDocument__c getCobPidPassport(
    String recordId,
    COBPrimaryIDDocumentModel.Passport passport
  ) {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      Id = recordId,
      FirstName__c = passport.firstName,
      MiddleNames__c = passport.middleNames,
      LastName__c = passport.lastName,
      DateOfBirth__c = Date.newInstance(
        passport.dateOfBirth.year,
        passport.dateOfBirth.month,
        passport.dateOfBirth.day
      ),
      ExpiryDate__c = Date.newInstance(
        passport.expiryDate.year,
        passport.expiryDate.month,
        passport.expiryDate.day
      ),
      CountryOfIssue__c = passport.countryOfIssue
    );
    cobPid.PassportNumber__c = passport.passportNumberToken?.value;

    return cobPid;
  }

  /**
   * @description method to build license tokenized data wrapped in COBPrimaryIDDocument__c structure
   * @param recordId COBPrimaryIDDocument__c record's Id that contains the origin copy of detokenized data
   * @param australianDriverLicence response's AustralianDriverLicence object from temporal workflow callout
   * @return `COBPrimaryIDDocument__c`
   */
  private static COBPrimaryIDDocument__c getCobPidLicense(
    String recordId,
    COBPrimaryIDDocumentModel.AustralianDriverLicence australianDriverLicence
  ) {
    COBPrimaryIDDocument__c cobPid = new COBPrimaryIDDocument__c(
      Id = recordId,
      FirstName__c = australianDriverLicence.firstName,
      MiddleNames__c = australianDriverLicence.middleNames,
      LastName__c = australianDriverLicence.lastName,
      DateOfBirth__c = Date.newInstance(
        australianDriverLicence.dateOfBirth.year,
        australianDriverLicence.dateOfBirth.month,
        australianDriverLicence.dateOfBirth.day
      ),
      ExpiryDate__c = Date.newInstance(
        australianDriverLicence.expiryDate.year,
        australianDriverLicence.expiryDate.month,
        australianDriverLicence.expiryDate.day
      ),
      StateOfIssue__c = australianDriverLicence.stateOfIssue
    );
    cobPid.LicenceNumber__c = australianDriverLicence.licenceNumberToken?.value;
    cobPid.LicenceCardNumber__c = australianDriverLicence.licenceCardNumberToken
      ?.value;

    return cobPid;
  }

  /**
   * @description method to trigger temporal workflow to update cobpid
   * @param record COB Primary ID record that will be updated
   * @return `COBPrimaryIDDocumentModel`
   */
  @TestVisible
  private static COBPrimaryIDDocumentModel triggerTemporalPIDWorklow(
    COBPrimaryIDDocument__c record
  ) {
    Case idOpsCase = COB_PID_VIEW_EDIT_REPOSITORY.getIdOpsCase(record);

    try {
      return STRAVINSKY_API_REPOSITORY.updatePrimaryIDDocument(
        record,
        idOpsCase.Id
      );
    } catch (Exception e) {
      Logger.error(ERROR_TOKENIZING_DATA, record.Id, e);
      Logger.saveLog();
      throw new AuraHandledException(FAILED_TOKENIZATION);
    }
  }

  /**
   * @description method to build a map between tokenized string and detokenized value
   * @param detokenizedValues api returned data for detokenized field
   * @return `Map<String, String>` a map between tokenized string and detokenized value
   */
  private static Map<String, String> buildDetokenizedMap(
    DetokenizeModel detokenizedValues
  ) {
    Map<String, String> detokenizedValuesMap = new Map<String, String>();

    for (DetokenizeModel.DetokenizedValue dv : detokenizedValues.values) {
      detokenizedValuesMap.put(dv.Tokenized, dv.Detokenized);
    }

    return detokenizedValuesMap;
  }

  /**
   * @description checks if a Primary ID Document is a passport
   * @param idDocumentType the Primary ID Document's document type
   * @return Boolean - if a Primary ID Document is a passport
   */
  private static Boolean isPassport(String idDocumentType) {
    return idDocumentType == PASSPORT_TYPE;
  }

  /**
   * @description checks if a Primary ID Document is a licence
   * @param idDocumentType the Primary ID Document's document type
   * @return Boolean - if a Primary ID Document is a license
   */
  private static Boolean isLicense(String idDocumentType) {
    return idDocumentType == LICENCE_TYPE;
  }

  /**
   * @description private without sharing class to bypass COBPrimaryIDDocument__c sharing settings
   */
  @TestVisible
  private without sharing class PIDDMLOperator {
    /**
     * @description Update COBPrimaryIDDocument__c record
     * @param tokenizedData Tokenised COBPrimaryIDDocument__c record
     */
    @TestVisible
    private void updateTokenizedData(COBPrimaryIDDocument__c tokenizedData) {
      if (tokenizedData == null) {
        return;
      }
      List<COBPrimaryIDDocument__c> tokenizedDataList = new List<COBPrimaryIDDocument__c>{
        tokenizedData
      };
      List<Database.SaveResult> results = DML_REPOSITORY.updateRecords(
        tokenizedDataList,
        DmlRepository.ALL_OR_NONE,
        DmlRepository.SYSTEM_MODE
      );
      if (results.isEmpty()) {
        throw new AuraHandledException(FAILED_UPDATE);
      }
    }
  }
}
