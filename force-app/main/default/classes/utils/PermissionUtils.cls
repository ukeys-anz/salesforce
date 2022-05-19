/**
 *
 * @author Jasmine Nguyen
 * @since 05/2022
 * @description Utility class for sObject permissions
 */
public with sharing class PermissionUtils {
  /**
   * @description Checks if the user has create permission on a specific object
   * @param objectName Name of the object which we need to check if the user has create permission on
   * @return Boolean - True if the user has create permission, otherwise throws an error
   */
  public static Boolean canCreate(String objectName) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
    Boolean createable = targetType.getDescribe().isQueryable();

    if (!createable) {
      NoAccessException error = new System.NoAccessException();
      error.setMessage(
        'User does not have the permissions to create ' + objectName
      );
      throw error;
    }

    return createable;
  }

  /**
   * @description Checks if the user has access permission on a specific object
   * @param objectName Name of the object which we need to check if the user has access permission on
   * @return Boolean - True if the user has access permission, otherwise throws an error
   */
  public static Boolean canAccess(String objectName) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
    Boolean accessible = targetType.getDescribe().isAccessible();

    if (!accessible) {
      NoAccessException error = new System.NoAccessException();
      error.setMessage(
        'User does not have the permissions to access ' + objectName
      );
      throw error;
    }

    return accessible;
  }

  /**
   * @description Checks if the user has update permission on a specific object
   * @param objectName Name of the object which we need to check if the user has update permission on
   * @return Boolean - True if the user has update permission, otherwise throws an error
   */
  public static Boolean canUpdate(String objectName) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
    Boolean updateable = targetType.getDescribe().isUpdateable();

    if (!updateable) {
      NoAccessException error = new System.NoAccessException();
      error.setMessage(
        'User does not have the permissions to update ' + objectName
      );
      throw error;
    }

    return updateable;
  }

  /**
   * @description Checks if the user has delete permission on a specific object
   * @param objectName Name of the object which we need to check if the user has delete permission on
   * @return Boolean - True if the user has the delete permission, otherwise throws an error
   */
  public static Boolean canDelete(String objectName) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
    Boolean deletable = targetType.getDescribe().isDeletable();

    if (!deletable) {
      NoAccessException error = new System.NoAccessException();
      error.setMessage(
        'User does not have the permissions to delete ' + objectName
      );
      throw error;
    }

    return deletable;
  }

  /**
   * @description Checks if the user has query permission on a specific object
   * @param objectName Name of the object which we need to check if the user has query permission on
   * @return Boolean - True if the user has query permission, otherwise throws an error
   */
  public static Boolean canQuery(String objectName) {
    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
    Boolean queryable = targetType.getDescribe().isQueryable();

    if (!queryable) {
      NoAccessException error = new System.NoAccessException();
      error.setMessage(
        'User does not have the permissions to query ' + objectName
      );
      throw error;
    }

    return queryable;
  }
}
