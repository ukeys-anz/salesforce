/**
 *
 * @author Peter Charalambous
 * @since 06/2020
 * @description Test RBAC Controls for restricted licenses (https://confluence.service.anz/display/ABT/RBAC+Controls+for+Restricted+Licenses)
 */
@isTest
public class RBACPermissionCheckTest {
  @isTest
  static void testPermission() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];
    PermissionSet ps = [
      SELECT Id, Name
      FROM PermissionSet
      WHERE Name = 'IDR_Level_3'
    ];
    //Create IDR User
    User idrUser = (User) FakerFactory.make(new FakerUserFactory());
    idrUser.ProfileId = p.Id;
    insert idrUser;
    insert new PermissionSetAssignment(
      AssigneeId = idrUser.id,
      PermissionSetId = ps.Id
    );

    String[] objectList = new List<String>{
      'Asset',
      'Campaign',
      'Opportunity',
      'Lead',
      'Order',
      'Product2',
      'PriceBook2',
      'Entitlement',
      'Quote',
      'ServiceContract'
    };

    PermissionChecker.PermissionReport pReport = PermissionChecker.HasReadAllPermission(
      objectList,
      idrUser.id
    );
    System.assertEquals(false, pReport.HasPermission);
  }
}
