import { findSecretName } from "../Services/find-secret-service.mjs";

const { BASE_REF } = process.env;

console.log(findSecretName(BASE_REF));
