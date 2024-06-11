### Manual Steps

1. Using the created manual steps folder for a release, this workflow will do the right job for release.

2. Salesforce Manual Steps Workflow | Production is a manual workflow that you can run it manually against each sandbox that you want. There are some inputs that you need to pass to run this workflow:

   - `manual_step_name` :

     - description: "Pre/Post deploy step?"
     - required: true

   - `release_folder_name` :

     - description: "Which release manual steps folder?"
     - required: true

   - `exclude_epic_folders` :

     - description: "Manual steps folders to be excluded?"
     - required: false

     - Point: this can be some folders together with comma splited. ( eg: epic/anzx-bau, develop)

3. This workflow will have two steps:

- One step to be approved by engineers to run the manual steps.

- Deploying and running all the manual steps.

- This is just for non-prod sandboxes.

4. After each release, the release folder will be removed by release engineer ( when they do master to dev ) and a new folder for new release will be created and the pattern should be followed. ( Create release folder, then epic folders, and inside them `preSteps` or `postSteps` files.)
