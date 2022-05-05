import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  createInstance as _createInstance,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";
import _LwcViewCardsDetails from "./../pageObjects/lwcViewCardsDetails";

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = _By.css("lightning-card");
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_cardDetailsButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css("[data-test-id='get-card-details-button']");
  return _element.findElement(_locator);
}

async function _utam_get_collapseExpandButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css("[data-test-id='collapse-expand-button']");
  return _element.findElement(_locator);
}

async function _utam_get_cardss(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css("[data-test-id='card-details']");
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_loadMoreButton(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css("[data-test-id='load-more']");
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

/**
 * generated from JSON src/utam/lwc/lwcViewCards.utam.json
 * @version 2022-05-03T02:13:15.510Z
 * @author UTAM
 */
export default class LwcViewCards extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCardDetailsButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_cardDetailsButton(driver, root);
    element = await _createInstance(_Button, driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getCollapseExpandButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_collapseExpandButton(driver, root);
    element = await _createInstance(_Button, driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCards() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_cardss(driver, root);
    if (!elements) {
      return null;
    }
    elements = await Promise.all(
      elements.map(function _createElement(element) {
        return _createInstance(_LwcViewCardsDetails, driver, element);
      })
    );
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async __getLoadMoreButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_loadMoreButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async showDetails() {
    const _statement0 = await this.__getCardDetailsButton();
    await _statement0.click();
  }

  async isInDetailsView() {
    const _statement0 = await this.__getCollapseExpandButton();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async hasMoreCards() {
    const _statement0 = await this.__getLoadMoreButton();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async loadMore() {
    const _statement0 = await this.__getLoadMoreButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
  }
}
