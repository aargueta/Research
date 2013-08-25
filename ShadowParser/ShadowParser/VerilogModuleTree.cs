using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Collections;

namespace ShadowParser {
    class VerilogModuleTree : IEnumerable<VerilogModule> {
        private VerilogModule root;
        private HashSet<string> processedModules;
        private List<VerilogModule> heirarchy;
        private bool iterateDuplicates;
        public SnapshotKey SnapshotKey;

        public VerilogModuleTree(VerilogModule root) {
            this.root = root;
            this.processedModules = new HashSet<string>();
            this.heirarchy = new List<VerilogModule>();
            this.iterateDuplicates = false;
        }



        /// <summary>
        /// Determines whether subsequent instantiations of the same module type will be returned or not
        /// </summary>
        public bool IterateDuplicates {
            get { return this.iterateDuplicates; }
            set { this.iterateDuplicates = value; }
        }

        public VerilogModule Root {
            get { return this.root; }
        }

        /// <summary>
        /// After root has been designated, it creates an ordered list of the modules with respect to the heirarchy
        /// </summary>
        /// <param name="numTopChains">Number of chains out at the top level</param>
        /// <param name="iterateDuplicates">Determines whether subsequent instantiations of the same module type will be returned or not. Defaults to false.</param>
        public void PopulateHeirarchy(int numTopChains, bool? iterateDuplicates = null){
            if(iterateDuplicates.HasValue)
                this.iterateDuplicates = iterateDuplicates.Value;
            
            root.NumChainsOut = numTopChains;
            for(int i = 0; i < root.InstantiatedModules.Count; i++){
                PopulateHeirarchy(root.InstantiatedModules[i].Type, this.iterateDuplicates);
            }
            processedModules.Add(root.Name);
            heirarchy.Add(root);
        }

        public List<VerilogModule> FlattenedHeirarchy {
            get { return new List<VerilogModule>(this.heirarchy); }
        }

        private void PopulateHeirarchy(VerilogModule currNode, bool iterateDuplicates) {
            if (!processedModules.Contains(currNode.Name)) {
                foreach (VerilogModuleInstance inst in currNode.InstantiatedModules) {
                    PopulateHeirarchy(inst.Type, iterateDuplicates);
                }
                processedModules.Add(currNode.Name);
                heirarchy.Add(currNode);
            }
        }

        public IEnumerator<VerilogModule> GetEnumerator() {
            // SHOULD BE REMOVED? DEPRECATED
            if(root == null)
                yield return null;
            PopulateHeirarchy(1);
            foreach (VerilogModule module in heirarchy) {
                yield return module;
            }
        }

        IEnumerator IEnumerable.GetEnumerator() {
            return GetEnumerator();
        }

        public void GenerateHeirarchySnapshotKey() {
             this.SnapshotKey = this.root.GenerateSnapshotKey();
        }

    }
}
