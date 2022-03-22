import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";

export default class Highlights2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getSecondaryFieldText(fieldIndexStarting1: number): Promise<string>;
  getPrimaryFieldContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getIconContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getSecondaryFields<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T[]>;
  getSecondaryFieldContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getActionsRibbon(): Promise<_ActionsRibbon>;
  getActionsContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
}
