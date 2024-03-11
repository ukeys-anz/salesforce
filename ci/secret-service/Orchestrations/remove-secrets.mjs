// Remove & Update Sensitive Information ( Certificates, mTLS Certificates, Named Credentials, ConnectedApps )

/// Import different function from services.
import {
  findAllFiles,
  changeForceIgnoreFile,
  retrieveComponent,
  changeCertsOnFiles,
  removeCert,
  discardGitChanges,
  deployFile
} from "../Services/helper.mjs";
///////////

/// Hardcoded username input

const USER_NAME = "PLATFORM";
////////

/// functions

// this is to retrieve named credentials, connectedApps, certificates and mTLS certificates
const retrieveComponents = (username) => {
  changeForceIgnoreFile("Change");
  retrieveComponent(
    "ci/secret-service/Config/certificatePackage.xml",
    username
  );
  retrieveComponent(
    "ci/secret-service/Config/connectedAppPackage.xml",
    username
  );
  retrieveComponent("ci/secret-service/Config/mTLSPackage.xml", username);
  retrieveComponent(
    "ci/secret-service/Config/namedCredentialPackage.xml",
    username
  );
  changeForceIgnoreFile("Revert");
};

// this is to change certificates on named credentials and connectedApps.
// it will change the cert to the dummy one and will deploy it.
const changeCert = (username) => {
  changeForceIgnoreFile("Change");

  const allNamedCredentials = findAllFiles(
    "force-app/main/default/namedCredentials"
  );
  const allConnectedApps = findAllFiles("force-app/main/default/connectedApps");
  changeCertsOnFiles(allNamedCredentials);
  changeCertsOnFiles(allConnectedApps);

  deployFile("force-app/main/default/namedCredentials", username);
  deployFile("force-app/main/default/connectedApps", username);

  changeForceIgnoreFile("Revert");
};

// This is to remove the certificates came from production
const removeCerts = (username) => {
  const allCerts = findAllFiles("force-app/main/default/certs");
  const allMTLS = findAllFiles("force-app/main/default/inboundCertificates");
  removeCert(allCerts, username);
  removeCert(allMTLS, username);
};

const uploadDummyCert = (username) => {
  deployFile(
    "force-app/main/default/certs/DummyCertificate_ToBechanged.crt-meta.xml",
    username
  );
};
/// Run Orchestration

const removeSensitiveInformation = (username) => {
  uploadDummyCert(username);
  retrieveComponents(username);
  changeCert(username);
  removeCerts(username);
  discardGitChanges();
};
/////

removeSensitiveInformation(USER_NAME);
