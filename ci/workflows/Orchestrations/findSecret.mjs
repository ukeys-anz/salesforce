import { findSecretName } from "../Services/find-secret-service.mjs";

const { BASE_REF, REPO_NAME } = process.env;

console.log(findSecretName(BASE_REF, REPO_NAME));
