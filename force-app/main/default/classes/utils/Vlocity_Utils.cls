/**
 * @author Laxmi
 * @since 04/2023
 * @description  To get the customer information  and account numbers on OCV search
 */
global with sharing class Vlocity_Utils implements Callable {
  /**
   * @param methodName The method passed from Integration procedure
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   * @return true is valid, false otherwise
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public Boolean invokeMethod(
    String methodName,
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    if ('getCustomerInfo'.equals(methodName)) {
      getCustomerInfo(input, output, options);
    } else if ('getKnownIssues'.equals(methodName)) {
      getKnownIssues(input, output, options);
    } else if ('deleteComplaintResolution'.equals(methodName)) {
      (new ComplaintResolutionActions())
        .deleteComplaintResolution(input, output, options);
    } else if ('createComplaintResolution'.equals(methodName)) {
         createComplaintResolution(input, output, options);
    }
        else if ('getLastModifiedDateOfField'.equals(methodName)){
            getLastModifiedDateOfField(input, output, options);
        }
    return true;
  }

  /**
   * @param action beaviour of the method to exhibit
   * @param args arguments to be used by the specified action
   * @return method to be invoked
   * @description To dispatch actual method
   */
  public Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');
    return invokeMethod(action, input, output, options);
  }

  /**
   * @description To get the customer Info
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   */
  public void getCustomerInfo(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    try {
      String custId = String.valueOf(input.get('CustomerId'));
      String custIdentifier = (String) input.get('CustomerIdentifier');
      IDRAPIRepository idr = new IDRAPIRepository();
      IDRCustomerInformationModel result = idr.getCustomerInfo(
        custId,
        custIdentifier
      );
      output.put('Response', JSON.serialize(result));
    } catch (Exception ex) {
      output.put('Exceptions', ex.getMessage());
    }
  }

  /**
   * @description To get Known Issues field values
   * @param input The input from the Integration procedure
   * @param output The output to be passed to Integration procedure
   * @param options The additional parameters required
   */
  public void getKnownIssues(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    List<Known_Issues__c> knownIssuesList = IDRExpressComplaintController.getAllKnownIssues();
    output.put('KnownIssue', knownIssuesList);
  }

  /**
   * @return boolean setting
   * @description to get custom setting value
   */
  @AuraEnabled(cacheable=true)
  public static Boolean getDisableOmni() {
    return IDRConstants.DISABLE_OMNI_FOR_CMOS;
  }

  /**
     * @description To create Complaint Resolution
     * @param input The input from IP CR Ids
     * @param output The output to be passed to Integration procedure
     * @param options The additional parameters required
     */
    public static void createComplaintResolution(
      Map<String, Object> input,
      Map<String, Object> output,
      Map<String, Object> options
    ) {
      List<Complaint_Resolution__c> crtocreate = new List<Complaint_Resolution__c>();
      List<Object> complaintRes = (List<Object>) input.get(
        'ComplaintResolution'
      );
      for (Object c : complaintRes) {
        RemedyDependentValues remedyValues = (RemedyDependentValues) JSON.deserialize(
          JSON.serialize(c),
          RemedyDependentValues.class
        );
        if (remedyValues.remedy == null) {
          continue;
        }
        Complaint_Resolution__c cr1 = new Complaint_Resolution__c(
          IDR_Complaint__c = (Id) input.get('ComplaintId'),
          IDR_Complaint_Remedy__c = remedyValues.remedy,
          IDR_Complaint_Sub_Remedy__c = remedyValues.subRemedy
        );
        if (remedyValues.durationOfRemedy != null) {
          cr1.IDR_Duration_of_Remedy__c = remedyValues.durationOfRemedy;
        }
        if (remedyValues.otherRemedy != null) {
          cr1.IDR_Other_Remedy_Provided__c = remedyValues.otherRemedy;
        }
        if (remedyValues.paymentProvided != null) {
          cr1.IDR_Financial_Compensation__c = remedyValues.paymentProvided;
        }
        if (remedyValues.rewardPoints != null) {
          cr1.IDR_Financial_Remedy_Points__c = remedyValues.rewardPoints;
        }
        if (remedyValues.detailsOfComplaint != null) {
          cr1.IDR_Provided_details_to_Manufacturer__c = remedyValues.detailsOfComplaint;
        }
        if (remedyValues.id != null) {
          cr1.Id = remedyValues.id;
        }
        crtocreate.add(cr1);
      }
      if (!crtocreate.isEmpty()) {
        (new ComplaintResolutionActions()).createResolutionrecords(crtocreate);
    }
  }

  /**
   * @description To handle complaint resolution actions which are used in IP
   */
  private without sharing class ComplaintResolutionActions {
    /**
     * @description To delete Complaint Resolution
     * @param input The input from IP CR Ids
     * @param output The output to be passed to Integration procedure
     * @param options The additional parameters required
     */
    public void deleteComplaintResolution(
      Map<String, Object> input,
      Map<String, Object> output,
      Map<String, Object> options
    ) {
      List<Complaint_Resolution__c> crtodel = new List<Complaint_Resolution__c>();
      List<Object> complaintRes = (List<Object>) input.get(
        'ComplaintResolution'
      );
      for (Object c : complaintRes) {
        Map<String, Object> cr = (Map<String, Object>) c;
        if (
          (cr.containsKey('Remedy') && cr.get('Remedy') == null) ||
          (cr.containsKey('remedyOffered') && cr.get('remedyOffered') == null)
        ) {
          crtodel.add(new Complaint_Resolution__c(Id = (Id) cr.get('Id')));
        }
      } // loop through the CRs node from IP and delete records with blank fields, Remedy
      if (!crtodel.isEmpty()) {
        delete crtodel;
      }
    }
      
/**
   * @description To create complaint resolution records
   * @param crtocreate list of Complaint_Resolution__c records to create
   */
    public void createResolutionrecords(List<Complaint_Resolution__c> crtocreate){
        List<Database.UpsertResult> results = new List<Database.UpsertResult>();
        DMLUtil.upsertRecords(
          crtocreate,
          DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
          DMLUtil.SYSTEM_MODE
        );
      }
    }

    /**
    * @description To get the last modified date of a particular field for a particular Case.
    * @param input The input from IP CR Ids
    * @param output The output to be passed to Integration procedure
    * @param options The additional parameters required
    */
    public void getLastModifiedDateOfField(
        Map<String, Object> input,
        Map<String, Object> output,
        Map<String, Object> options
    ) {
        String fieldName = String.ValueOf(input.get('FieldName'));
        String caseId = String.ValueOf(input.get('recordId'));
        output.put('lastModifiedDate' + fieldName, 0);
        List<CaseHistory> historyList = [
            SELECT CreatedDate
            FROM CaseHistory
            WHERE Field = :fieldName AND CaseId = :caseId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        List<Case> cseList = [SELECT CreatedDate FROM Case WHERE ID =: caseId];
        DateTime lastModifiedDate;
        DateTime now = DateTime.now();
        if (!historyList.isEmpty()){
          lastModifiedDate = historyList[0].CreatedDate;
        }
        else if (!cseList.isEmpty()){
          lastModifiedDate = cseList[0].CreatedDate;
        }
        if(lastModifiedDate != null){
          Integer daysSinceLastUpdate = now.date().daysBetween(lastModifiedDate.date());
          output.put('lastModifiedDate' + fieldName, Math.abs(daysSinceLastUpdate) + ' Days'); 
        }
    }
  /**
   * @description To deserialize the input from IP.
   */
  public class RemedyDependentValues {
    public String remedy;
    public String subRemedy;
    public Decimal durationOfRemedy;
    public String otherRemedy;
    public Decimal paymentProvided;
    public Decimal rewardPoints;
    public Boolean detailsOfComplaint;
    public Id id;
  }
}