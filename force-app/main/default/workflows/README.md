# Workflows

Workflows are being phased out of the Salesforce platform with the platform moving to Process Builders.

Ideally
- Triggers should replace general record updates
- Platform Events should be used instead of Outbound Messages

We do not want to use Workflows (or Process Builders/Flows) and instead want all logic to be maintained in triggers as it is easier for us to maintain and build frameworks around.

If you want to use a workflow and believe that it is the best solution to a requirement, please ensure to have a discussion with your peers. A rule has been placed into `.CODEOWNERS` if any PR contains a change to Workflows it requires approval from:
- The Engineering Lead OR
- a Lead Engineer

# Naming Convention

All Workflow Rules should be named `SObject - Function` e.g. `Account - Update Business Name`.

All Workflow Actions should be similarly named if it is relevant (e.g. if an action is SObject specific), but at a minimum should always specify the action it is performing e.g. `Acount - Update Business Name to Person Name` or `Send Outbound Message to Service X`.