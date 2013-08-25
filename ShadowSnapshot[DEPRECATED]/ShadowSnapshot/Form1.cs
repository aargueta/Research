using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using Ader.Text;

namespace ShadowSnapshot {
    public partial class Form1 : Form {
        private Button ShadowFile;
        private TextBox FileLoc;
        private Button Browse;
        private ProgressBar progressBar1;
        private CheckBox owCheckBox;
        private TextBox appendixTextBox;
        private Label label2;
        private TextBox logBox;
        private TextBox qPortNameBox;
        private Label label3;
        private Label label4;
        private TextBox shadowModuleNameBox;
        private TabControl tabControl1;
        private TabPage tabPage1;
        private TabPage tabPage2;
        private Label label7;
        private Label label6;
        private Label label5;
        private TextBox resetNameBox;
        private TextBox clkNameBox;
        private TextBox dPortNameBox;
        private Label label9;
        private TextBox shadowDumpNameBox;
        private Label label8;
        private TextBox shadowCaptureNameBox;
        private TreeView moduleTreeView;
        private Button SubmoduleAddButton;
        private Label label1;

        public Form1() {
            InitializeComponent();
        }

        private void InitializeComponent() {
            this.ShadowFile = new System.Windows.Forms.Button();
            this.FileLoc = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.Browse = new System.Windows.Forms.Button();
            this.progressBar1 = new System.Windows.Forms.ProgressBar();
            this.owCheckBox = new System.Windows.Forms.CheckBox();
            this.appendixTextBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.logBox = new System.Windows.Forms.TextBox();
            this.qPortNameBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.shadowModuleNameBox = new System.Windows.Forms.TextBox();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.label9 = new System.Windows.Forms.Label();
            this.shadowDumpNameBox = new System.Windows.Forms.TextBox();
            this.label8 = new System.Windows.Forms.Label();
            this.shadowCaptureNameBox = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.resetNameBox = new System.Windows.Forms.TextBox();
            this.clkNameBox = new System.Windows.Forms.TextBox();
            this.dPortNameBox = new System.Windows.Forms.TextBox();
            this.moduleTreeView = new System.Windows.Forms.TreeView();
            this.SubmoduleAddButton = new System.Windows.Forms.Button();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.SuspendLayout();
            // 
            // ShadowFile
            // 
            this.ShadowFile.Location = new System.Drawing.Point(164, 91);
            this.ShadowFile.Name = "ShadowFile";
            this.ShadowFile.Size = new System.Drawing.Size(108, 23);
            this.ShadowFile.TabIndex = 1;
            this.ShadowFile.Text = "Create Shadow File";
            this.ShadowFile.UseVisualStyleBackColor = true;
            this.ShadowFile.Click += new System.EventHandler(this.ShadowFile_Click);
            // 
            // FileLoc
            // 
            this.FileLoc.Location = new System.Drawing.Point(136, 16);
            this.FileLoc.Name = "FileLoc";
            this.FileLoc.Size = new System.Drawing.Size(192, 20);
            this.FileLoc.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(63, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(67, 13);
            this.label1.TabIndex = 3;
            this.label1.Text = "File Location";
            // 
            // Browse
            // 
            this.Browse.Location = new System.Drawing.Point(334, 13);
            this.Browse.Name = "Browse";
            this.Browse.Size = new System.Drawing.Size(75, 23);
            this.Browse.TabIndex = 4;
            this.Browse.Text = "Browse";
            this.Browse.UseVisualStyleBackColor = true;
            this.Browse.Click += new System.EventHandler(this.Browse_Click);
            // 
            // progressBar1
            // 
            this.progressBar1.ForeColor = System.Drawing.Color.Red;
            this.progressBar1.Location = new System.Drawing.Point(20, 604);
            this.progressBar1.Name = "progressBar1";
            this.progressBar1.Size = new System.Drawing.Size(435, 23);
            this.progressBar1.TabIndex = 5;
            // 
            // owCheckBox
            // 
            this.owCheckBox.AutoSize = true;
            this.owCheckBox.Location = new System.Drawing.Point(136, 68);
            this.owCheckBox.Name = "owCheckBox";
            this.owCheckBox.Size = new System.Drawing.Size(171, 17);
            this.owCheckBox.TabIndex = 6;
            this.owCheckBox.Text = "Overwrite Existing Shadow File";
            this.owCheckBox.UseVisualStyleBackColor = true;
            // 
            // appendixTextBox
            // 
            this.appendixTextBox.Location = new System.Drawing.Point(136, 42);
            this.appendixTextBox.Name = "appendixTextBox";
            this.appendixTextBox.Size = new System.Drawing.Size(192, 20);
            this.appendixTextBox.TabIndex = 7;
            this.appendixTextBox.Text = "_SHADOWED";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(18, 45);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(112, 13);
            this.label2.TabIndex = 8;
            this.label2.Text = "Shadow File Appendix";
            // 
            // logBox
            // 
            this.logBox.Location = new System.Drawing.Point(12, 461);
            this.logBox.Multiline = true;
            this.logBox.Name = "logBox";
            this.logBox.ReadOnly = true;
            this.logBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.logBox.Size = new System.Drawing.Size(435, 137);
            this.logBox.TabIndex = 10;
            // 
            // qPortNameBox
            // 
            this.qPortNameBox.Location = new System.Drawing.Point(191, 154);
            this.qPortNameBox.Name = "qPortNameBox";
            this.qPortNameBox.Size = new System.Drawing.Size(192, 20);
            this.qPortNameBox.TabIndex = 11;
            this.qPortNameBox.Text = "shadow_q";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(117, 157);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(68, 13);
            this.label3.TabIndex = 12;
            this.label3.Text = "Q-Port Name";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(70, 24);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(115, 13);
            this.label4.TabIndex = 13;
            this.label4.Text = "Shadow Module Name";
            // 
            // shadowModuleNameBox
            // 
            this.shadowModuleNameBox.Location = new System.Drawing.Point(191, 21);
            this.shadowModuleNameBox.Name = "shadowModuleNameBox";
            this.shadowModuleNameBox.Size = new System.Drawing.Size(192, 20);
            this.shadowModuleNameBox.TabIndex = 14;
            this.shadowModuleNameBox.Text = "shadow_module";
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Location = new System.Drawing.Point(12, 12);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(443, 237);
            this.tabControl1.TabIndex = 15;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.appendixTextBox);
            this.tabPage1.Controls.Add(this.FileLoc);
            this.tabPage1.Controls.Add(this.owCheckBox);
            this.tabPage1.Controls.Add(this.ShadowFile);
            this.tabPage1.Controls.Add(this.label1);
            this.tabPage1.Controls.Add(this.Browse);
            this.tabPage1.Controls.Add(this.label2);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(435, 149);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "File Options";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.label9);
            this.tabPage2.Controls.Add(this.shadowDumpNameBox);
            this.tabPage2.Controls.Add(this.label8);
            this.tabPage2.Controls.Add(this.shadowCaptureNameBox);
            this.tabPage2.Controls.Add(this.label7);
            this.tabPage2.Controls.Add(this.label6);
            this.tabPage2.Controls.Add(this.label5);
            this.tabPage2.Controls.Add(this.resetNameBox);
            this.tabPage2.Controls.Add(this.clkNameBox);
            this.tabPage2.Controls.Add(this.dPortNameBox);
            this.tabPage2.Controls.Add(this.label3);
            this.tabPage2.Controls.Add(this.shadowModuleNameBox);
            this.tabPage2.Controls.Add(this.qPortNameBox);
            this.tabPage2.Controls.Add(this.label4);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(435, 211);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "Module Options";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(72, 183);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(108, 13);
            this.label9.TabIndex = 24;
            this.label9.Text = "Shadow Dump Name";
            // 
            // shadowDumpNameBox
            // 
            this.shadowDumpNameBox.Location = new System.Drawing.Point(191, 180);
            this.shadowDumpNameBox.Name = "shadowDumpNameBox";
            this.shadowDumpNameBox.Size = new System.Drawing.Size(192, 20);
            this.shadowDumpNameBox.TabIndex = 23;
            this.shadowDumpNameBox.Text = "s_dump";
            // 
            // label8
            // 
            this.label8.AutoSize = true;
            this.label8.Location = new System.Drawing.Point(72, 102);
            this.label8.Name = "label8";
            this.label8.Size = new System.Drawing.Size(113, 13);
            this.label8.TabIndex = 22;
            this.label8.Text = "Shadow Enable Name";
            // 
            // shadowCaptureNameBox
            // 
            this.shadowCaptureNameBox.Location = new System.Drawing.Point(191, 99);
            this.shadowCaptureNameBox.Name = "shadowCaptureNameBox";
            this.shadowCaptureNameBox.Size = new System.Drawing.Size(192, 20);
            this.shadowCaptureNameBox.TabIndex = 21;
            this.shadowCaptureNameBox.Text = "s_capture";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(119, 76);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(66, 13);
            this.label7.TabIndex = 20;
            this.label7.Text = "Reset Name";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(120, 50);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(65, 13);
            this.label6.TabIndex = 19;
            this.label6.Text = "Clock Name";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(117, 131);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(68, 13);
            this.label5.TabIndex = 18;
            this.label5.Text = "D-Port Name";
            // 
            // resetNameBox
            // 
            this.resetNameBox.Location = new System.Drawing.Point(191, 73);
            this.resetNameBox.Name = "resetNameBox";
            this.resetNameBox.Size = new System.Drawing.Size(192, 20);
            this.resetNameBox.TabIndex = 17;
            this.resetNameBox.Text = "rst";
            // 
            // clkNameBox
            // 
            this.clkNameBox.Location = new System.Drawing.Point(191, 47);
            this.clkNameBox.Name = "clkNameBox";
            this.clkNameBox.Size = new System.Drawing.Size(192, 20);
            this.clkNameBox.TabIndex = 16;
            this.clkNameBox.Text = "clk";
            // 
            // dPortNameBox
            // 
            this.dPortNameBox.Location = new System.Drawing.Point(191, 128);
            this.dPortNameBox.Name = "dPortNameBox";
            this.dPortNameBox.Size = new System.Drawing.Size(192, 20);
            this.dPortNameBox.TabIndex = 15;
            this.dPortNameBox.Text = "shadow_din";
            // 
            // moduleTreeView
            // 
            this.moduleTreeView.Location = new System.Drawing.Point(12, 265);
            this.moduleTreeView.Name = "moduleTreeView";
            this.moduleTreeView.Size = new System.Drawing.Size(439, 152);
            this.moduleTreeView.TabIndex = 16;
            // 
            // SubmoduleAddButton
            // 
            this.SubmoduleAddButton.Location = new System.Drawing.Point(372, 423);
            this.SubmoduleAddButton.Name = "SubmoduleAddButton";
            this.SubmoduleAddButton.Size = new System.Drawing.Size(75, 23);
            this.SubmoduleAddButton.TabIndex = 17;
            this.SubmoduleAddButton.Text = "Add Submodule";
            this.SubmoduleAddButton.UseVisualStyleBackColor = true;
            this.SubmoduleAddButton.Click += new System.EventHandler(this.SubmoduleAddButton_Click);
            // 
            // Form1
            // 
            this.BackColor = System.Drawing.SystemColors.Control;
            this.ClientSize = new System.Drawing.Size(467, 634);
            this.Controls.Add(this.SubmoduleAddButton);
            this.Controls.Add(this.moduleTreeView);
            this.Controls.Add(this.tabControl1);
            this.Controls.Add(this.logBox);
            this.Controls.Add(this.progressBar1);
            this.Name = "Form1";
            this.Text = "ShadowWriter";
            this.TransparencyKey = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.tabPage2.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        private void ShadowFile_Click(object sender, EventArgs e) {
            this.progressBar1.Value = 0;
            string fileLocation = this.FileLoc.Text;

            FileInfo fi;
            StreamReader sr;
            try {
                fi = new FileInfo(fileLocation);
                sr = fi.OpenText();
            } catch {
                MessageBox.Show("Error opening file '" + fileLocation + "'.", "ShadowWriter", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            string writeLocation = fileLocation.Insert(fileLocation.Length - 2, this.appendixTextBox.Text);
            if(File.Exists(writeLocation) && !this.owCheckBox.Checked){
                MessageBoxButtons btn = MessageBoxButtons.OKCancel;
                MessageBoxIcon icon = MessageBoxIcon.Warning;
                DialogResult result = MessageBox.Show("File '" + writeLocation + "' already exists, overwrite?", "ShadowWriter", btn, icon);
                
                switch(result){
                    case DialogResult.Cancel:
                        sr.Close();
                        return;
                    default:
                        break;//Continue
                }
            }
            StreamWriter sw = new StreamWriter(writeLocation);
            bool shadowSuccess = WriteShadowDffs(sw, sr);

            //Deal with failed shadow here<----------
            sr.Close();
            sw.Close();
            VerilogFile vf = new VerilogFile(fileLocation);
        }

        private bool WriteShadowDffs(StreamWriter sw, StreamReader sr) {
            string fileText;
            fileText = sr.ReadToEnd();
            StringTokenizer tok = new StringTokenizer(fileText);
            tok.IgnoreWhiteSpace = true;

            int totalDFFs = 0;
            List<DFFModule> dffs = new List<DFFModule>();
            List<Token> bkmrks = new List<Token>();

            while(true){
                Token currToken = tok.Next(); 
                if (currToken.Value == "module") {
                    bkmrks = DFFModule.ParseModuleHeader(tok);
                }
                if (currToken.Kind == TokenKind.EOF) break;
                if (currToken.Kind == TokenKind.EOL) {
                    while (currToken.Kind == TokenKind.EOL) {
                        currToken = tok.Next();
                    }
                    string currWord = currToken.Value;

                    if (currWord == "module") {
                        bkmrks = DFFModule.ParseModuleHeader(tok);
                    }

                    if (currWord.StartsWith("dff")) {
                        DFFModule dff = DFFModule.ParseDFF(tok);
                        totalDFFs += dff.numDFFs;
                        dffs.Add(dff);
                        progressBar1.PerformStep();
                    }
                }
            }

            logBox.Text += "Total DFFs Detected: " + dffs.Count() + "\r\n";
            logBox.Text += "Total DFF bits detected: " + totalDFFs + "\r\n";
            logBox.Text += "DFF Output Names:" + "\r\n";
            foreach (DFFModule dff in dffs) {
                logBox.Text += "\t" + dff.numDFFs + ":    " + dff.qName + "\r\n";
                progressBar1.PerformStep();
            }

            bool writeSuccess = WriteShadowFile(sw, fileText, bkmrks, dffs, totalDFFs);


            return writeSuccess;
        }

        private bool WriteShadowFile(StreamWriter sw, string fileText, List<Token> bookmarks, List<DFFModule> dffs, int totalDFFs) {
            sw.Write(fileText.Substring(0,bookmarks[0].Pos - 2));
            sw.WriteLine(",\r\n\t" + shadowCaptureNameBox.Text + ", //SHADOW_Q PORT");
            sw.WriteLine("\t" + qPortNameBox.Text + ", //SHADOW_Q PORT");
            sw.WriteLine("\t" + shadowDumpNameBox.Text + " //SHADOW DUMP PORT");

            sw.Write(fileText.Substring(bookmarks[0].Pos - 1, bookmarks[1].Pos - bookmarks[0].Pos - 1));

            sw.WriteLine("\r\n/**********SHADOW MODULE CODE INSERTION*********/");
            sw.WriteLine("input\t" + shadowCaptureNameBox.Text + "; //SHADOW CAPTURE DECLARATION");
            sw.WriteLine("input\t" + qPortNameBox.Text + "; //SHADOW_Q PORT DECLARATION");
            sw.WriteLine("output\t"+ shadowDumpNameBox.Text + "; //SHADOW DUMP DECLARATION");
            sw.WriteLine("wire [" + (totalDFFs - 1) + ":0]\t" + dPortNameBox.Text + " = { ");
            for (int i = 0; i < dffs.Count; i++) {
                sw.WriteLine("\t" + ((i == 0 || i == dffs.Count - 1) ? dffs[i].qName : (dffs[i].qName + ", ")));
            }
            sw.WriteLine("});\r\n");

            sw.WriteLine("shadow_capture  #(" + totalDFFs + ") " + shadowModuleNameBox.Text + "(" + clkNameBox.Text +", " + resetNameBox.Text + ", " + shadowCaptureNameBox.Text + ", " + dPortNameBox.Text + ", " + qPortNameBox.Text + ", " + shadowDumpNameBox.Text + ");");
            sw.WriteLine("/**********SHADOW MODULE CODE INSERTION*********/\r\n");

            sw.Write(fileText.Substring(bookmarks[1].Pos - 1));
            return true;
        }

        private void Browse_Click(object sender, EventArgs e) {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.FileName = "Derp.v";
            dlg.Filter = "Verilog Documents (.v)|*.v";
            dlg.ShowDialog();
            this.FileLoc.Text = dlg.FileName;
        }

        private void SubmoduleAddButton_Click(object sender, EventArgs e) {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.FileName = "Derp.v";
            dlg.Filter = "Verilog Documents (.v)|*.v";
            dlg.ShowDialog();
            VerilogFile newModule = new VerilogFile(dlg.FileName);
            VerilogTreeNode vTNode = (VerilogTreeNode)moduleTreeView.SelectedNode;
            if (vTNode != null) {
                vTNode.VFile.AddSubModule(newModule);
                vTNode.Nodes.Add(new VerilogTreeNode(newModule));
                vTNode.Refresh();
            } else {
                moduleTreeView.Nodes.Add(new VerilogTreeNode(newModule));
            }
        }
    }
}
