using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;

namespace ShadowParser {
    /// <summary>
    /// Corresponds to an instantiation of a Verilog module, it is created by the VerilogModule class once that class has been added to the VerilogProject
    /// module library and an instantiation has been parsed in a VerilogFile.
    /// </summary>
    public class VerilogModuleInstance {
        private VerilogModule parent;
        private VerilogModule moduleType;
        private string instanceName;
        private string filename;
        private bool paramsExist;
        private bool paramsNamed;
        private Token paramList;
        private Token inoutListEnd;
        private int numChains;
        private int lowLclErrId, uppLclErrId;

        /*
        private SortedDictionary<string, string> inPorts;
        private SortedDictionary<string, string> outPorts;
        private SortedDictionary<string, string> inoutPorts;*/

        public VerilogModuleInstance(VerilogModule parent, VerilogModule type, string instanceName, Token inoutListEnd){
            this.parent = parent;
            this.filename = parent.Filename;
            this.moduleType = type;
            this.instanceName = instanceName;
            this.inoutListEnd = inoutListEnd;
        }
        public string InstanceName {
            get { return this.instanceName; }
        }

        public VerilogModule Type {
            get { return this.moduleType; }
        }

        public int ChainsCount {
            get { return this.numChains; }
            set { this.numChains = value; }
        }

        public Token InOutListEnd {
            get { return this.inoutListEnd; }
        }

        public bool Parameterized {
            get { return this.paramsExist; }
            set { this.paramsExist = value; }
        }

        public bool ParametersNamed {
            get { return this.paramsNamed; }
            set { this.paramsNamed = value; }
        }

        public Token ParameterList {
            get { return this.paramList; }
            set { this.paramList = value; }
        }

        public int CalcTotalNumDffs() {
            return this.moduleType.NumTotalDffBits;
        }

        public VerilogModule ParentModule {
            get { return this.parent; }
        }

        public int UpperLocalErrorId {
            get { return this.uppLclErrId; }
        }

        public int LowerLocalErrorId {
            get { return this.lowLclErrId; }
        }

        public void SetLocalErrorIds(int low, int high) {
            this.lowLclErrId = low;
            this.uppLclErrId = high;
        }
    }
}
