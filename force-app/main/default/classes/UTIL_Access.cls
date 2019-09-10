/**
*   Apex Access Utils
*   @author saiero
*   @date 2019
*   @group Utilities
*   @description Utility class to manage access to features and trigger them: trigger bypass and re-entry, controlers. Adapted from PAD https://www.adminbooster.com/pad
*/
public inherited sharing class UTIL_Access {
    @TestVisible
    private static final String BP_ALL_TRG_DNAME = 'bpAllTRG';
    @TestVisible
    private static final String BP_DNAME_PATTERN = 'bp%';
    /**
    *   @description List of Apex codes that should run only once. Add any code to the list
    */
    private static final Set<String> REQUIRED_ONCE = new Set<String>{'AP123','AP432'};
    /**
    *   @description List of Apex code that has already been run. Keep this list empty.
    */
    private static Set<String> hasRun = new Set<String>();
    /**
    *   @description List of triggers that can be bypassed
    */
    public static String bypassCodes{get; private set;}
    /**
    *   @description ex: 'AP123','AP432': List of Apex codes that need to be bypassed, dynamically and temporaryly managed by Apex Code
            Usage example: AP05 is not allowing to delete EmailMessage records; when merging cases, we need to remove/create EmailMessage records to the target Case.
            For this we need to temporary allow deletion, even if the user is not byPassing this rule.

            Implementation example:
            //Switch during the transaction into AP05 bypass, then revert to the original value
            boolean canTriggerAP05=UTIL_Access.canTrigger('AP05');
            if(canTriggerAP05){ //Remove
                UTIL_Access.apexForcedBypass.add('AP05');
            }
            delete [Select Id from EmailMessage where Id in :mapOldNewParentId.keySet() ];
            if(canTriggerAP05){ //restore
                UTIL_Access.apexForcedBypass.remove('AP05');
            }
    */
    public static Set<String> apexForcedBypass = new Set<String>();
    /*
    * @description Can be set by Apex Code to avoid running any logic
    */
    public static Boolean bypassAll = false;

    static {
        init();
    }

	/**
	*	@name init
    *   @description Init the class, by building up the list of triggers that can be bypassed for the current user
	*	@param N/A
	*	@return Void
	*	@throws N/A
	*/
    @TestVisible
    private static void init() {
        String strTmp = '';
        for(CustomPermission cp:[SELECT DeveloperName,(SELECT Id FROM Setupentityaccessitems WHERE SetupEntityType='CustomPermission' AND ParentId IN(SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId()) limit 1)FROM CustomPermission where DeveloperName like :BP_DNAME_PATTERN]) {
            if(cp.SetupEntityAccessItems != null && cp.SetupEntityAccessItems.size() > 0) {
                strTmp += cp.DeveloperName + ';';
            }
        }
        bypassCodes=';'+strTmp;
    }

	/**
	*	@name canTrigger
    *   @description Output whether we execute or bypass
	*	@param String apexName: Trigger code, AKA the name of its related bypass custom permission
	*	@return Boolean: True if processing should occur (apexName not found or no bypass-all), False otherwise
	*	@throws N/A
	*/
    public static Boolean canTrigger(String apexName) {
        if(REQUIRED_ONCE.contains(apexName)) {//If it should run only once
            if(hasRun.contains(apexName)) {
                return false;//Already run, should not run
            }
            hasRun.add(apexName);
        }
        return(bypassCodes.indexOf(';'+apexName+';')==-1 && !apexForcedBypass.contains(apexName) && !bypassAll && bypassCodes.indexOf(';'+BP_ALL_TRG_DNAME+';')==-1);
    }
}
