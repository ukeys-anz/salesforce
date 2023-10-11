import secretNames from "../Config/secretNames.json" assert { type: "json" };

// To find the related secret name for the target org
// This will be passed on one of the github action steps to find the secret.
// exp:
//   name: Find secret name
//   working-directory: salesforce
//   run: |
//     secretName=$(node ci/workflows/Services/authentication-service.mjs findSecretName "${{ github.base_ref }}")
//     echo SECRET_NAME="$secretName" >> $GITHUB_ENV
//   name: SFDXURL
//      id: secrets
//      uses: google-github-actions/get-secretmanager-secrets@main
//      with:
//      secrets: |-
//        sfdxurl:projects/36540621485/secrets/ghr-salesforce-prod-${{ env.SECRET_NAME }}/versions/latest
const findSecretName = (baseRef) => {
  const secretName = secretNames[baseRef];
  if (!secretName) {
    console.error(`No secret could be found for ${baseRef}`);
    process.exit(1);
  }
  return secretName;
};

export { findSecretName };
