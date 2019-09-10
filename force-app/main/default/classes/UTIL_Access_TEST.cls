/**
* Trigger Utils Test Class
* @author saiero
* @date 2019
* @group Utilities
* @description Test class for UTIL_Access
*/
@isTest
private class UTIL_Access_TEST {
	/**
	*	@name setup
	*	@description Create test records once and then access them in every test method in the test class.
	*	@param N/A
	*	@return Void
	*	@throws N/A
	*/
	@testSetup
	static void setup() {
		//create a pset and assign it to current user
		PermissionSet pset = new PermissionSet(Label = 'Bypass Test', Name = 'Bypass_Test');
        insert pset;
		insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = pset.Id);
		//get the test custom perm and link it to the pset
		CustomPermission cp = [SELECT DeveloperName FROM CustomPermission WHERE DeveloperName='bpTest' LIMIT 1];
		insert new SetupEntityAccess(ParentId = pset.Id, SetupEntityId = cp.Id);
	}

	/**
	*	@name testCanTrigger
	*	@description Test the canTrigger method against the following use cases:
	*		1- Required once
	*		2- Second Required once
	*		3- Bypass via custom permission
	*		4- Bypass all
	*		5- No bypass
	*		6- Forced bypass
	*		7- Forced bypass removed
	*		8- Bypass via custom permission bpAll
	*	@param N/A
	*	@return Void
	*	@throws N/A
	**/
	@isTest
	private static void testCanTrigger() {
		String strRequiredOnce = 'AP123';
		String strBypassInCP = 'bpTest';
		String strNotExist = 'nonexistant' + Datetime.now();

		Test.startTest();
		// Required once | Expected = true
		Boolean b01 = UTIL_Access.canTrigger(strRequiredOnce);	
		// Second Required once | Expected = false
		Boolean b02 = UTIL_Access.canTrigger(strRequiredOnce);	
		// Bypass via custom permission | Expected = false
		Boolean b03 = UTIL_Access.canTrigger(strBypassInCP);	
		// Bypass all | Expected = false
		UTIL_Access.bypassAll = true;
		Boolean b04 = UTIL_Access.canTrigger(strNotExist);
		UTIL_Access.bypassAll = false;
		// No bypass | Expected = true
		Boolean b05 = UTIL_Access.canTrigger(strNotExist);
		// Forced bypass | Expected = false
		UTIL_Access.ApexForcedBypass.add(strNotExist);
		Boolean b06 = UTIL_Access.canTrigger(strNotExist);
		// Forced bypass removed | Expected = true
		UTIL_Access.ApexForcedBypass.remove(strNotExist);
		Boolean b07 = UTIL_Access.canTrigger(strNotExist);
		// Bypass via custom permission 'bpAll' | Expected = false
		// First, add that custom perm to the pset that was assigned to user at setup
		PermissionSet pset = [SELECT id FROM PermissionSet WHERE Name='Bypass_Test' LIMIT 1];
		CustomPermission cp = [SELECT id FROM CustomPermission WHERE DeveloperName=:UTIL_Access.BP_ALL_TRG_DNAME LIMIT 1];
		insert new SetupEntityAccess(ParentId = pset.Id, SetupEntityId = cp.Id);
		UTIL_Access.init();	// Need to reinitialize UTIL_Access because of new Custom Permission!
		Boolean b08 = UTIL_Access.canTrigger(strNotExist);

		Test.stopTest();

		System.assertEquals(true, b01, 'Required once | Expected = Can trigger');
		System.assertEquals(false, b02, 'Second Required once | Expected = Cannot trigger');
		System.assertEquals(false, b03, 'Bypass via custom permission | Expected = Cannot trigger');
		System.assertEquals(false, b04, 'Bypass all | Expected = Cannot trigger');
		System.assertEquals(true, b05, 'No bypass | Expected = Can trigger');
		System.assertEquals(false, b06, 'Forced bypass | Expected = Cannot trigger');
		System.assertEquals(true, b07, 'Forced bypass removed | Expected = Can trigger');
		System.assertEquals(false, b08, 'Bypass via custom permission bpAll | Expected = Cannot trigger');
	}
}
