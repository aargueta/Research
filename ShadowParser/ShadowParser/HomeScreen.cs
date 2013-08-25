using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;

namespace ShadowParser {
    public partial class HomeScreen : Form {
        private VerilogProject project;
        private VerilogFileParser parser;
        private ChangeInserter inserter;

        public bool closeNow;
        public string projectDirectory;
        public List<string> filesToParse;

        public HomeScreen() {
            this.closeNow = false;
            InitializeComponent();
            StartProjectDialog startDialog = new StartProjectDialog(this);
            startDialog.ShowDialog();
            if (closeNow) {
                //this.Close();
            } else {
                this.moduleLibraryDisplay.Enabled = true;
                this.moduleHeirarchyDisplay.Enabled = true;
            }
            this.project = new VerilogProject(this.projectNameBox.Text, projectDirectory);
            this.parser = new VerilogFileParser(this.project);
            this.project.Parser = this.parser;
            this.filesToParse = new List<string>();
        }

        private void addToLibrary_Click(object sender, EventArgs e) {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.Multiselect = true;
            dlg.Filter = "Verilog Documents|*.v";
            if (dlg.ShowDialog() == DialogResult.Cancel) {
                return;
            }
            if (saveSelection.Checked) {
                foreach (string origFileName in dlg.FileNames) {
                    filesToParse.Add(origFileName);
                }
                SaveFilesToLoad(filesToParse);
            }
            List<string> fileNames = CopyToDirectory(dlg.FileNames);
            LoadFiles(fileNames);
            this.designateRootButton.Enabled = true;
        }

        private void SaveFilesToLoad(List<string> fileNames) {
            XmlSerializer serializer = new XmlSerializer(typeof(List<string>));
            using (FileStream stream = File.OpenWrite(Path.Combine(this.projectDirectory, this.projectNameBox.Text + ".config"))) {
                serializer.Serialize(stream, fileNames);
            }
        }

        private List<string> ReadFilesToLoad() {
            List<string> fileNames = new List<string>();
            XmlSerializer serializer = new XmlSerializer(typeof(List<string>));
            using (FileStream stream = File.OpenRead(Path.Combine(this.projectDirectory, this.projectNameBox.Text + ".config"))) {
                List<string> filename = (List<string>)serializer.Deserialize(stream);
                fileNames.AddRange(filename);
            }
            return fileNames;
        }

        private void LoadFiles(List<string> fileNames) {
            foreach (string fileName in fileNames) {
                VerilogFile vFile = this.parser.Parse(fileName);
                this.project.AddModulesToLibrary(vFile.DeclaredModules);
            }

            this.moduleLibraryDisplay.Items.Clear();
            List<VerilogModule> modules = project.GetModuleList();
            foreach (VerilogModule module in modules) {
                this.moduleLibraryDisplay.Items.Add(module);
            }
        }

        /// <summary>
        /// Copies original files to working directory and returns the copied file paths
        /// </summary>
        /// <param name="filePaths"></param>
        /// <returns>Copied file paths</returns>
        private List<string> CopyToDirectory(string[] filePaths) {
            List<string> copiedFilePaths = new List<string>();
            foreach (string filePath in filePaths) {
                string copiedFilePath = Path.Combine(this.projectDirectory,Path.GetFileName(filePath));
                if(filePath != copiedFilePath)
                    File.Copy(filePath, copiedFilePath, true);
                copiedFilePaths.Add(copiedFilePath);
            }
            return copiedFilePaths;
        }

        private void dffLibraryLocationBox_Click(object sender, EventArgs e) {
            OpenFileDialog dlg = new OpenFileDialog();
            dlg.FileName = "";
            dlg.Filter = "Verilog Documents|*.v";
            if (dlg.ShowDialog() == DialogResult.Cancel) {
                return;
            }
            this.dffLibraryLocationBox.Text = dlg.FileName;
        }

        private void importDffButton_Click(object sender, EventArgs e) {
            if (!File.Exists(dffLibraryLocationBox.Text)) {
                MessageBox.Show("File does not exist.");
                return;
            }
            this.parser.ParseDFFLibrary(dffLibraryLocationBox.Text);
            List<DFFModule> dffs = project.GetDffList();
            foreach (DFFModule dff in dffs) {
                this.dffLibraryDisplay.Items.Add(dff.typeName);
            }
            if(File.Exists(Path.Combine(this.projectDirectory, this.projectNameBox.Text + ".config"))){
                this.importPrevious.Enabled = true;
            }
            this.addToLibraryButton.Enabled = true;
        }

        private void HomeScreen_Load(object sender, EventArgs e) {
            if (closeNow)
                this.Close();
        }

        private void designateRootButton_Click(object sender, EventArgs e) {
            if (this.moduleLibraryDisplay.SelectedItem != null) {
                project.DisplayModuleHeirarchy(this.moduleHeirarchyDisplay, (VerilogModule)this.moduleLibraryDisplay.SelectedItem);
                inserter = new ChangeInserter(project, new VerilogModuleTree((VerilogModule)this.moduleLibraryDisplay.SelectedItem));
            }
            this.runInserterButton.Enabled = true;
        }

        private void runInserterButton_Click(object sender, EventArgs e) {
            if (inserter == null) {
                MessageBox.Show("Designate root first.","ShadowParser", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            ChangeInserter.InserterMode mode;
            if(this.errorSelect.Checked){
                if(this.shadowSelect.Checked){
                    mode = ChangeInserter.InserterMode.Both;
                }else{
                    mode = ChangeInserter.InserterMode.Error;
                }
            }else{
                if(this.shadowSelect.Checked){
                    mode = ChangeInserter.InserterMode.Shadow;
                }else{
                    MessageBox.Show("Select changes to insert!");
                    return;
                }
            }
            inserter.InsertChanges(mode, Convert.ToInt32(numChainSelect.Value));
            MessageBox.Show("Insertion complete.", "ShadowParser", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void importPrevious_Click(object sender, EventArgs e) {
            filesToParse.Clear();
            filesToParse = ReadFilesToLoad();
            CopyToDirectory(filesToParse.ToArray());
            LoadFiles(filesToParse);
            this.designateRootButton.Enabled = true;
        }
    }
}
