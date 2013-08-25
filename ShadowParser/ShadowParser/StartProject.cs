using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace ShadowParser {
    public partial class StartProjectDialog : Form {
        private HomeScreen home;
        public StartProjectDialog(HomeScreen home) {
            this.home = home;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.StartProjectDialog_FormClosing);
            InitializeComponent();

            Properties.Settings settings = Properties.Settings.Default;
            this.projDirectoryBox.Text = settings.ProjectDirectory;
            this.projectNameBox.Text = settings.ProjectName;
        }

        private void startProjectButton_Click(object sender, EventArgs e) {
            home.projectNameBox.Text = this.projectNameBox.Text;
            Properties.Settings.Default.ProjectName = projectNameBox.Text;

            if (!Directory.Exists(projDirectoryBox.Text)) {
                Directory.CreateDirectory(projDirectoryBox.Text);
            }
            home.projectDirectory = projDirectoryBox.Text;
            Properties.Settings.Default.ProjectDirectory = projDirectoryBox.Text;

            if (clearPreviousFiles.Checked)
                Properties.Settings.Default.FilesToParse.Clear();
            Properties.Settings.Default.Save();

            this.Close();
        }

        public void StartProjectDialog_FormClosing(Object sender, FormClosingEventArgs e) {
            if (projectNameBox.Text == "") {
                DialogResult result = MessageBox.Show("Project name empty!", "Project Initialization Error", MessageBoxButtons.RetryCancel);
                if (result == DialogResult.Retry) {
                    e.Cancel = true;
                    return;
                } else {
                    this.home.closeNow = true;
                    return;
                }
            }
            if (!Directory.Exists(projDirectoryBox.Text)) {
                DialogResult result = MessageBox.Show("Project directory does not exist, create it?", "Project Initialization Error", MessageBoxButtons.OKCancel);
                if (result != DialogResult.Cancel) {
                    e.Cancel = true;
                    return;
                }
            }
        }

        private void projDirectoryBox_Click(object sender, EventArgs e) {
            FolderBrowserDialog dlg = new FolderBrowserDialog();
            if (dlg.ShowDialog() == DialogResult.Cancel)
                return;
            projDirectoryBox.Text = dlg.SelectedPath;
        }


    }
}
