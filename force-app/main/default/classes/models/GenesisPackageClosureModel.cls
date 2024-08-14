/**
 * @author Nilesh Kalal/Kopal Goswami
 * @since 10 June 2024
 * @description Model for Close Package API
 */
public with sharing class GenesisPackageClosureModel extends CalloutModel {
  @AuraEnabled
  public Integer accountsClosed;
  @AuraEnabled
  public Integer cardsClosed;
  @AuraEnabled
  public Integer packagesClosed;
  @AuraEnabled
  public ErrorInfo errorInfo;
  /**
   * @description indicates errorInfo
   */
  public class ErrorInfo {
    @AuraEnabled
    public Integer errorCode;
    @AuraEnabled
    public String reason;
  }

  /**
   * @param packageClosureResponse input string to deserialize
   * @return `GenesisPackageClosureModel`
   * @description deserializes the input string into the model, using the base method
   */
  public static GenesisPackageClosureModel parse(String packageClosureResponse) {
    return (GenesisPackageClosureModel) deserialize(
      packageClosureResponse,
      GenesisPackageClosureModel.class
    );
  }
}
