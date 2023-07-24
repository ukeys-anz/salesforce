/**
 * @author Mani
 * @since June 2023
 * @description Controller for Credit Assessment flex card
 * @design https://confluence.service.anz/display/ABT/BOH+104+-+View+UMI
 */
global with sharing class ViewServiceabilityController implements omnistudio.VlocityOpenInterface {
  private static final String METHODNAME = 'getUMIAssessments';
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
    if (methodName.equals(METHODNAME)) {
      return getUMIAssessments(input, output, options);
    }
    return false;
  }

  /**
   * @param input arg for omnistudio flex card
   * @param output arg for omnistudio flex card
   * @param options arg for omnistudio flex card
   * @return `Boolean`
   * @description calls callout framework and sanitizes payload for flexcard
   */
  private Boolean getUMIAssessments(
    Map<String, Object> input,
    Map<String, Object> output,
    Map<String, Object> options
  ) {
    UMIResponse result = new UMIResponse();
    List<ResidentialLoanApplication> loanRec = getLoanRecord(
      (String) input.get('loanId')
    );

    result.hasError = (loanRec.isEmpty() ||
    String.isBlank(loanRec[0]?.Credit_ID__c) ||
    String.isBlank(loanRec[0]?.SOP_Id__c));
    result.isSubmitted = String.isNotBlank(loanRec[0]?.Assessment_Outcome__c);

    if (!result.hasError && result.isSubmitted) {
      try {
        ViewServiceabilityAPIRepository api = new ViewServiceabilityAPIRepository();
        ViewServiceabilityModel apiResponse = api.getUMIAssessments(
          new List<String>{ loanRec[0]?.SOP_Id__c },
          loanRec[0]?.Credit_ID__c,
          loanRec[0]?.Name,
          loanRec[0]?.Account?.OCV_ID__c
        );
        transformAPIToUIResponse(result, apiResponse);
      } catch (Exception ex) {
        result.hasError = true;
      }
    }

    output.put('result', JSON.deserializeUntyped(JSON.serialize(result)));
    return true;
  }

  private class UMIResponse {
    Boolean hasError;
    Boolean isSubmitted;
    Decimal totalUmi;
    String lastModified;
    List<Assessment> incomeAssessment = new List<Assessment>();
    List<Assessment> hemExpenses = new List<Assessment>();
    List<Assessment> nonHemExpenses = new List<Assessment>();
    List<Assessment> liabilities = new List<Assessment>();
  }
  private class Assessment implements Comparable {
    String applicant = '';
    String category;
    Set<String> ocvIds;
    String type = '';
    Decimal applicationAmount;
    Decimal assessedAmount;

    private Assessment(
      String ocvId,
      String type,
      Decimal applicationAmount,
      Decimal assessedAmount,
      String category
    ) {
      this.ocvIds = new Set<String>{ ocvId };
      this.type = type;
      this.applicationAmount = applicationAmount;
      this.assessedAmount = assessedAmount;
      this.category = category;
    }

    private Assessment(
      Set<String> ocvIds,
      String type,
      Decimal applicationAmount,
      Decimal assessedAmount,
      String category
    ) {
      this.ocvIds = ocvIds;
      this.type = type;
      this.applicationAmount = applicationAmount;
      this.assessedAmount = assessedAmount;
      this.category = category;
    }

    private Assessment(
      Decimal applicationAmount,
      Decimal assessedAmount,
      String category
    ) {
      Set<String> ocvIds = new Set<String>();
      this.applicant = 'Total';
      this.type = '';
      this.applicationAmount = applicationAmount;
      this.assessedAmount = assessedAmount;
      this.category = category;
    }
    /**
     * @description convert application amount decimal value to string to display in flexcard
     */
    public String applicationAmountStr {
      get {
        return BOHService.convertDecimalToString(this.applicationAmount);
      }
    }
    /**
     * @description convert assessed amount decimal value to string to display in flexcard
     */
    public String assessedAmountStr {
      get {
        return BOHService.convertDecimalToString(this.assessedAmount);
      }
    }

    /**
     * @description override method for Comparable interface to provide custom sorting mechanism
     * @param objectToCompare instance of Assessment Object to compare againt.
     * @return `Integer` comparision result (-1 | 0 | 1) to define the sorting index
     */
    public Integer compareTo(Object objectToCompare) {
      Assessment compare = ((Assessment) objectToCompare);
      //Keep the total as last item always
      if (this.applicant == 'Total') {
        return 1;
      } else if (compare.applicant == 'Total') {
        return -1;
      } else if (
        this.category == 'incomeAssessment' ||
        this.category == 'liabilities'
      ) {
        return this.compareIncomeAndDebt(compare);
      } else if (
        this.category == 'hemExpenses' ||
        this.category == 'nonHemExpenses'
      ) {
        return this.type.compareTo(compare.type);
      } else {
        return 1;
      }
    }
    private Integer compareIncomeAndDebt(Assessment compare) {
      if (this.type == BOHService.ANZPLUSLOAN && this.type == compare.type) {
        return 0;
      } else if (this.type == BOHService.ANZPLUSLOAN) {
        return 1;
      } else if (compare.type == BOHService.ANZPLUSLOAN) {
        return -1;
      } else if (this.ocvIds.size() < compare.ocvIds.size()) {
        return -1;
      } else if (this.ocvIds.size() > compare.ocvIds.size()) {
        return 1;
      } else {
        Integer nameCompare = this.applicant.compareTo(compare.applicant);
        if (nameCompare == 0) {
          return this.compareOnAssessedAmount(compare);
        } else {
          return nameCompare > 0 ? 1 : -1;
        }
      }
    }
    private Integer compareOnAssessedAmount(Assessment compare) {
      if (this.assessedAmount == null) {
        return 1;
      } else if (compare.assessedAmount == null) {
        return -1;
      } else if (this.assessedAmount > compare.assessedAmount) {
        return -1;
      } else if (this.assessedAmount < compare.assessedAmount) {
        return 1;
      } else if (this.assessedAmount == compare.assessedAmount) {
        return 0;
      } else {
        return 1;
      }
    }
  }

  private static Map<String, String> applicantNameMapByOcvId = new Map<String, String>();
  private void transformAPIToUIResponse(
    UMIResponse result,
    ViewServiceabilityModel apiResponse
  ) {
    result.totalUmi = apiResponse?.totalUMI?.value();
    result.lastModified = BOHService.getFormatedDate(apiResponse?.createTime);

    Set<String> ocvIds = new Set<String>();
    for (ViewServiceabilityModel.Assessment item : apiResponse?.assessments) {
      result.incomeAssessment.addAll(
        processAssessment(ocvIds, item.incomeAssessment, 'incomeAssessment')
      );
      result.hemExpenses.addAll(
        processAssessment(ocvIds, item.hemExpenses, 'hemExpenses')
      );
      result.nonHemExpenses.addAll(
        processAssessment(ocvIds, item.nonHemExpenses, 'nonHemExpenses')
      );
      result.liabilities.addAll(
        processAssessment(ocvIds, item.liabilities, 'liabilities')
      );
    }

    for (Account acc : getApplicants(ocvIds)) {
      applicantNameMapByOcvId.put(acc.OCV_ID__c, acc.FirstName);
    }
    updateAplicantsName(result.incomeAssessment);
    updateAplicantsName(result.hemExpenses);
    updateAplicantsName(result.nonHemExpenses);
    updateAplicantsName(result.liabilities);

    result.incomeAssessment.sort();
    result.hemExpenses.sort();
    result.nonHemExpenses.sort();
    result.liabilities.sort();
  }

  private List<Assessment> processAssessment(
    Set<String> ocvIds,
    ViewServiceabilityModel.AssessmentCategory apiAssessment,
    String category
  ) {
    List<Assessment> uiAssessments = new List<Assessment>();
    if (apiAssessment?.summary != null && !apiAssessment?.summary?.isEmpty()) {
      for (
        ViewServiceabilityModel.AssessmentSummary item : apiAssessment?.summary
      ) {
        if (String.isNotBlank(item.ocvId)) {
          ocvIds.add(item.ocvId);
          uiAssessments.add(
            new Assessment(
              item?.ocvId,
              item?.type,
              item?.applicationAmount?.value(),
              item?.assessedAmount?.value(),
              category
            )
          );
        } else if (item?.parties != null && !item?.parties?.isEmpty()) {
          Set<String> patyIds = new Set<String>();
          for (ViewServiceabilityModel.PartyInfo party : item?.parties) {
            patyIds.add(party.ocvId);
          }
          ocvIds.addAll(patyIds);
          uiAssessments.add(
            new Assessment(
              patyIds,
              item?.type,
              item?.applicationAmount?.value(),
              item?.assessedAmount?.value(),
              category
            )
          );
        }
      }
      uiAssessments.add(
        new Assessment(
          apiAssessment?.totalApplicationAmount?.value(),
          apiAssessment?.totalassessedAmount?.value(),
          category
        )
      );
    }

    return uiAssessments;
  }

  private void updateAplicantsName(List<Assessment> uiAssessments) {
    for (Assessment uiAssessment : uiAssessments) {
      if (uiAssessment.ocvIds != null) {
        uiAssessment.applicant = String.join(
          getApplicantNames(uiAssessment.ocvIds),
          ' & '
        );
      }
    }
  }

  private List<String> getApplicantNames(Set<String> ocvIds) {
    List<String> applicantNames = new List<String>();
    for (String ocvId : ocvIds) {
      if (applicantNameMapByOcvId.containsKey(ocvId)) {
        applicantNames.add(applicantNameMapByOcvId.get(ocvId));
      }
    }
    applicantNames.sort();
    return applicantNames;
  }

  private List<ResidentialLoanApplication> getLoanRecord(String loanId) {
    return [
      SELECT
        Id,
        Assessment_Outcome__c,
        Credit_ID__c,
        SOP_Id__c,
        Name,
        Account.OCV_ID__c
      FROM ResidentialLoanApplication
      WHERE Id = :loanId
      LIMIT 1
    ];
  }
  private List<Account> getApplicants(Set<String> ocvIds) {
    return [
      SELECT id, FirstName, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN :ocvIds
    ];
  }
}
