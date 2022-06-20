/**
 * @author Adam Smith
 * @since 20220411
 * @description  Class to help DML Operations for Interactions
 */
public with sharing class InteractionDMLHelper {
  /**
   * @description Method to update the interactions record
   * @param interactions The list of interactions to be updated
   */
  public static void updateInteractions(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(interactions);
      lib_systemLog log = new lib_systemLog(
        'InteractionsDMLHelper',
        'updateInteractions'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Interaction',
        results,
        interactions
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionsDMLHelper',
        'updateInteractions',
        'Not enough permissions to update Interactions.'
      );
    }
  }
}
