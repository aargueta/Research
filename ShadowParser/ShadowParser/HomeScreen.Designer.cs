namespace ShadowParser {
    partial class HomeScreen {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing) {
            if (disposing && (components != null)) {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent() {
            this.moduleHeirarchyDisplay = new System.Windows.Forms.TreeView();
            this.addToLibraryButton = new System.Windows.Forms.Button();
            this.moduleLibraryDisplay = new System.Windows.Forms.ListBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label4 = new System.Windows.Forms.Label();
            this.numChainSelect = new System.Windows.Forms.NumericUpDown();
            this.importDffButton = new System.Windows.Forms.Button();
            this.dffLibraryLocationBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.dffLibraryDisplay = new System.Windows.Forms.ListBox();
            this.projectNameBox = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.designateRootButton = new System.Windows.Forms.Button();
            this.runInserterButton = new System.Windows.Forms.Button();
            this.importPrevious = new System.Windows.Forms.Button();
            this.saveSelection = new System.Windows.Forms.CheckBox();
            this.shadowSelect = new System.Windows.Forms.CheckBox();
            this.errorSelect = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numChainSelect)).BeginInit();
            this.SuspendLayout();
            // 
            // moduleHeirarchyDisplay
            // 
            this.moduleHeirarchyDisplay.Enabled = false;
            this.moduleHeirarchyDisplay.Location = new System.Drawing.Point(380, 206);
            this.moduleHeirarchyDisplay.Name = "moduleHeirarchyDisplay";
            this.moduleHeirarchyDisplay.Size = new System.Drawing.Size(260, 550);
            this.moduleHeirarchyDisplay.TabIndex = 0;
            // 
            // addToLibraryButton
            // 
            this.addToLibraryButton.Enabled = false;
            this.addToLibraryButton.Location = new System.Drawing.Point(277, 327);
            this.addToLibraryButton.Name = "addToLibraryButton";
            this.addToLibraryButton.Size = new System.Drawing.Size(98, 35);
            this.addToLibraryButton.TabIndex = 1;
            this.addToLibraryButton.Text = "Browse && Import File";
            this.addToLibraryButton.UseVisualStyleBackColor = true;
            this.addToLibraryButton.Click += new System.EventHandler(this.addToLibrary_Click);
            // 
            // moduleLibraryDisplay
            // 
            this.moduleLibraryDisplay.Enabled = false;
            this.moduleLibraryDisplay.FormattingEnabled = true;
            this.moduleLibraryDisplay.Location = new System.Drawing.Point(10, 206);
            this.moduleLibraryDisplay.Name = "moduleLibraryDisplay";
            this.moduleLibraryDisplay.Size = new System.Drawing.Size(260, 550);
            this.moduleLibraryDisplay.TabIndex = 2;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.numChainSelect);
            this.groupBox1.Controls.Add(this.importDffButton);
            this.groupBox1.Controls.Add(this.dffLibraryLocationBox);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.dffLibraryDisplay);
            this.groupBox1.Controls.Add(this.projectNameBox);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Location = new System.Drawing.Point(12, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(628, 188);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Project Settings";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(7, 98);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(90, 13);
            this.label4.TabIndex = 9;
            this.label4.Text = "Top Level Chains";
            // 
            // numChainSelect
            // 
            this.numChainSelect.Location = new System.Drawing.Point(10, 114);
            this.numChainSelect.Maximum = new decimal(new int[] {
            256,
            0,
            0,
            0});
            this.numChainSelect.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numChainSelect.Name = "numChainSelect";
            this.numChainSelect.Size = new System.Drawing.Size(71, 20);
            this.numChainSelect.TabIndex = 8;
            this.numChainSelect.Value = new decimal(new int[] {
            64,
            0,
            0,
            0});
            // 
            // importDffButton
            // 
            this.importDffButton.Location = new System.Drawing.Point(143, 73);
            this.importDffButton.Name = "importDffButton";
            this.importDffButton.Size = new System.Drawing.Size(75, 23);
            this.importDffButton.TabIndex = 7;
            this.importDffButton.Text = "Import";
            this.importDffButton.UseVisualStyleBackColor = true;
            this.importDffButton.Click += new System.EventHandler(this.importDffButton_Click);
            // 
            // dffLibraryLocationBox
            // 
            this.dffLibraryLocationBox.Location = new System.Drawing.Point(10, 75);
            this.dffLibraryLocationBox.Name = "dffLibraryLocationBox";
            this.dffLibraryLocationBox.Size = new System.Drawing.Size(127, 20);
            this.dffLibraryLocationBox.TabIndex = 5;
            this.dffLibraryLocationBox.Text = "D:\\Unrelated Junk\\Stanford\\Research\\OpenSPARCT1\\design\\sys\\iop\\common\\rtl\\swrvr_c" +
    "lib.v";
            this.dffLibraryLocationBox.Click += new System.EventHandler(this.dffLibraryLocationBox_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(6, 59);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(131, 13);
            this.label3.TabIndex = 4;
            this.label3.Text = "DFF Libary DeclarationFile";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(365, 16);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(58, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "DFF Libary";
            // 
            // dffLibraryDisplay
            // 
            this.dffLibraryDisplay.FormattingEnabled = true;
            this.dffLibraryDisplay.Location = new System.Drawing.Point(368, 33);
            this.dffLibraryDisplay.Name = "dffLibraryDisplay";
            this.dffLibraryDisplay.Size = new System.Drawing.Size(254, 147);
            this.dffLibraryDisplay.TabIndex = 2;
            // 
            // projectNameBox
            // 
            this.projectNameBox.Enabled = false;
            this.projectNameBox.Location = new System.Drawing.Point(10, 36);
            this.projectNameBox.Name = "projectNameBox";
            this.projectNameBox.Size = new System.Drawing.Size(127, 20);
            this.projectNameBox.TabIndex = 1;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(7, 20);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(74, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Project Name:";
            // 
            // designateRootButton
            // 
            this.designateRootButton.Enabled = false;
            this.designateRootButton.Location = new System.Drawing.Point(276, 403);
            this.designateRootButton.Name = "designateRootButton";
            this.designateRootButton.Size = new System.Drawing.Size(98, 26);
            this.designateRootButton.TabIndex = 4;
            this.designateRootButton.Text = "Designate Root";
            this.designateRootButton.UseVisualStyleBackColor = true;
            this.designateRootButton.Click += new System.EventHandler(this.designateRootButton_Click);
            // 
            // runInserterButton
            // 
            this.runInserterButton.Enabled = false;
            this.runInserterButton.Location = new System.Drawing.Point(276, 538);
            this.runInserterButton.Name = "runInserterButton";
            this.runInserterButton.Size = new System.Drawing.Size(98, 23);
            this.runInserterButton.TabIndex = 5;
            this.runInserterButton.Text = "Run Inserter!";
            this.runInserterButton.UseVisualStyleBackColor = true;
            this.runInserterButton.Click += new System.EventHandler(this.runInserterButton_Click);
            // 
            // importPrevious
            // 
            this.importPrevious.Enabled = false;
            this.importPrevious.Location = new System.Drawing.Point(276, 270);
            this.importPrevious.Name = "importPrevious";
            this.importPrevious.Size = new System.Drawing.Size(98, 37);
            this.importPrevious.TabIndex = 6;
            this.importPrevious.Text = "Import Previous Files";
            this.importPrevious.UseVisualStyleBackColor = true;
            this.importPrevious.Click += new System.EventHandler(this.importPrevious_Click);
            // 
            // saveSelection
            // 
            this.saveSelection.AutoSize = true;
            this.saveSelection.Checked = true;
            this.saveSelection.CheckState = System.Windows.Forms.CheckState.Checked;
            this.saveSelection.Location = new System.Drawing.Point(277, 368);
            this.saveSelection.Name = "saveSelection";
            this.saveSelection.Size = new System.Drawing.Size(98, 17);
            this.saveSelection.TabIndex = 7;
            this.saveSelection.Text = "Save Selection";
            this.saveSelection.UseVisualStyleBackColor = true;
            // 
            // shadowSelect
            // 
            this.shadowSelect.AutoSize = true;
            this.shadowSelect.Location = new System.Drawing.Point(277, 491);
            this.shadowSelect.Name = "shadowSelect";
            this.shadowSelect.Size = new System.Drawing.Size(65, 17);
            this.shadowSelect.TabIndex = 8;
            this.shadowSelect.Text = "Shadow";
            this.shadowSelect.UseVisualStyleBackColor = true;
            // 
            // errorSelect
            // 
            this.errorSelect.AutoSize = true;
            this.errorSelect.Checked = true;
            this.errorSelect.CheckState = System.Windows.Forms.CheckState.Checked;
            this.errorSelect.Location = new System.Drawing.Point(277, 515);
            this.errorSelect.Name = "errorSelect";
            this.errorSelect.Size = new System.Drawing.Size(82, 17);
            this.errorSelect.TabIndex = 9;
            this.errorSelect.Text = "Insert Errors";
            this.errorSelect.UseVisualStyleBackColor = true;
            // 
            // HomeScreen
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(652, 768);
            this.Controls.Add(this.errorSelect);
            this.Controls.Add(this.shadowSelect);
            this.Controls.Add(this.saveSelection);
            this.Controls.Add(this.importPrevious);
            this.Controls.Add(this.runInserterButton);
            this.Controls.Add(this.designateRootButton);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.moduleLibraryDisplay);
            this.Controls.Add(this.addToLibraryButton);
            this.Controls.Add(this.moduleHeirarchyDisplay);
            this.Name = "HomeScreen";
            this.Text = "ShadowParser";
            this.Load += new System.EventHandler(this.HomeScreen_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numChainSelect)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TreeView moduleHeirarchyDisplay;
        private System.Windows.Forms.Button addToLibraryButton;
        private System.Windows.Forms.ListBox moduleLibraryDisplay;
        private System.Windows.Forms.GroupBox groupBox1;
        public System.Windows.Forms.TextBox projectNameBox;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox dffLibraryDisplay;
        private System.Windows.Forms.Button importDffButton;
        private System.Windows.Forms.TextBox dffLibraryLocationBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button designateRootButton;
        private System.Windows.Forms.Button runInserterButton;
        private System.Windows.Forms.Button importPrevious;
        private System.Windows.Forms.CheckBox saveSelection;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.NumericUpDown numChainSelect;
        private System.Windows.Forms.CheckBox shadowSelect;
        private System.Windows.Forms.CheckBox errorSelect;
    }
}

