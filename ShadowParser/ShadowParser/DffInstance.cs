using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;

namespace ShadowParser {
    public class DffInstance {
        private string typeName;
        private string instanceName;
        private Token portList;
        private Token paramList;
        private string clkPort;
        private string dPort;
        private string qPort;
        private int sizeParam;
        private bool parameterized;
        private string paramName;

        public bool ParametersExist;
        public bool ParametersNamed;
        public bool ParamsInParens;
        public Token ParameterBegin;
        public Token ParameterEnd;
         

        private int errId;

        public DffInstance(DFFModule dffType) {
            this.typeName = dffType.typeName;
        }

        public string InstanceName {
            get { return this.instanceName; }
            set { this.instanceName = value; }
        }

        public Token PortList {
            get { return this.portList; }
            set { this.portList = value; }
        }
        
        public Token ParameterList {
            get { return this.paramList; }
            set { this.paramList = value; }
        }

        public string ClockPort {
            get { return this.clkPort; }
            set { this.clkPort = value; }
        }

        public string DPort {
            get { return this.dPort; }
            set { this.dPort = value; }
        }

        public string QPort {
            get { return this.qPort; }
            set { this.qPort = value; }
        }

        public int Size {
            get { return this.sizeParam; }
            set { this.sizeParam = value; }
        }

        public bool IsParameterized {
            get { return this.parameterized; }
            set { this.parameterized = value; }
        }

        public string Parameter {
            get { return this.paramName; }
            set { this.paramName = value; }
        }

        public int ErrorId {
            get { return this.errId; }
            set { this.errId = value; }
        }
    }
}
