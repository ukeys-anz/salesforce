import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";

export const redirectToRecordByName = async (
  recordName: string
): Promise<void> => {
  await searchRecordInGlobalSearchAndRedirect(recordName);
};
