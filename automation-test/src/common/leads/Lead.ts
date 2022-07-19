import { UserRole, SObject, SObjectAPIName } from "../../constants/enums";
import * as faker from "faker";

export default abstract class Lead {
  protected readonly userRole: UserRole;
  public sobject: SObject;
  public sobjectAPIName: SObjectAPIName;
  protected readonly firstName: string;
  protected readonly lastName: string;
  protected readonly mobile: string;
  protected readonly email: string;
  protected readonly ocvId: string;
  protected leadId: string | undefined;
  protected accountId: string | undefined; // converted Account Id

  constructor(userRole: UserRole) {
    this.userRole = userRole;
    this.sobject = SObject.Lead;
    this.sobjectAPIName = SObjectAPIName.Lead;
    this.firstName = faker.name.firstName();
    this.lastName = faker.name.lastName();
    this.mobile = faker.phone.phoneNumber("04########");
    this.email = faker.internet.exampleEmail(this.firstName, this.lastName);
    this.ocvId = faker.datatype
      .number({ min: 1000000000, max: 9999999999 })
      .toString();
  }

  abstract create(mockData: any): Promise<void>;
}
