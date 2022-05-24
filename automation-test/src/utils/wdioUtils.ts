import { UserRole } from "constants/enums";
import { loginJSForce } from "utils/apiUtils";

export const cleanupTestData = async (
  userRole: UserRole,
  sobjects: string[]
) => {
  const userDetails = getUserDetails(userRole);
  const conn = await loginJSForce(userDetails.username!, userDetails.password!);

  if (conn) {
    for (const s of sobjects) {
      const records = await conn
        .sobject(s)
        .find({
          CreatedById: { $eq: userDetails.userId }
        })
        .destroy();
    }
  }
};

const getUserDetails = (userRole: UserRole) => {
  const userRoleValues = Object.values(UserRole);
  const userRoleKeys = Object.keys(UserRole);

  const roleIndex = userRoleValues.indexOf(userRole as unknown as UserRole);
  if (roleIndex !== -1) {
    const roleKey = userRoleKeys[roleIndex];
    const usernameVar = roleKey + "_USERNAME";
    const passwordVar = roleKey + "_PASSWORD";
    const userIdVar = roleKey + "_USERID";

    const userDetails = {
      username: process.env[usernameVar],
      password: process.env[passwordVar],
      userId: process.env[userIdVar]
    };
    return userDetails;
  } else {
    console.error(
      "Error: Cannot find any matching test user's credential, exiting..."
    );
    process.exit(-1);
  }
};
