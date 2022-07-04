import { OwnerType } from "../constants/enums";

export default interface IAssignNewOwner {
  assignNewOwner(newOwnerType: OwnerType, newOwnerName: string): Promise<void>;
}
