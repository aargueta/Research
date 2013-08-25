using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;

namespace ShadowParser {
    /// <summary>
    /// Used to keep track of possible instantiations of modules not yet defined in the project library.
    /// This allows for modules to be parsed independent of the heirarchy.
    /// </summary>
    public class PossibleInstance {
        private string typeName;
        private string instanceName;
        private string filename;
        private VerilogModule parent;
        public bool paramsExist, paramsNamed;
        public Token paramList;
        private Token bookmark, inOutListEnd;

        public PossibleInstance(string typeName, string instanceName, VerilogModule parentModule, Token bookmark, Token inOutListEnd, bool paramsExist, bool paramsNamed, Token paramList) {
            this.typeName = typeName;
            this.instanceName = instanceName;
            this.filename = parentModule.Filename;
            this.parent = parentModule;
            this.bookmark = bookmark;
            this.inOutListEnd = inOutListEnd;
            this.paramsExist = paramsExist;
            this.paramsNamed = paramsNamed;
            this.paramList = paramList;
        }

        public string InstanceName {
            get { return this.instanceName; }
        }

        public string TypeName {
            get { return this.typeName; }
        }

        public string Filename {
            get { return this.filename; }
        }

        public VerilogModule ParentModule {
            get { return this.parent; }
        }

        public Token Bookmark {
            get { return this.bookmark; }
        }

        public Token InOutListEnd {
            get { return this.inOutListEnd; }
            set { this.inOutListEnd = value; }
        }
    }
}
