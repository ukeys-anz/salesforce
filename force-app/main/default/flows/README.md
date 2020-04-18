# Flows (and Process Builders)

Flows and Process Builders are only to be used by exception, as our engineering practise prefers to write and maintain code (LWX over Visual Flows and Triggers over Process Builders).

Ideally
- Triggers should replace general record updates via PB
- *Never* write server side automation in a flow, it should always be in a trigger
- Triggers is strongly preferred to Process Builder

We do not want to use Process Builders/Flows (or Workflows) and instead want all logic to be maintained in triggers as it is easier for us to maintain and build frameworks around.

If you want to use a flow or process builder and believe that it is the best solution to a requirement, please ensure to have a discussion with your peers. A rule has been placed into `.CODEOWNERS` if any PR contains a change to a Flow or Process Builder it requires approval from:
- The Engineering Lead OR
- a Lead Engineer

# Naming Convention

All Flows should be named by the function it proves e.g. `Setup Wizard`.

Each SObject *should have no more than one* Process Builder, and the Process Builder should be named `SObject Process` e.g. `Account Process`.