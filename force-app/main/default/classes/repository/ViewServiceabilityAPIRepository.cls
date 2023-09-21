/**
 * @author Mani
 * @since June 2023
 * @description View Serviceability API repository for to invoke Mule to get response from SOP, gearbox, LoadApp
 * @design https://confluence.service.anz/display/ABT/BOH+104+-+View+UMI
 * @group Repository
 */
public with sharing class ViewServiceabilityAPIRepository extends RepositoryBase {
  /**
   * @param sopIds sop id
   * @param creditId credit id
   * @param ocvId ocv id of the primary loan application
   * @param termMonths Loan term in months
   * @param loanAmount Loan amount
   * @return `ViewServiceabilityModel`
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public ViewServiceabilityModel getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String ocvId,
    Integer termMonths,
    Decimal loanAmount
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getUMIAssessments(
      sopIds,
      creditId,
      ocvId,
      termMonths,
      loanAmount
    );
    if (response.successful == false) {
      throw response.error;
    }
    try {
      return ViewServiceabilityModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, ViewServiceabilityAPIRepository.class);
      return null;
    }
  }
}
