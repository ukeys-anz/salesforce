import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class Component2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
}
