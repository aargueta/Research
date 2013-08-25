using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace ShadowParser {
    /// <summary>
    /// Corresponds to a Verilog File, contains a list of any modules declared within that file.
    /// </summary>
    public class VerilogFile {
        private string filename;
        private Dictionary<string, VerilogModule> moduleDeclarations;

        public VerilogFile(string filename) {
            this.filename = filename;
            this.moduleDeclarations = new Dictionary<string, VerilogModule>();
        }

        public void AddDeclaration(VerilogModule declaration) {
            if (this.moduleDeclarations.ContainsKey(declaration.Name)) {
                if (this.moduleDeclarations[declaration.Name].Filename == declaration.Filename) {
                    // In this case, there are multiple instantiations of the same module within
                    // the same file, probably due to an IFDEF statement
                    StringBuilder sb = new StringBuilder("Multiple module insantiations found:");
                    sb.AppendLine("\tModule: " + declaration.Name);
                    sb.AppendLine("\tFile: " +declaration.Filename);
                    sb.AppendLine("\tOriginal @ Line:" + moduleDeclarations[declaration.Name].InOutListEnd.Line);
                    sb.AppendLine("\tNew @ Line:" + declaration.InOutListEnd.Line);
                    sb.AppendLine("Use new module instantiation?");
                    DialogResult dr = MessageBox.Show(sb.ToString(), "VFile Parser: Module Instance Conflict", MessageBoxButtons.YesNo);
                    if (dr == DialogResult.Yes) {
                        this.moduleDeclarations[declaration.Name] = declaration;
                    }
                } else {
                    // In this case, we are updating an old declaration, typically due to
                    // replacing PossibleInstances with VerilogModuleInstances
                    this.moduleDeclarations[declaration.Name] = declaration;
                }
            } else {
                this.moduleDeclarations.Add(declaration.Name, declaration);
            }
        }

        public string FileName {
            get { return this.filename; }
        }

        public Dictionary<string, VerilogModule> DeclaredModules {
            get { return this.moduleDeclarations; }
        }
    }
}
