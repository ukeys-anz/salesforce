import { UserRole, SObject, SObjectAPIName } from "../../constants/enums";
import * as faker from "faker";

export default abstract class Lead {
  public userRole: UserRole;
  public sobject: SObject;
  public sobjectAPIName: SObjectAPIName;
  public firstName: string;
  public lastName: string;
  public mobile: string;
  public email: string;
  public ocvId: string;
  public id: string | undefined;
  public accountId: string | undefined; // converted Account Id

  constructor(userRole: UserRole, init?: Partial<Lead>) {
    // assign Lead default value
    this.sobject = SObject.Lead;
    this.sobjectAPIName = SObjectAPIName.Lead;
    this.userRole = userRole;
    this.firstName = init?.firstName ? init.firstName : faker.name.firstName();
    this.lastName = init?.lastName ? init.lastName : faker.name.lastName();
    this.mobile = init?.mobile
      ? init.mobile
      : faker.phone.phoneNumber("04########");
    this.email = init?.email
      ? init.email
      : faker.internet.exampleEmail(this.firstName, this.lastName);
    this.ocvId = init?.ocvId
      ? init.ocvId
      : faker.datatype.number({ min: 1000000000, max: 9999999999 }).toString();

    Object.assign(this, init);
  }

  abstract create(mockData: any): Promise<void>;
}
