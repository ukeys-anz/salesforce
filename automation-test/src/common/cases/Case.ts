import { SObjectAPIName, UserRole } from "constants/enums";
import { SObject } from "constants/enums";

export default abstract class Case {
  protected readonly userRole: UserRole;
  public caseNumber: string | undefined;
  public sobject: SObject;
  public sobjectAPIName: SObjectAPIName;

  constructor(userRole: UserRole) {
    this.userRole = userRole;
    this.caseNumber = undefined;
    this.sobject = SObject.Case;
    this.sobjectAPIName = SObjectAPIName.Case;
  }

  abstract create(mockData: any): Promise<void>;
  abstract update(): Promise<void>;
  abstract close(): Promise<void>;
}
