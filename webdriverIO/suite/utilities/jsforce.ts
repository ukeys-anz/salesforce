const jsforce = require("jsforce");

export const jsForce = new jsforce.Connection({
  instanceUrl: process.env.INSTANCE_URL,
  accessToken: process.env.ACCESS_TOKEN
});
