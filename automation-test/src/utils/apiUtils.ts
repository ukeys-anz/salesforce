import { Connection, StandardSchema } from "jsforce";

export const loginJSForce = async (username: string, password: string) => {
  if (!username || !password) {
    return;
  }
  const conn = new Connection<StandardSchema>({
    loginUrl: process.env.SALESFORCE_LOGIN_URL
  });

  await conn.login(username, password);

  return conn;
};
