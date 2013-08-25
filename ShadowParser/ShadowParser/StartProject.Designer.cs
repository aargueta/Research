namespace ShadowParser {
    partial class StartProjectDialog {
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
            this.startProjectButton = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.projectNameBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.projDirectoryBox = new System.Windows.Forms.TextBox();
            this.clearPreviousFiles = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // startProjectButton
            // 
            this.startProjectButton.Location = new System.Drawing.Point(197, 12);
            this.startProjectButton.Name = "startProjectButton";
            this.startProjectButton.Size = new System.Drawing.Size(75, 23);
            this.startProjectButton.TabIndex = 8;
            this.startProjectButton.Text = "Start Project";
            this.startProjectButton.UseVisualStyleBackColor = true;
            this.startProjectButton.Click += new System.EventHandler(this.startProjectButton_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(14, 16);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(71, 13);
            this.label1.TabIndex = 7;
            this.label1.Text = "Project Name";
            // 
            // projectNameBox
            // 
            this.projectNameBox.Location = new System.Drawing.Point(91, 14);
            this.projectNameBox.Name = "projectNameBox";
            this.projectNameBox.Size = new System.Drawing.Size(100, 20);
            this.projectNameBox.TabIndex = 6;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(0, 43);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(85, 13);
            this.label2.TabIndex = 10;
            this.label2.Text = "Project Directory";
            // 
            // projDirectoryBox
            // 
            this.projDirectoryBox.Location = new System.Drawing.Point(91, 40);
            this.projDirectoryBox.Name = "projDirectoryBox";
            this.projDirectoryBox.Size = new System.Drawing.Size(100, 20);
            this.projDirectoryBox.TabIndex = 9;
            this.projDirectoryBox.Click += new System.EventHandler(this.projDirectoryBox_Click);
            // 
            // clearPreviousFiles
            // 
            this.clearPreviousFiles.AutoSize = true;
            this.clearPreviousFiles.Location = new System.Drawing.Point(13, 71);
            this.clearPreviousFiles.Name = "clearPreviousFiles";
            this.clearPreviousFiles.Size = new System.Drawing.Size(169, 17);
            this.clearPreviousFiles.TabIndex = 11;
            this.clearPreviousFiles.Text = "Clear Previously Imported Files";
            this.clearPreviousFiles.UseVisualStyleBackColor = true;
            // 
            // StartProjectDialog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(284, 152);
            this.Controls.Add(this.clearPreviousFiles);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.projDirectoryBox);
            this.Controls.Add(this.startProjectButton);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.projectNameBox);
            this.Name = "StartProjectDialog";
            this.Text = "StartProject";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button startProjectButton;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox projectNameBox;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox projDirectoryBox;
        private System.Windows.Forms.CheckBox clearPreviousFiles;
    }
}