/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.TooManyFields, PMD.PropertyNamingConventions'
)
/**
 * @author Paul Boyington
 * @since May 2022
 * @description Model for Close Package API
 */
public with sharing class PackageClosureModel extends CalloutModel {
  @AuraEnabled
  public Status status;
  @AuraEnabled
  public Meta meta;

  /**
   * @description indicates status
   */
  public class Status {
    @AuraEnabled
    public Integer code;
    @AuraEnabled
    public String description;
  }

  /**
   * @description Meta wrapper
   */
  public class Meta {
    @AuraEnabled
    public ClosePackageMetaStatus accountA1;
    @AuraEnabled
    public ClosePackageMetaStatus accountS1;
    @AuraEnabled
    public ClosePackageMetaStatus card;
    @AuraEnabled
    public ClosePackageMetaStatus overall_package;
  }

  /**
   * @description ClosePackageMetaStatus wrapper
   */
  public class ClosePackageMetaStatus {
    @AuraEnabled
    public String number_id;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String error;
  }

  /**
   * @param json input string to deserialize
   * @return `PackageClosureModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static PackageClosureModel parse(String json) {
    Map<String, String> keyMappings = new Map<String, String>{
      'number' => 'number_id',
      'package' => 'overall_package'
    };
    return (PackageClosureModel) deserialize(
      json,
      PackageClosureModel.class,
      keyMappings
    );
  }
}
