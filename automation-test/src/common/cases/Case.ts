import { ownerType } from "types/record";
import { UserRole } from "constants/enums";
export default abstract class Case {
  protected readonly userRole: UserRole;

  constructor(userRole: UserRole) {
    this.userRole = userRole;
  }

  abstract createRecord(): Promise<void>;
  abstract updateRecord(): Promise<void>;
  abstract assignNewOwner(ownerType?: ownerType): Promise<void>;
  abstract closeRecord(): Promise<void>;
}
