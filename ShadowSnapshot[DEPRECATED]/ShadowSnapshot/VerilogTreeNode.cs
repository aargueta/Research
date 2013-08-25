using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ShadowSnapshot {
    class VerilogTreeNode : TreeNode {
        private VerilogFile vFile;

        public VerilogTreeNode(VerilogFile vFile) {
            this.vFile = vFile;
            StringBuilder sb = new StringBuilder();
            foreach (int chainLength in this.vFile.ShadowChains) {
                sb.AppendFormat("%d|", chainLength);
            }
            this.Text = this.vFile.ModuleName + " - " + this.vFile.NumDffBits + " [" + sb.ToString() +  "]";
        }

        public VerilogFile VFile {
            get {
                return this.vFile;
            }
        }

        public void Refresh() {
            StringBuilder sb = new StringBuilder();
            foreach (int chainLength in this.vFile.ShadowChains) {
                sb.AppendFormat("%d|", chainLength);
            }
            this.Text = this.vFile.ModuleName + " - " + this.vFile.NumDffBits + " [" + sb.ToString() + "]";
            if (this.Level > 0) {
                ((VerilogTreeNode)this.Parent).Refresh();
            }
        }

    }
}
