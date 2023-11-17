/**
 * @author Laxmi
 * @since 04/2023
 * @description  To get the customer information and account numbers on OCV search
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
      (new DeleteCRS()).deleteComplaintResolution(input, output, options);
    } else if ('createComplaintResolution'.equals(methodName)) {
      (new DeleteCRS()).createComplaintResolution(input, output, options);
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
      System.debug('test ' + result);
      output.put('Response', JSON.serialize(result));
    } catch (Exception ex) {
      output.put('Response', '');
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

  private without sharing class DeleteCRS {
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
        if (cr.get('Remedy') == null) {
          crtodel.add(new Complaint_Resolution__c(Id = (Id) cr.get('Id')));
        }
      } // loop through the CRs node from IP and delete records with blank fields, Remedy
      if (!crtodel.isEmpty()) {
        delete crtodel;
      }
    }

    /**
     * @description To create Complaint Resolution
     * @param input The input from IP CR Ids
     * @param output The output to be passed to Integration procedure
     * @param options The additional parameters required
     */
    public void createComplaintResolution(
      Map<String, Object> input,
      Map<String, Object> output,
      Map<String, Object> options
    ) {
      List<Complaint_Resolution__c> crtocreate = new List<Complaint_Resolution__c>();
      List<Object> complaintRes = (List<Object>) input.get(
        'ComplaintResolution'
      );
      for (Object c : complaintRes) {
        Map<String, Object> cr = (Map<String, Object>) c;
        Complaint_Resolution__c cr1 = new Complaint_Resolution__c(
          IDR_Complaint__c = (Id) input.get('ComplaintId'),
          IDR_Complaint_Remedy__c = (String) cr.get('Remedy'),
          IDR_Complaint_Sub_Remedy__c = (String) cr.get('SubRemedy')
        );
        if (cr.get('durationOfRemedy') != null) {
          cr1.IDR_Duration_of_Remedy__c = Decimal.valueOf(
            String.valueOf(cr.get('durationOfRemedy'))
          );
        }
        if (cr.get('otherRemedy') != null) {
          cr1.IDR_Other_Remedy_Provided__c = String.valueOf(
            cr.get('otherRemedy')
          );
        }
        if (cr.get('PaymentProvided') != null) {
          cr1.IDR_Financial_Compensation__c = Decimal.valueOf(
            String.valueOf(cr.get('PaymentProvided'))
          );
        }
        if (cr.get('rewardPoints') != null) {
          cr1.IDR_Financial_Remedy_Points__c = Decimal.valueOf(
            String.valueOf(cr.get('rewardPoints'))
          );
        }
        if (cr.get('detailsOfComplaint') != null) {
          cr1.IDR_Provided_details_to_Manufacturer__c = Boolean.valueOf(
            cr.get('detailsOfComplaint')
          );
        }
        crtocreate.add(cr1);
      }
      if (!crtocreate.isEmpty()) {
        insert crtocreate;
      }
    }
  }
}
