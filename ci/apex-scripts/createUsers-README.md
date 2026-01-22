# User Manual: Creating Test Users in Salesforce Developer Console

## Overview
This script allows you to batch create multiple test users in a Salesforce sandbox environment with pre-configured roles, profiles, permissions, and manager hierarchies.

## Prerequisites
- Access to Salesforce Developer Console in your target sandbox
- The following helper classes must exist in your org:
  - `QueryRole` - Queries UserRole by DeveloperName
  - `QueryProfile` - Queries Profile by Name
  - `QueryPS` - Queries PermissionSet by Name
  - `QueryPSG` - Queries PermissionSetGroup by DeveloperName
- A CallCenter named "Twilo Flex Call Center Adapter Open CTI" (if creating users with CallCenter access)

## Setup Instructions

### Step 1: Open Developer Console
1. Log into your Salesforce sandbox
2. Click the gear icon (⚙️) in the top right corner
3. Select **Developer Console**

### Step 2: Open Execute Anonymous Window
1. In Developer Console, go to **Debug** → **Open Execute Anonymous Window**
2. Or use keyboard shortcut: `Ctrl+E` (Windows) or `Cmd+E` (Mac)

### Step 3: Configure User Data
1. Open the `createUsers.apex` script
2. Locate the `userDataJSON` variable
3. Uncomment the user definitions you want to create by removing the `//` at the beginning of each line
4. Modify user data as needed following the JSON structure

### User Data JSON Structure
{
  "FirstName": "Test",
  "LastName": "User Name",
  "Username": "_unique.username",
  "UserRole": "Role_Developer_Name",
  "Profile": "Profile Name",
  "Manager": "_manager.username",
  "KnowledgeUser": true,
  "CallCenter": true,
  "FederationId": "fed.id@anznp.com",
  "PermissionSets": ["Permission_Set_1", "Permission_Set_2"],
  "PermissionSetGroups": ["PSG_1", "PSG_2"]
}

#### Field Descriptions
- **FirstName** (optional): User's first name
- **LastName** (required): User's last name
- **Username** (required): Username prefix (sandbox suffix auto-appended)
- **UserRole** (required): DeveloperName of UserRole
- **Profile** (required): Name of Profile
- **Manager** (optional): Username prefix of manager (must exist in same batch or database)
- **KnowledgeUser** (optional): Set to `true` for Knowledge User access
- **CallCenter** (optional): Set to `true` to assign CallCenter
- **FederationId** (optional): Federation identifier for SSO
- **PermissionSets** (optional): Array of Permission Set Names
- **PermissionSetGroups** (optional): Array of Permission Set Group DeveloperNames

### Step 4: Handle Manager Hierarchies
**Important**: If using the `Manager` field:

- **Option A**: Create users in order (managers first, then subordinates in separate executions)
- **Option B**: Remove `Manager` field for users whose managers don't exist yet
- **Option C**: Ensure manager users already exist in the database

### Step 5: Execute the Script
1. Copy the entire contents of `createUsers.apex`
2. Paste into the Execute Anonymous Window
3. Ensure **Open Log** checkbox is checked
4. Click **Execute**

### Step 6: Review Results
1. Check the debug log for:
   - `USER DEBUG|User created successfully: [Username]`
   - Any error messages
2. Verify users created:
   - Go to **Setup** → **Users**
   - Search for the created usernames

## Script Behavior

### Username Generation
- Input: `_cmos.uat.l1.1`
- Output: `_cmos.uat.l1.1@anzx.com.[sandboxname]`

### Default Values
- **Email**: `anzx-salesforce@anz.com` (if not specified)
- **LanguageLocaleKey**: `en_US`
- **LocaleSidKey**: `en_AU`
- **EmailEncodingKey**: `UTF-8`
- **TimeZoneSidKey**: `Australia/Sydney`

### Alias Generation
- Takes first character of FirstName (if present) + first 4 characters of LastName
- Converted to lowercase
- Example: "Test" + "CMOS UAT L1 1" → `tcmos`

## Execution Process
The script performs three main operations:

1. **Create Users**: Inserts all User records with basic information
2. **Assign Permissions**: Assigns Permission Sets and Permission Set Groups
3. **Assign Managers**: Updates User records with ManagerId references

## Common Issues & Solutions

### Issue: NullPointerException on CallCenter
**Solution**: The script already handles this with a try-catch. If CallCenter doesn't exist, users will be created without CallCenter assignment.

### Issue: NullPointerException on Manager
**Cause**: Referenced manager doesn't exist in current batch or database

**Solutions**:
- Remove `"Manager"` field from JSON for affected users
- Create manager users in a separate execution first
- Query existing managers from database (requires code modification)

### Issue: "REQUIRED_FIELD_MISSING" for UserRole/Profile
**Cause**: Specified Role or Profile doesn't exist in org

**Solution**: Verify the exact DeveloperName/Name in Setup

### Issue: "DUPLICATE_USERNAME"
**Cause**: User already exists with that username

**Solution**: Use a different username prefix or delete existing user first

### Issue: Permission Set assignment fails
**Cause**: Permission Set or Permission Set Group doesn't exist

**Solution**: Verify exact API names in Setup → Permission Sets

## Best Practices

1. **Test with Small Batches**: Start with 2-3 users to verify configuration
2. **Review Debug Logs**: Always check logs for warnings or errors
3. **Create Managers First**: If building hierarchies, create in multiple executions
4. **Verify Metadata Exists**: Confirm all Roles, Profiles, and Permission Sets exist before running
5. **Use Meaningful Usernames**: Follow naming conventions like `_[team].[role].[number]`
6. **Document Federation IDs**: Keep track of FederationIds for SSO testing
