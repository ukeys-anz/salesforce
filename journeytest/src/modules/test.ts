class SfTest {
  xyz = 0;

  methodTest = () => {
    console.log(this.xyz + 1);
  };
}

const sfTest = new SfTest();
console.log(sfTest.xyz);
sfTest.methodTest();
