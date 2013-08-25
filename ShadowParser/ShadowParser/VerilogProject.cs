using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;
using System.Windows.Forms;

namespace ShadowParser {
    /// <summary>
    /// Top module overall, contains definitions of all modules contained within, acts as a library for those modules.
    /// </summary>
    class VerilogProject {
        private string projectName;
        private string projectDirectory;
        private VerilogFileParser parser;
        private Dictionary<string, VerilogModule> moduleLibrary;
        private Dictionary<string, DFFModule> dffLibrary;
        private HashSet<string> keywordLibrary;
        private Dictionary<string, List<PossibleInstance>> possibleInstancesLibrary;

        public VerilogProject(string projectName, string projectDirectory) {
            this.projectName = projectName;
            this.projectDirectory = projectDirectory;
            this.moduleLibrary = new Dictionary<string, VerilogModule>();
            this.dffLibrary = new Dictionary<string, DFFModule>();
            this.keywordLibrary = new HashSet<string>();
            this.possibleInstancesLibrary = new Dictionary<string, List<PossibleInstance>>();
            PopulateKeywordLibrary();
        }

        public VerilogFileParser Parser {
            set { this.parser = value; }
        }

        private void PopulateKeywordLibrary() {
            string[] keywords = VerilogKeywords.Default.keywords.Split('\n');
            foreach (string keyword in keywords) {
                keywordLibrary.Add(keyword.TrimEnd('\r'));
            }
        }

        public void AddModuleToLibrary(VerilogModule module) {
            this.moduleLibrary.Add(module.Name, module);
        }

        public void AddModulesToLibrary(Dictionary<string, VerilogModule> modules) {
            foreach (KeyValuePair<string, VerilogModule> kvp in modules) {
                if (!this.moduleLibrary.ContainsKey(kvp.Key)) {
                    // Extract Module from dictionary and add to library
                    VerilogModule vMod = kvp.Value;
                    this.moduleLibrary.Add(vMod.Name, vMod);

                    // Add possible instances contained in the module to the library
                    foreach (KeyValuePair<string, List<PossibleInstance>> kvpLPI in vMod.PossibleInstances) {
                        foreach (PossibleInstance pi in kvpLPI.Value) {
                            if (!this.possibleInstancesLibrary.ContainsKey(pi.TypeName)) {
                                //If it's the first possible instance of its type, create a new list before adding the PossibleInstance to it
                                possibleInstancesLibrary.Add(pi.TypeName, new List<PossibleInstance>());
                            }
                            // Already other possible instances of the same type, add pi to list of instances
                            possibleInstancesLibrary[pi.TypeName].Add(pi);
                        }

                        // Check if any possibleInstances are defined by this module
                        if (this.possibleInstancesLibrary.ContainsKey(vMod.Name)) {
                            // If so, replace PossibleInstances with VerilogModuleInstances
                            List<PossibleInstance> piList = possibleInstancesLibrary[vMod.Name];
                            for (int i = 0; i < piList.Count; i++) {
                                PossibleInstance pi = piList[i];
                                StringTokenizer tknzr = StringTokenizer.TokenizerFromFile(pi.Filename, pi.Bookmark);
                                VerilogModuleInstance vmi = parser.ParseModuleInstance(pi.ParentModule, tknzr, pi.Bookmark,  vMod);
                                pi.ParentModule.AddModuleInstance(vmi);
                                //this.AddModulesToLibrary(this.parser.Reparse(piList[i]).DeclaredModules);
                                piList.RemoveAt(i);
                                if (piList.Count == 0)
                                    possibleInstancesLibrary.Remove(vMod.Name);
                            }
                        }
                    }
                } else {
                    // Reparsing: updating VerilogModule definitions to contain more module instantiations
                    this.moduleLibrary[kvp.Key] = kvp.Value;
                }
                
            }
        }

        public void AddDffToLibrary(DFFModule dffType) {
            this.dffLibrary.Add(dffType.typeName, dffType);
        }

        public bool IsModule(string tokenValue) {
            return this.moduleLibrary.ContainsKey(tokenValue);
        }

        public bool IsDff(string tokenValue) {
            return this.dffLibrary.ContainsKey(tokenValue);
        }

        public bool IsKeyword(string tokenValue) {
            return this.keywordLibrary.Contains(tokenValue);
        }

        public VerilogModule GetModule(string moduleName) {
            VerilogModule vMod = null;
            this.moduleLibrary.TryGetValue(moduleName, out vMod);
            return vMod;
        }

        public DFFModule GetDffType(string dffTypeName) {
            DFFModule dff;
            this.dffLibrary.TryGetValue(dffTypeName, out dff);
            return dff;
        }

        public List<VerilogModule> GetModuleList() {
            List<VerilogModule> modules = new List<VerilogModule>();
            foreach (KeyValuePair<string, VerilogModule> pair in this.moduleLibrary) {
                modules.Add(pair.Value);
            }
            return modules;
        }

        public List<DFFModule> GetDffList() {
            List<DFFModule> dffs = new List<DFFModule>();
            foreach (KeyValuePair<string, DFFModule> pair in this.dffLibrary) {
                dffs.Add(pair.Value);
            }
            return dffs;
        }

        public void DisplayModuleHeirarchy(TreeView display, VerilogModule root) {
            display.Nodes.Clear();
            VerilogModuleTreeNode rootNode = new VerilogModuleTreeNode(root);
            display.Nodes.Add(rootNode);
            CheckPossibleInstantiations(root);
            root.AssignLocalErrorIds();
            foreach(VerilogModuleInstance vmi in root.InstantiatedModules){
                PopulateDisplayHeirarchy(display.Nodes[0], vmi.Type);
            }
        }

        private void PopulateDisplayHeirarchy(TreeNode parent, VerilogModule module) {
            TreeNode moduleNode = new TreeNode(module.Name);
            parent.Nodes.Add(moduleNode);
            CheckPossibleInstantiations(module);
            module.AssignLocalErrorIds();
            foreach (VerilogModuleInstance vmi in module.InstantiatedModules) {
                PopulateDisplayHeirarchy(parent.Nodes[parent.Nodes.IndexOf(moduleNode)], vmi.Type);
            }
        }

        private void CheckPossibleInstantiations(VerilogModule vMod) {
            Dictionary<string, List<PossibleInstance>> tempInsts = new Dictionary<string, List<PossibleInstance>>(vMod.PossibleInstances);
            foreach (KeyValuePair<string, List<PossibleInstance>> piEntry in tempInsts) {
                string pInstName = piEntry.Key;
                if (IsModule(pInstName)) {
                    vMod.ReplacePossibleInstances(GetModule(pInstName));
                }
            }
        }

        public string GetWorkingCopyPath(VerilogModule vMod) {
            return System.IO.Path.Combine(projectDirectory, System.IO.Path.GetFileName(vMod.Filename));
        }

        public String Name {
            get { return this.projectName; }
        }

        public String Directory {
            get { return this.projectDirectory; }
        }
    }

    public struct DFFModule {
        public string typeName;
        public string clk;
        public string dPort;
        public string qPort;

        public DFFModule(string typeName, string clk, string d, string q) {
            this.typeName = typeName;
            this.clk = clk;
            this.dPort = d;
            this.qPort = q;
        }

        public override string ToString() {
            return this.typeName;
        }
    }
}
