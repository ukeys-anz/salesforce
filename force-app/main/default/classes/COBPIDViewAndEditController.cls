/**
 * @description controller class for cobPidViewAndEdit lwc
 * @author Victor Wang
 * @since 01/2023
 */
public with sharing class COBPIDViewAndEditController {
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
  private static final List<String> LICENCE_TOKENIZED_FIELDS = new List<String>{
    'LicenceNumber__c',
    'LicenceCardNumber__c'
  };

  @TestVisible
  private static final List<String> PASSPORT_TOKENIZED_FIELDS = new List<String>{
    'PassportNumber__c'
  };

  /**
   * @description method to retrieve detokenized Customer Onboarding Application data and return to lwc component
   * @param recordId Salesforce ID of the COBPrimaryIDDocument__c record from the lwc component
   * @return `COBPrimaryIDDocument__c` detokenized data structured with COBPrimaryIDDocument__c object
   */
  @AuraEnabled
  public static COBPrimaryIDDocument__c detokenizeCOBPIDData(string recordId) {
    if (!PermissionUtils.canQuery('COBPrimaryIDDocument__c')) {
      CommonUtil.logAndThrowIAE(
        'COBPIDViewAndEditController',
        'detokenizeCOBPIDData',
        'Not enough permissions to query required object.'
      );
    }

    COBPrimaryIDDocument__c cobPid = getCOBPID(recordId);

    if (String.isBlank(cobPid.PersonaId__c)) {
      Logger.error(NO_PERSONA_ID, recordId);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(MISSING_PERSONA_ID);
      e.setMessage(MISSING_PERSONA_ID);
      throw e;
    }

    StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
    COBPrimaryIDDocumentModel response;

    List<String> fields = new List<String>();
    if (cobPid.IdDocumentType__c == PASSPORT_TYPE) {
      fields = PASSPORT_TOKENIZED_FIELDS;
    } else if (cobPid.IdDocumentType__c == LICENCE_TYPE) {
      fields = LICENCE_TOKENIZED_FIELDS;
    }

    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedValues = COBPrimaryIDDocumentModel.buildTokenizedValues(
      cobPid,
      fields
    );

    try {
      response = stravinskyApi.cobPidDetokenization(
        cobPid.PersonaId__c,
        tokenizedValues
      );
    } catch (Exception e) {
      Logger.error(ERROR_DETOKENIZING_DATA, cobPid.Id, e);
      Logger.saveLog();
      AuraHandledException ex = new AuraHandledException(FAILED_DETOKENIZATION);
      ex.setMessage(FAILED_DETOKENIZATION);
      throw ex;
    }

    Map<String, String> detokenizedValuesMap = buildDetokenizedMap(
      response.values
    );

    for (String field : fields) {
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
    if (
      !PermissionUtils.canUpdate('COBPrimaryIDDocument__c') ||
      !PermissionUtils.canQuery('Case')
    ) {
      CommonUtil.logAndThrowIAE(
        'COBPIDViewAndEditController',
        'updateCOBPIDData',
        'Not enough permissions to update required object.'
      );
    }

    if (String.isBlank(record.PersonaId__c)) {
      Logger.error(NO_PERSONA_ID, record);
      Logger.saveLog();
      AuraHandledException e = new AuraHandledException(MISSING_PERSONA_ID);
      e.setMessage(MISSING_PERSONA_ID);
      throw e;
    }

    COBPrimaryIDDocumentModel response = triggerTemporalPIDWorklow(record);

    COBPrimaryIDDocument__c tokenizedData = buildTokenizedData(
      record.Id,
      record.IdDocumentType__c,
      response
    );

    updateTokenizedData(tokenizedData);
  }

  /**
   * @description method to build tokenized data wrapped in COBPrimaryIDDocument__c structure
   * @param recordId COBPrimaryIDDocument__c record id for update
   * @param idDocumentType COBPrimaryIDDocument__c document type
   * @param response response from temporal workflow callout
   * @return `COBPrimaryIDDocumentModel`
   */
  private static COBPrimaryIDDocument__c buildTokenizedData(
    String recordId,
    String idDocumentType,
    COBPrimaryIDDocumentModel response
  ) {
    COBPrimaryIDDocument__c tokenizedData = new COBPrimaryIDDocument__c(
      Id = recordId,
      FirstName__c = idDocumentType == PASSPORT_TYPE
        ? response.passport.firstName
        : response.licence.firstName,
      MiddleNames__c = idDocumentType == PASSPORT_TYPE
        ? response.passport.middleNames
        : response.licence.middleNames,
      LastName__c = idDocumentType == PASSPORT_TYPE
        ? response.passport.lastName
        : response.licence.lastName,
      DateOfBirth__c = idDocumentType == PASSPORT_TYPE
        ? Date.newInstance(
            response.passport.dateOfBirth.year,
            response.passport.dateOfBirth.month,
            response.passport.dateOfBirth.day
          )
        : Date.newInstance(
            response.licence.dateOfBirth.year,
            response.licence.dateOfBirth.month,
            response.licence.dateOfBirth.day
          )
    );

    if (idDocumentType == PASSPORT_TYPE) {
      if (String.isNotBlank(response.passport.passportNumberToken?.value)) {
        tokenizedData.PassportNumber__c = response.passport.passportNumberToken.value;
      }
    } else if (idDocumentType == LICENCE_TYPE) {
      if (String.isNotBlank(response.licence.licenceNumberToken?.value)) {
        tokenizedData.LicenceNumber__c = response.licence.licenceNumberToken.value;
      }
      if (String.isNotBlank(response.licence.licenceCardNumberToken?.value)) {
        tokenizedData.LicenceCardNumber__c = response.licence.licenceCardNumberToken.value;
      }
    }

    return tokenizedData;
  }

  /**
   * @description method to trigger temporal workflow to update cobpid
   * @param record data returned from tokenize api
   * @return `COBPrimaryIDDocumentModel`
   */
  private static COBPrimaryIDDocumentModel triggerTemporalPIDWorklow(
    COBPrimaryIDDocument__c record
  ) {
    try {
      StravinskyAPIRepository stravinskyApi = new StravinskyAPIRepository();
      COBPrimaryIDDocumentModel requestBody = COBPrimaryIDDocumentModel.buildUpdateRequestBody(
        record
      );
      return stravinskyApi.cobPidTokenization(record.PersonaId__c, requestBody);
    } catch (Exception e) {
      Logger.error(ERROR_TOKENIZING_DATA, record.Id, e);
      Logger.saveLog();
      AuraHandledException ex = new AuraHandledException(FAILED_TOKENIZATION);
      ex.setMessage(FAILED_TOKENIZATION);
      throw ex;
    }
  }

  /**
   * @description method to save updated data
   * @param tokenizedData data returned from tokenize api
   */
  private static void updateTokenizedData(
    COBPrimaryIDDocument__c tokenizedData
  ) {
    if (PermissionUtils.canUpdate('COBPrimaryIDDocument__c')) {
      Database.SaveResult result = Database.Update(tokenizedData, false);

      if (!result.isSuccess()) {
        Logger.error('Failed to update COBPrimaryIDDocument__c', result);
        Logger.saveLog();

        AuraHandledException ex = new AuraHandledException(FAILED_UPDATE);
        ex.setMessage(FAILED_UPDATE);
        throw ex;
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'COBPIDViewAndEditController',
        'updateCOBPIDData',
        'Not enough permissions to update COBPrimaryIDDocument__c.'
      );
    }
  }

  /**
   * @description method to build a map between tokenized string and detokenized value
   * @param detokenizedValues api returned data for detokenized field
   * @return `Map<String, String>` a map between tokenized string and detokenized value
   */
  private static Map<String, String> buildDetokenizedMap(
    List<COBPrimaryIDDocumentModel.DetokenizedValue> detokenizedValues
  ) {
    Map<String, String> detokenizedValuesMap = new Map<String, String>();

    for (COBPrimaryIDDocumentModel.DetokenizedValue dv : detokenizedValues) {
      detokenizedValuesMap.put(dv.Tokenized, dv.Detokenized);
    }

    return detokenizedValuesMap;
  }

  /**
   * @description method to query a COBPrimaryIDDocument__c record by ID
   * @param recordId Salesforce ID of the COBPrimaryIDDocument__c record from the lwc component
   * @return `COBPrimaryIDDocument__c`
   */
  private static COBPrimaryIDDocument__c getCOBPID(String recordId) {
    return [
      SELECT
        Id,
        PersonaId__c,
        IdDocumentType__c,
        LicenceNumber__c,
        LicenceNumberOCRClient__c,
        LicenceNumberOCRServer__c,
        LicenceCardNumber__c,
        LicenceCardNumberOCRClient__c,
        LicenceCardNumberOCRServer__c,
        PassportNumber__c,
        PassportNumberOCRClient__c,
        PassportNumberOCRServer__c,
        FirstName__c,
        FirstNameOCRClient__c,
        FirstNameOCRServer__c,
        MiddleNames__c,
        MiddleNamesOCRClient__c,
        MiddleNamesOCRServer__c,
        LastName__c,
        LastNameOCRClient__c,
        LastNameOCRServer__c,
        DateOfBirth__c,
        DateOfBirthOCRClient__c,
        DateOfBirthOCRServer__c,
        StateOfIssue__c,
        StateOfIssueOCRClient__c,
        StateOfIssueOCRServer__c,
        CountryOfIssue__c,
        CountryOfIssueOCRClient__c,
        CountryOfIssueOCRServer__c,
        ExpiryDate__c,
        ExpiryDateOCRClient__c,
        ExpiryDateOCRServer__c
      FROM COBPrimaryIDDocument__c
      WHERE ID = :recordId
      LIMIT 1
    ];
  }
}
