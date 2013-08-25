using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ShadowParser {
    class VerilogModuleTreeNode : TreeNode {
        private TreeNode node;
        private VerilogModule moduleType;

        public VerilogModuleTreeNode(VerilogModule moduleType) {
            this.node = new TreeNode(moduleType.Name);
            this.moduleType = moduleType;
        }

        public VerilogModule Type {
            get { return this.moduleType; }
        }

        public override string ToString() {
            return moduleType.Name;
        }
    }
}
