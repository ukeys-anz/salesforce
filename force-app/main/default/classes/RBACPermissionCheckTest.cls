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
    Profile p = CommonUtil.getProfileByName('ANZ Standard User');
    List<PermissionSet> pSets = new List<PermissionSet>(
      [
        SELECT Id, Name
        FROM PermissionSet
        WHERE Name = 'IDR_User_Level_3' OR Name = 'IDR_User'
      ]
    );
    //Create IDR User
    User idrUser = TestUtil.createTestUser(
      new Map<String, Object>{ 'ProfileId' => p.Id }
    );
    insert idrUser;
    List<PermissionSetAssignment> pSetAssignments = new List<PermissionSetAssignment>();
    for (PermissionSet ps : pSets) {
      pSetAssignments.add(TestUtil.createPSAssignment(idrUser.id, ps.Id));
    }
    insert pSetAssignments;

    //The commented objects are currently not available in our org.
    //Once available they will be uncommented.
    String[] objectList = new List<String>{
      'Asset',
      'Campaign',
      // 'Opportunity',
      'Lead',
      'Order',
      'PriceBook2',
      'Quote',
      'ServiceContract'
      /*'SalesContract',
      'Solution',
      'WorkOrder',
      'EmployeeWorkOrder'*/
    };

    PermissionChecker.PermissionReport report = PermissionChecker.hasReadAllPermission(
      objectList,
      idrUser.id
    );
    System.assertEquals(
      false,
      report.hasPermission,
      'User has access to ' +
      String.join(new List<String>(report.sObjectAccess), ', ')
    );
  }
}
