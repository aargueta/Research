using ShadowParser;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Ader.Text;

namespace ShadowParserTester
{
    
    
    /// <summary>
    ///This is a test class for VerilogFileParserTest and is intended
    ///to contain all VerilogFileParserTest Unit Tests
    ///</summary>
    [TestClass()]
    public class VerilogFileParserTest {


        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext {
            get {
                return testContextInstance;
            }
            set {
                testContextInstance = value;
            }
        }

        #region Additional test attributes
        // 
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion


        /// <summary>
        ///A test for RunPrecompiler
        ///</summary>
        [TestMethod()]
        [DeploymentItem("ShadowParser.exe")]
        public void RunPrecompilerTest() {
            PrivateObject param0 = null; // TODO: Initialize to an appropriate value
            VerilogFileParser_Accessor target = new VerilogFileParser_Accessor(param0); // TODO: Initialize to an appropriate value
            StringTokenizer tknzr = new StringTokenizer(string.Empty); // TODO: Initialize to an appropriate value
            Token prevTok = null; // TODO: Initialize to an appropriate value
            Token currTok = null; // TODO: Initialize to an appropriate value
            target.RunPrecompiler(tknzr, ref prevTok, ref currTok);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }
    }
}
