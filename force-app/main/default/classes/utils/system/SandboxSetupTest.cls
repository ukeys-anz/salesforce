/**
 * @author Alan Hillgemann
 * @since September 2024
 *  @description Test class for {@link SandboxSetup}
 */
@isTest
private class SandboxSetupTest {
  private static List<PermissionSetAssignment> getPsas(
    Set<String> psNames,
    Id userId
  ) {
    return [
      SELECT Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSet.Name IN :psNames
    ];
  }
  @isTest
  static void testRunApexClassUserWithNoPsas() {
    User user = TestUtil.createTestUserWithProfile(
      'Minimum Access - Salesforce'
    );
    insert user;
    Test.startTest();
    Test.testSandboxPostCopyScript(
      new SandboxSetup(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName(),
      true
    );
    Test.stopTest();
    Assert.areEqual(
      CommonUtil.getProfileByName('System Administrator').Id,
      [SELECT ProfileId FROM User WHERE Id = :user.Id].ProfileId,
      'System Administrator profile should be assigned'
    );
    List<PermissionSetAssignment> psas = getPsas(
      new Set<String>{ 'Disable_MFA', 'Enforce_SSO' },
      user.id
    );
    Assert.areEqual(1, psas.size(), 'One permission set should be assigned');
    Assert.areEqual(
      'Disable_MFA',
      psas[0].PermissionSet.Name,
      'Disable_MFA permission set should be assigned'
    );
  }
  @isTest
  static void testRunApexClassUserWithPsas() {
    User user = TestUtil.createTestUserWithProfile('System Administrator');
    insert user;
    List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user.Id,
        PermissionSetId = CommonUtil.getPermissionSetByName('Disable_MFA').Id
      ),
      new PermissionSetAssignment(
        AssigneeId = user.Id,
        PermissionSetId = CommonUtil.getPermissionSetByName('Enforce_SSO').Id
      )
    };
    insert psas;
    Test.startTest();
    Test.testSandboxPostCopyScript(
      new SandboxSetup(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName(),
      true
    );
    Test.stopTest();
    psas = new List<PermissionSetAssignment>(
      getPsas(new Set<String>{ 'Disable_MFA', 'Enforce_SSO' }, user.id)
    );
    Assert.areEqual(1, psas.size(), 'One permission set should be assigned');
    Assert.areEqual(
      'Disable_MFA',
      psas[0].PermissionSet.Name,
      'Disable_MFA permission set should be assigned'
    );
  }
  @isTest
  static void testPsasToAdd() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>{
      'Disable_MFA' => new PermissionSetAssignment(),
      'Enforce_SSO' => new PermissionSetAssignment()
    };
    Id userId = Lib_FakeIdGenerator.getMockId(User.getSObjectType());
    Test.startTest();
    List<PermissionSetAssignment> psasToAdd = SandboxSetup.psasToAdd(
      psasByName,
      userId
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      psasToAdd.size(),
      'There should be no permission set assignments to add'
    );
  }
  @isTest
  static void testPsasToAddNoPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>();
    Id userId = Lib_FakeIdGenerator.getMockId(User.getSObjectType());
    Test.startTest();
    List<PermissionSetAssignment> psasToAdd = SandboxSetup.psasToAdd(
      psasByName,
      userId
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      psasToAdd.size(),
      'There should be one permission set assignment to add'
    );
    Assert.areEqual(
      CommonUtil.getPermissionSetByName('Disable_MFA').Id,
      psasToAdd[0].PermissionSetId,
      'Permission set assignment to add should be Disable_MFA'
    );
  }
  @isTest
  static void testPsasToRemove() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>{
      'Disable_MFA' => new PermissionSetAssignment(),
      'Enforce_SSO' => new PermissionSetAssignment(
        PermissionSet = CommonUtil.getPermissionSetByName('Enforce_SSO')
      )
    };
    Test.startTest();
    List<PermissionSetAssignment> psasToRemove = SandboxSetup.psasToRemove(
      psasByName
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      psasToRemove.size(),
      'There should be one permission set assignment to remove'
    );
    Assert.areEqual(
      'Enforce_SSO',
      psasToRemove[0].PermissionSet.Name,
      'Permission set assignment to remove should be Enforce_SSO'
    );
  }
  @isTest
  static void testPsasToRemoveNoPsas() {
    Map<String, PermissionSetAssignment> psasByName = new Map<String, PermissionSetAssignment>();
    Test.startTest();
    List<PermissionSetAssignment> psasToRemove = SandboxSetup.psasToRemove(
      psasByName
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      psasToRemove.size(),
      'There should be no permission set assignments to remove'
    );
  }
}
