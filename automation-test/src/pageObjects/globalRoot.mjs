import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

async function _utam_get_knowledgeApprovalHistoryDropDownApprove(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.branding-actions.forceActionsDropDownMenuList li:nth-of-type(1) a`
  );
  return _element.findElement(_locator);
}

export default class GlobalRoot extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getKnowledgeApprovalHistoryDropDownApprove() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_knowledgeApprovalHistoryDropDownApprove(
      driver,
      root
    );
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async approveArticle() {
    const _statement0 =
      await this.__getKnowledgeApprovalHistoryDropDownApprove();
    await _statement0.click();
  }
}
