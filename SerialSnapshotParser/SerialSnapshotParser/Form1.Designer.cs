namespace SerialSnapshotParser {
    partial class Form1 {
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
            this.sShot1Box1 = new System.Windows.Forms.TextBox();
            this.sShot1Box2 = new System.Windows.Forms.TextBox();
            this.portSelect = new System.Windows.Forms.ComboBox();
            this.snapShotSelect = new System.Windows.Forms.ComboBox();
            this.captureToggle = new System.Windows.Forms.CheckBox();
            this.diffChanges = new System.Windows.Forms.Button();
            this.baudSelect = new System.Windows.Forms.ComboBox();
            this.clearSnaps = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // sShot1Box1
            // 
            this.sShot1Box1.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.sShot1Box1.Location = new System.Drawing.Point(12, 12);
            this.sShot1Box1.Multiline = true;
            this.sShot1Box1.Name = "sShot1Box1";
            this.sShot1Box1.Size = new System.Drawing.Size(233, 508);
            this.sShot1Box1.TabIndex = 1;
            this.sShot1Box1.Click += new System.EventHandler(this.sShot1Box1_Click);
            // 
            // sShot1Box2
            // 
            this.sShot1Box2.Font = new System.Drawing.Font("Courier New", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.sShot1Box2.Location = new System.Drawing.Point(251, 12);
            this.sShot1Box2.Multiline = true;
            this.sShot1Box2.Name = "sShot1Box2";
            this.sShot1Box2.Size = new System.Drawing.Size(234, 507);
            this.sShot1Box2.TabIndex = 5;
            this.sShot1Box2.Click += new System.EventHandler(this.sShot1Box2_Click);
            // 
            // portSelect
            // 
            this.portSelect.FormattingEnabled = true;
            this.portSelect.Location = new System.Drawing.Point(91, 526);
            this.portSelect.Name = "portSelect";
            this.portSelect.Size = new System.Drawing.Size(121, 21);
            this.portSelect.TabIndex = 9;
            // 
            // snapShotSelect
            // 
            this.snapShotSelect.FormattingEnabled = true;
            this.snapShotSelect.Items.AddRange(new object[] {
            "First",
            "Second"});
            this.snapShotSelect.Location = new System.Drawing.Point(91, 562);
            this.snapShotSelect.Name = "snapShotSelect";
            this.snapShotSelect.Size = new System.Drawing.Size(121, 21);
            this.snapShotSelect.TabIndex = 11;
            // 
            // captureToggle
            // 
            this.captureToggle.AutoSize = true;
            this.captureToggle.Location = new System.Drawing.Point(12, 564);
            this.captureToggle.Name = "captureToggle";
            this.captureToggle.Size = new System.Drawing.Size(63, 17);
            this.captureToggle.TabIndex = 12;
            this.captureToggle.Text = "Capture";
            this.captureToggle.UseVisualStyleBackColor = true;
            this.captureToggle.CheckedChanged += new System.EventHandler(this.captureToggle_CheckedChanged);
            // 
            // diffChanges
            // 
            this.diffChanges.Location = new System.Drawing.Point(410, 558);
            this.diffChanges.Name = "diffChanges";
            this.diffChanges.Size = new System.Drawing.Size(75, 23);
            this.diffChanges.TabIndex = 13;
            this.diffChanges.Text = "Diff";
            this.diffChanges.UseVisualStyleBackColor = true;
            this.diffChanges.Click += new System.EventHandler(this.diffChanges_Click);
            // 
            // baudSelect
            // 
            this.baudSelect.FormattingEnabled = true;
            this.baudSelect.Items.AddRange(new object[] {
            "9600",
            "115200"});
            this.baudSelect.Location = new System.Drawing.Point(285, 525);
            this.baudSelect.Name = "baudSelect";
            this.baudSelect.Size = new System.Drawing.Size(121, 21);
            this.baudSelect.TabIndex = 14;
            // 
            // clearSnaps
            // 
            this.clearSnaps.Location = new System.Drawing.Point(313, 558);
            this.clearSnaps.Name = "clearSnaps";
            this.clearSnaps.Size = new System.Drawing.Size(75, 23);
            this.clearSnaps.TabIndex = 15;
            this.clearSnaps.Text = "Clear";
            this.clearSnaps.UseVisualStyleBackColor = true;
            this.clearSnaps.Click += new System.EventHandler(this.clearSnaps_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(497, 596);
            this.Controls.Add(this.clearSnaps);
            this.Controls.Add(this.baudSelect);
            this.Controls.Add(this.diffChanges);
            this.Controls.Add(this.captureToggle);
            this.Controls.Add(this.snapShotSelect);
            this.Controls.Add(this.portSelect);
            this.Controls.Add(this.sShot1Box2);
            this.Controls.Add(this.sShot1Box1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox sShot1Box1;
        private System.Windows.Forms.TextBox sShot1Box2;
        private System.Windows.Forms.ComboBox portSelect;
        private System.Windows.Forms.ComboBox snapShotSelect;
        private System.Windows.Forms.CheckBox captureToggle;
        private System.Windows.Forms.Button diffChanges;
        private System.Windows.Forms.ComboBox baudSelect;
        private System.Windows.Forms.Button clearSnaps;
    }
}

