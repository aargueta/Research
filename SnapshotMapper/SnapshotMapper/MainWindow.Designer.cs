namespace SnapshotMapper {
    partial class MainWindow {
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
            this.snapKeyUrl = new System.Windows.Forms.TextBox();
            this.browseSnapKey = new System.Windows.Forms.Button();
            this.browseRadDump = new System.Windows.Forms.Button();
            this.rawDumpUrl = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.mapDump = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // snapKeyUrl
            // 
            this.snapKeyUrl.Location = new System.Drawing.Point(19, 39);
            this.snapKeyUrl.Name = "snapKeyUrl";
            this.snapKeyUrl.Size = new System.Drawing.Size(174, 20);
            this.snapKeyUrl.TabIndex = 0;
            // 
            // browseSnapKey
            // 
            this.browseSnapKey.Location = new System.Drawing.Point(223, 37);
            this.browseSnapKey.Name = "browseSnapKey";
            this.browseSnapKey.Size = new System.Drawing.Size(75, 23);
            this.browseSnapKey.TabIndex = 1;
            this.browseSnapKey.Text = "Browse";
            this.browseSnapKey.UseVisualStyleBackColor = true;
            this.browseSnapKey.Click += new System.EventHandler(this.browseSnapKey_Click);
            // 
            // browseRadDump
            // 
            this.browseRadDump.Location = new System.Drawing.Point(223, 76);
            this.browseRadDump.Name = "browseRadDump";
            this.browseRadDump.Size = new System.Drawing.Size(75, 23);
            this.browseRadDump.TabIndex = 3;
            this.browseRadDump.Text = "Browse";
            this.browseRadDump.UseVisualStyleBackColor = true;
            this.browseRadDump.Click += new System.EventHandler(this.browseRadDump_Click);
            // 
            // rawDumpUrl
            // 
            this.rawDumpUrl.Location = new System.Drawing.Point(19, 78);
            this.rawDumpUrl.Name = "rawDumpUrl";
            this.rawDumpUrl.Size = new System.Drawing.Size(174, 20);
            this.rawDumpUrl.TabIndex = 2;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(16, 23);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(69, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "SnapKey File";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(16, 62);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(79, 13);
            this.label2.TabIndex = 5;
            this.label2.Text = "Raw Dump File";
            // 
            // mapDump
            // 
            this.mapDump.Location = new System.Drawing.Point(19, 116);
            this.mapDump.Name = "mapDump";
            this.mapDump.Size = new System.Drawing.Size(75, 23);
            this.mapDump.TabIndex = 6;
            this.mapDump.Text = "Map Dump";
            this.mapDump.UseVisualStyleBackColor = true;
            this.mapDump.Click += new System.EventHandler(this.mapDump_Click);
            // 
            // MainWindow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(312, 160);
            this.Controls.Add(this.mapDump);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.browseRadDump);
            this.Controls.Add(this.rawDumpUrl);
            this.Controls.Add(this.browseSnapKey);
            this.Controls.Add(this.snapKeyUrl);
            this.Name = "MainWindow";
            this.Text = "Snapshot Mapper";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox snapKeyUrl;
        private System.Windows.Forms.Button browseSnapKey;
        private System.Windows.Forms.Button browseRadDump;
        private System.Windows.Forms.TextBox rawDumpUrl;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button mapDump;
    }
}

