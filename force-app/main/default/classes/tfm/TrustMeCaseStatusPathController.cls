/**
 * @description       : LWC Controller for trustMeCaseStatusUpdateModal
 * @author            : Shivraj Kadam
 * @group             :
 * @last modified on  : Feb 2025
 **/
public with sharing class TrustMeCaseStatusPathController {
  /**
   * @description Trigger TrustMe Case Update Flow
   * @param trustMeCase Case with new fields data to be updated
   * @param comments comments to create Case Comments
   */
  @AuraEnabled
  public static void updateStatus(
    Case trustMeCase,
    String comments
  ) {
    try {
      TrustMeCaseStatusPathHelper.makeAPICallout(trustMeCase);
      TrustMeCaseStatusPathHelper.handleCaseUpdate(trustMeCase, comments);
    } catch (TrustMeAPIRepository.InsufficientAccessException e) {
      throw new AuraHandledException('InsufficientAccessException');
    } catch (TrustMeAPIRepository.ServerErrorException e) {
      throw new AuraHandledException('ServerErrorException');
    } catch (DmlException e) {
      throw new AuraHandledException('DmlException');
    } catch (Exception e) {
      throw new AuraHandledException('Exception');
    }
  }
}