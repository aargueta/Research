using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;
using System.Data;

namespace ShadowParser {
    /// <summary>
    /// Corresponds to a Verilog module declaration
    /// </summary>
    public class VerilogModule {
        private string fileName;
        private string moduleName;
        private Dictionary<string, int> parameters;
        private Token inOutListEnd; // Marks the end of the input and output list (so that an output can be added for shadow chains)
        private Token postHeader; //Marks right after the input/output list and header (so that wires can be instantiated here)
        private Token prevEndModule; // Marks right before the end of the module (so that the shadow module can be instantiated in there)
        private List<string> inPorts;
        private List<string> outPorts;
        private List<string> inoutPorts;

        private int numChainsOut;
        private int numChainsIn;

        private List<DffInstance> localDffs;
        private List<VerilogModuleInstance> moduleInstances;
        private Dictionary<string, List<PossibleInstance>> possibleInstances;

        public SnapshotKeyGenerator keyGen;

        public VerilogModule(string filename, string name, List<string> inPorts = null, List<string> outPorts = null, List<string> inoutPorts = null) {
            this.fileName = filename;
            this.moduleName = name;
            this.parameters = new Dictionary<string,int>();
            this.inPorts = (inPorts == null)? inPorts : new List<string>();
            this.outPorts = (outPorts == null) ? outPorts : new List<string>(); ;
            this.inoutPorts = (inoutPorts == null) ? inoutPorts : new List<string>();
            this.localDffs = new List<DffInstance>();
            this.moduleInstances = new List<VerilogModuleInstance>();
            this.possibleInstances = new Dictionary<string, List<PossibleInstance>>();
            this.numChainsOut = 0;
            this.numChainsIn = 0;
        }

        public string Filename {
            get { return this.fileName; }
        }

        public string Name {
            get { return this.moduleName; }
        }

        public Dictionary<string, int> Parameters {
            get { return this.parameters; }
        }

        /// <summary>
        /// Marks the end of the input and output list
        /// </summary>
        public Token InOutListEnd {
            get { return this.inOutListEnd; }
            set { this.inOutListEnd = value; }
        }

        /// <summary>
        /// Marks right after the input/output list and module header
        /// </summary>
        public Token PostHeader {
            get { return this.postHeader; }
            set { this.postHeader = value; }
        }

        /// <summary>
        /// Marks right before the end of the module declaration
        /// </summary>
        public Token PrevEndModule {
            get { return this.prevEndModule; }
            set { this.prevEndModule = value; }
        }

        public List<string> Inputs {
            get { return this.inPorts; }
        }

        public List<string> Outputs {
            get { return this.outPorts; }
        }

        public List<string> Inouts {
            get { return this.inoutPorts; }
        }

        public List<VerilogModuleInstance> InstantiatedModules {
            get { return this.moduleInstances; }
        }

        public List<DffInstance> LocalDffs {
            get { return this.localDffs; }
        }

        public int NumLocalDffs {
            get { return this.localDffs.Count; }
        }

        public int NumTotalDffs {
            get {
                int numDffs = NumLocalDffs;
                foreach (VerilogModuleInstance inst in moduleInstances) {
                    numDffs += inst.Type.NumTotalDffs;
                }
                return numDffs;
            }
        }

        public int NumLocalDffBits {
            get {
                int numBits = 0;
                for(int i = 0; i < localDffs.Count; i++){
                    numBits += localDffs[i].Size;
                }
                return numBits;
            }
        }

        public int NumTotalDffBits {
            get {
                int numBits = NumLocalDffBits;
                foreach (VerilogModuleInstance inst in moduleInstances) {
                    numBits += inst.Type.NumTotalDffBits;
                }
                return numBits;
            }
        }

        public int ErrorControlWidth {
            get {
                if (this.NumTotalDffs < 2)
                    return this.NumTotalDffs;
                return Convert.ToInt32(Math.Ceiling(Math.Log(this.NumTotalDffs, 2))); 
            }
        }

        public Dictionary<string, List<PossibleInstance>> PossibleInstances {
            get { return this.possibleInstances; }
        }

        public VerilogModuleInstance Instantiate(VerilogModule parent, string name, Token inoutListEnd) {
            return new VerilogModuleInstance(parent, this, name, inoutListEnd);
        }

        public void AddDffInstance(DffInstance dff) {
            if(dff.IsParameterized){
                if (parameters.ContainsKey(dff.Parameter)) {
                    dff.Size = parameters[dff.Parameter];
                } else {
                    try {
                        dff.Size = EvaluateComplexParam(dff.Parameter);
                    } catch {
                        // ABORT EVALUATION: assign default width
                        dff.Size = 1;
                        //throw new Exception("The string '" + dff.Parameter + "' could not be interpreted to a defined parameter.");
                    }
                }
            }
            this.localDffs.Add(dff);
        }

        private int EvaluateComplexParam(string complexParameter) {
            string cmpParam = complexParameter;
            foreach (string param in parameters.Keys) {
                if (complexParameter.Contains(param)) {
                    string paramVal = parameters[param].ToString();
                    cmpParam = cmpParam.Replace(param, paramVal);
                }
            }
            object val = new DataTable().Compute(cmpParam, string.Empty);
            int intVal = 0;
            double doubleVal = 0.0;
            if (Int32.TryParse(val.ToString(), out intVal)) {
                //Yay it's an int
            } else if(Double.TryParse(val.ToString(), out doubleVal)){
                //It's a double
                intVal = Convert.ToInt32(doubleVal);
            }
            return intVal;
        }

        /// <summary>
        /// Adds ModuleInstance to the parent's definition. Also, if a definition to a PossibleInstance is found, 
        /// the PossibleInstance is removed and replaced with the ModuleInstance provided.
        /// </summary>
        /// <param name="module"></param>
        public void AddModuleInstance(VerilogModuleInstance module) {
            if (this.possibleInstances.ContainsKey(module.Type.Name)){
                List<PossibleInstance> lpi = this.possibleInstances[module.Type.Name];
                for (int i = 0; i < lpi.Count; i++ ) {
                    PossibleInstance pi = lpi[i];
                    if (pi.InstanceName == module.InstanceName) {
                        this.possibleInstances[module.Type.Name].Remove(pi);
                        break;
                    }
                }
                if (this.possibleInstances[module.Type.Name].Count == 0)
                    this.possibleInstances.Remove(module.Type.Name);
            }

            this.moduleInstances.Add(module);
        }

        /// <summary>
        /// Replaces all PossibleInstances with real instances of the VerilogModule type.
        /// Used after the type has been found.
        /// </summary>
        /// <param name="vMod"></param>
        public void ReplacePossibleInstances(VerilogModule vMod) {
            if (!this.possibleInstances.ContainsKey(vMod.Name))
                return;
            List<PossibleInstance> lpi = this.possibleInstances[vMod.Name];
            foreach (PossibleInstance pInst in lpi) {
                VerilogModuleInstance vmi = new VerilogModuleInstance(pInst.ParentModule, vMod, pInst.InstanceName, pInst.InOutListEnd);
                vmi.Parameterized = pInst.paramsExist;
                vmi.ParametersNamed = pInst.paramsNamed;
                vmi.ParameterList = pInst.paramList;
                this.moduleInstances.Add(vmi);
            }
            this.possibleInstances.Remove(vMod.Name);
        }

        public void AddPossibleInstance(Token bookmark, string instanceName, Token inOutListEnd, bool paramsExist, bool paramsNamed, Token paramList) {
            if (this.possibleInstances.ContainsKey(bookmark.Value)) {
                this.possibleInstances[bookmark.Value].Add(new PossibleInstance(bookmark.Value, instanceName, this, bookmark, inOutListEnd, paramsExist, paramsNamed, paramList));
            } else {
                List<PossibleInstance> tempList = new List<PossibleInstance>();
                tempList.Add(new PossibleInstance(bookmark.Value, instanceName, this, bookmark, inOutListEnd, paramsExist, paramsNamed, paramList));
                this.possibleInstances.Add(bookmark.Value, tempList);
            }
        }

        public void AssignLocalErrorIds() {
            int lclErrId = this.localDffs.Count;
            foreach (VerilogModuleInstance vmi in this.moduleInstances) {
                vmi.SetLocalErrorIds(lclErrId, lclErrId + vmi.Type.NumTotalDffs - 1);
                lclErrId += vmi.Type.NumTotalDffs;
            }
        }

        public int NumChainsOut {
            get { return numChainsOut; } 
            set {
                numChainsOut = value;
                numChainsIn = 0;
                if (value == 0)
                    return;
                int cachedTotalDffBits = this.NumTotalDffBits - this.NumLocalDffBits;
                if (cachedTotalDffBits == 0)
                    return;
                foreach (VerilogModuleInstance inst in moduleInstances) {
                    inst.Type.NumChainsOut = Convert.ToInt32(Math.Ceiling((double)value * (double)inst.Type.NumTotalDffBits / (double)cachedTotalDffBits));
                    this.numChainsIn += inst.Type.NumChainsOut;
                }
            }
        }

        public int NumChainsIn {
            get { return this.numChainsIn; }
        }

        public override string ToString() {
            return (this.Name + "\t{LD:" + this.localDffs.Count + "| S:" + this.moduleInstances.Count + "| TD:" + this.NumTotalDffs + "}");
        }

        public SnapshotKey GenerateSnapshotKey() {
            return GenerateSnapshotKey("//" + this.Name);
        }

        public SnapshotKey GenerateSnapshotKey(String instanceName) {
            this.keyGen = new SnapshotKeyGenerator(this);
            return this.keyGen.Generate(instanceName);
        }
    }
}
