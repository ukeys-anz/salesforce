import { ownerType } from "types/record";
export default abstract class Case {
  protected readonly userRole: string;

  constructor(userRole: string) {
    this.userRole = userRole;
  }

  abstract createRecord(): Promise<void>;
  abstract updateRecord(): Promise<void>;
  abstract assignNewOwner(ownerType?: ownerType): Promise<void>;
  abstract closeRecord(): Promise<void>;
}
