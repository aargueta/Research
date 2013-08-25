using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Windows.Forms;
using Ader.Text;

namespace ShadowSnapshot {
    public delegate void VerilogFileUpdate();

    class VerilogFile {
        private string filename;
        private string fileText;

        private string moduleName;

        private string shadowPort;
        private int shadowPortWidth;
        private List<int> shadowChains; //shadowChains.Length() = shadowPortWidth

        private List<VerilogFile> subModules;
        private List<DFFModule> dffs;
        private int numDffsTopModule; //Additional DFF bits at top module level
        private int totalDffBits;

        private List<Token> bkmrks; //Insertion locations for top module's shadow port
        private List<Token> subPortBkmrks; // Bookmarks for submodule shadow ports

        private FileInfo fi;
        private StreamReader sr;
        private StringTokenizer tok;

        private VerilogFileUpdate parentUpdater;

        public VerilogFile(string filename, List<VerilogFile> subModules = null) {
            this.filename = filename;
            try {
                fi = new FileInfo(filename);
                sr = fi.OpenText();
            } catch {
                MessageBox.Show("Error opening file '" + filename + "'.", "ShadowWriter", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            fileText = sr.ReadToEnd();
            tok = new StringTokenizer(fileText);
            tok.IgnoreWhiteSpace = true;

            this.shadowChains = new List<int>();
            this.subModules = (subModules == null) ? new List<VerilogFile>() : subModules;
            this.dffs = new List<DFFModule>();
            this.bkmrks = new List<Token>();
            this.subPortBkmrks = new List<Token>();

            ParseNewFile();
            foreach (VerilogFile submodule in this.subModules) {
                foreach (int chain in submodule.shadowChains) {


                    //////////////////////////////////////


                    //CONTINUE HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


                    /////////////////////////////////////



                }
                this.totalDffBits += submodule.NumDffBits;
            }
            this.totalDffBits += this.numDffsTopModule;
        }

        public void SetShadowModule(string portName, int portWidth) {
            this.shadowPort = portName;
            this.shadowPortWidth = portWidth;
        }

        public void AddSubModule(VerilogFile subModule) {
            this.subModules.Add(subModule);
            this.totalDffBits += subModule.NumDffBits;
            subModule.SetParentUpdater(new VerilogFileUpdate(Update));
            Update();
            if(this.parentUpdater != null)
                this.parentUpdater.Invoke();
        }

        public string Filename {
            get {
                return this.filename;
            }
        }

        public string FileText {
            get {
                return this.fileText;
            }
        }

        public string ModuleName {
            get {
                return this.moduleName;
            }
        }

        public List<DFFModule> Dffs {
            get {
                return this.dffs;
            }
        }

        public List<int> ShadowChains {
            get {
                return this.shadowChains;
            }
        }

        /// <summary>
        /// Bookmark #1: End of port list. Insert top level ports here.
        /// Bookmark #2: End of I/O declaration lists. Insert port declaration here along with module declaration.
        /// </summary>
        public List<Token> TopModuleBookmarks {
            get {
                return this.bkmrks;
            }
        }

        /// <summary>
        /// Returns the ends of the shadowed submodule I/O port lists. Insert shadow ports here.
        /// </summary>
        public List<Token> SubModuleBookmarks {
            get {
                return this.subPortBkmrks;
            }
        }

        public int NumDffBits {
            get {
                return this.totalDffBits;
            }
        }

        public void SetParentUpdater(VerilogFileUpdate updater) {
            this.parentUpdater = updater;
        }

        private void Update() {
            this.totalDffBits = this.numDffsTopModule;
            foreach (VerilogFile subMod in this.subModules) {
                this.totalDffBits += subMod.NumDffBits;
            }
        }

        private bool ParseNewFile() {
            if (this.sr == null)
                return false;
            while (true) {
                Token currToken = tok.Next(); 
                if (currToken.Value == "module") {
                    bkmrks = DFFModule.ParseModuleHeader(tok);
                    this.moduleName = bkmrks[0].Value;
                    bkmrks.RemoveAt(0);
                }
                if (currToken.Kind == TokenKind.EOF) break;
                if (currToken.Kind == TokenKind.EOL) {
                    while (currToken.Kind == TokenKind.EOL) {
                        currToken = tok.Next();
                    }

                    string currWord = currToken.Value;
                    if (currWord == "module") {
                        bkmrks = DFFModule.ParseModuleHeader(tok);
                        this.moduleName = bkmrks[0].Value;
                        bkmrks.RemoveAt(0);//Remove module name bookmark
                    } else if (currWord.StartsWith("dff")) {
                        DFFModule dff = DFFModule.ParseDFF(tok);
                        numDffsTopModule += dff.numDFFs;
                        dffs.Add(dff);
                    } else {
                        foreach (VerilogFile subModule in this.subModules) {
                            if (currWord == subModule.moduleName) {
                                subPortBkmrks.Add(ParseSubmodule(tok, subModule));
                            }
                        }
                    }
                }
            }
            return true;
        }

        private Token ParseSubmodule(StringTokenizer tok, VerilogFile submodule) {
            Token currToken = null;
            Token prevToken = new Token(TokenKind.Unknown, "", 0, 0, 0);
            while (true) {
                currToken = tok.Next();
                if (currToken.Kind == TokenKind.EOF)
                    return null;
                if (currToken.Value == ";" && prevToken.Value == ")")
                    return prevToken;
                prevToken = currToken;
            }
        }

        
    }
}
