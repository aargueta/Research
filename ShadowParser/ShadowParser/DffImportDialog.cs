using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ShadowParser {
    public partial class DffImportDialog : Form {
        private List<DFFModule> inDffs;
        private List<DFFModule> outDffs;

        public DffImportDialog() {
            InitializeComponent();
        }

        public List<DFFModule> Import(VerilogFile vFile) {
            inDffs = new List<DFFModule>();
            foreach (KeyValuePair<string, VerilogModule> pair in vFile.DeclaredModules) {
                DFFModule dff = new DFFModule(pair.Value.Name, "clk", "d", "q");
                inDffs.Add(dff);
                this.checkedListBox1.Items.Add(dff);
            }
            DialogResult dr = this.ShowDialog();
            return outDffs;
        }

        void DffImportDialog_FormClosing(object sender, System.Windows.Forms.FormClosingEventArgs e) {
            outDffs = new List<DFFModule>();
            foreach (object dff in checkedListBox1.CheckedItems) {
                outDffs.Add((DFFModule)dff);
            }
        }

        private void checkAllButton_Click(object sender, EventArgs e) {
            
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e) {
            checkBox1.Text = checkBox1.Checked? "Uncheck all" : "Check all";
            for (int i = 0; i < checkedListBox1.Items.Count; i++) {
                checkedListBox1.SetItemChecked(i, checkBox1.Checked);
            }
        }

    }
}
