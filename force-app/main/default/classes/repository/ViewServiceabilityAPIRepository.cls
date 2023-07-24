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
   * @param loanId loan id
   * @return `ViewServiceabilityModel`
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public ViewServiceabilityModel getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String loanId
  ) {
    Service s = ServiceProvider.getService(BOHService.class);
    HttpCalloutResponse response = s.getUMIAssessments(
      sopIds,
      creditId,
      loanId
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
