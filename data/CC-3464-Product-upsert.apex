Id idProductFamily = [SELECT Id, Name
FROM Product_Family__c
WHERE Name = 'Insurance/wealth products'].Id;
List<Product2> lstProducts = new List<Product2>();
for ( Product2 oProduct : [SELECT Id, Name, IDR_Product_Family__c FROM Product2 WHERE ANZ_Product_Code__c IN ('572', '573', '574')]) {
  oProduct.IDR_Product_Family__c = idProductFamily;
  lstProducts.add(oProduct);
}
update lstProducts;
