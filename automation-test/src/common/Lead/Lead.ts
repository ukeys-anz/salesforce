import { UserRole, SObject, SObjectAPIName } from "constants/enums";

export default abstract class Lead {
  protected readonly userRole: UserRole;
  public sobject: SObject;
  public sobjectAPIName: SObjectAPIName;

  constructor(userRole: UserRole) {
    this.userRole = userRole;
    this.sobject = SObject.Lead;
    this.sobjectAPIName = SObjectAPIName.Lead;
  }

  abstract create(mockData: any): Promise<void>;
}
