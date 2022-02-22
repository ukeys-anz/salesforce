import LwcCustomerDetails from "../pageObjects/lwcCustomerDetails";

export default class SfNavigation {
  selectNavigation = async (menuitem: string) => {
    const customerPageRoot = await utam.load(LwcCustomerDetails);
    const menuSelectElement = await customerPageRoot.getMenuSelect(menuitem);
    menuSelectElement.click();
  };
}
