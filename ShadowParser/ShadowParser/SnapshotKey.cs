using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ShadowParser {
    public class SnapshotKeyGenerator {
        private int numChainsIn;
        private int numChainsOut;
        private int numDffBits;
        private List<DffInstance> localDffs;
        private VerilogModule vMod;

        public SnapshotKeyGenerator(VerilogModule vMod){
            this.vMod = vMod;
            this.numChainsIn = vMod.NumChainsIn;
            this.numChainsOut = vMod.NumChainsOut;
            this.numDffBits = vMod.NumLocalDffBits;
            this.localDffs = vMod.LocalDffs;
        }

        public SnapshotKey Generate() {
            return Generate("//");
        }

        public SnapshotKey Generate(String instanceName){
            Dictionary<int, SnapshotKey.ChainKey> key = new Dictionary<int, SnapshotKey.ChainKey>();
            if (this.numChainsOut == 0)
                return new SnapshotKey(key, 0, 0);
            int chainLength = (this.numDffBits / this.numChainsOut);
            int extraBits = this.numDffBits - chainLength * this.numChainsOut;
            for (int i = 0; i < this.numDffBits; i++) {
                bool extraBit = i >= numDffBits - extraBits;
                int chain = extraBit ? numChainsOut - 1 : i / chainLength;
                int cycle = i - chain * chainLength;
                if (!key.ContainsKey(chain)) {
                    key.Add(chain, new SnapshotKey.ChainKey(extraBit ? chainLength + extraBits : chainLength));
                }
                key[chain][cycle] = GetBitEntry(instanceName, i);
            }
            SnapshotKey snapshotKey = new SnapshotKey(key, this.numChainsOut, chainLength + extraBits);
            List<SnapshotKey> childKeys = new List<SnapshotKey>();
            for(int i = 0; i < vMod.InstantiatedModules.Count; i++){
                VerilogModuleInstance vmi = vMod.InstantiatedModules[i];
                childKeys.Add(vmi.Type.GenerateSnapshotKey(instanceName + "/" + vmi.InstanceName));
            }
            snapshotKey.AppendChildKeys(childKeys);
            return snapshotKey;
        }

        private DffBitRecord GetBitEntry(String instanceName, int bitIndex) {
            int bitCount = 0;
            for (int i = 0; i < localDffs.Count; i++) {
                bitCount += localDffs[i].Size;
                if ((bitIndex + 1)<= bitCount) {
                    int dffBitIndex = localDffs[i].Size - (bitCount - bitIndex);
                    if (localDffs[i].Size == 1 && dffBitIndex > 0)
                        dffBitIndex = 0;
                    return new DffBitRecord(instanceName + "/" + localDffs[i].InstanceName, localDffs[i].Size, dffBitIndex);
                }
            }
            return new DffBitRecord("[INVALID]", 0, 0);
        }




    }
    public class SnapshotKey {
        private Dictionary<int, ChainKey> key;
        private int numChains;
        private int maxChainLength;

        public SnapshotKey(Dictionary<int, ChainKey> key, int numChains, int maxChainLength) {
            this.key = key;
            this.numChains = numChains;
            this.maxChainLength = maxChainLength;
        }

        public void AppendChildKeys(List<SnapshotKey> children) {
            List<ChainKey> childChains = new List<ChainKey>();
            for (int i = 0; i < children.Count; i++) { // Order all children in a single list
                for (int j = 0; j < children[i].NumChains; j++) {
                    childChains.Add(children[i].GetChain(j));
                }
            }
            int tempMaxLength = 0;
            int parentChainNum = 0;
            for (int i = 0; i < childChains.Count; i++) { // Add children chains in order
                if (!this.key.ContainsKey(parentChainNum))
                    this.key.Add(parentChainNum, new ChainKey(0));
                this.key[parentChainNum].AppendChain(childChains[i], this.maxChainLength);
                parentChainNum = (parentChainNum + 1) % this.numChains;
                if (tempMaxLength < childChains[i].Length)
                    tempMaxLength = childChains[i].Length;
                if (parentChainNum == 0) {
                    this.maxChainLength += tempMaxLength;
                    tempMaxLength = 0;
                }
            }
        }

        public String GetBitId(int chain, int cycle) {
            return this.key[chain][cycle].Name + "[" + this.key[chain][cycle].BitNum + "]";
        }

        public ChainKey GetChain(int chainIndex) {
            return this.key[chainIndex];
        }

        public int NumChains {
            get { return this.numChains; }
        }

        public int Length {
            get { return this.maxChainLength; }
        }

        public List<KeyValuePair<int, List<DffBitRecord>>> Export() {
            List<KeyValuePair<int, List<DffBitRecord>>> exportKey = new List<KeyValuePair<int, List<DffBitRecord>>>();
            foreach (KeyValuePair<int, ChainKey> chainKeyEntry in this.key) {
                exportKey.Add(new KeyValuePair<int, List<DffBitRecord>>(chainKeyEntry.Key, chainKeyEntry.Value.Export()));
            }
            return exportKey;
        }

        public List<List<DffBitRecord>> RotateExport() {
            List<KeyValuePair<int, List<DffBitRecord>>> exportKey = this.Export();
            List<List<DffBitRecord>> rotateKey = new List<List<DffBitRecord>>();
            Boolean dumpDone = false;
            int i = 0;
            while(!dumpDone){
                dumpDone = true;
                rotateKey.Add(new List<DffBitRecord>());
                for (int j = 0; j < this.numChains; j++) {
                    if (exportKey[j].Value.Count == 0) {
                        rotateKey[i].Add(new DffBitRecord("", 0, 0));
                    }else{
                        dumpDone = false;
                        rotateKey[i].Add(exportKey[j].Value[0]);
                        exportKey[j].Value.RemoveAt(0);
                    }
                }
                i++;
            }
            return rotateKey;
        }

        public class ChainKey {
            private Dictionary<int, DffBitRecord> keys;

            public ChainKey(int chainLength) {
                keys = new Dictionary<int, DffBitRecord>(chainLength);
            }

            public void AppendChain(ChainKey child, int clock) {
                //int parentLength = this.Length;
                foreach (KeyValuePair<int, DffBitRecord> bitKeyEntry in child) {
                    this.keys[bitKeyEntry.Key + clock] = bitKeyEntry.Value;
                }
            }

            public IEnumerator<KeyValuePair<int, DffBitRecord>> GetEnumerator() {
                return this.keys.GetEnumerator();
            }

            public int Length {
                get { return this.keys.Count; }
            }

            public DffBitRecord this[int i] {
                get {
                    if (!keys.ContainsKey(i)) {
                        return new DffBitRecord("[INVALID]", 0,0);
                    } else {
                        return keys[i];
                    }
                }
                set {
                    if (keys.ContainsKey(i)) {
                        keys.Remove(i);
                    }
                    keys.Add(i, value);
                }
            }

            public List<DffBitRecord> Export() {
                List<DffBitRecord> exportKey = new List<DffBitRecord>();
                foreach (KeyValuePair<int, DffBitRecord> bitKey in this.keys) {
                    exportKey.Add(bitKey.Value);
                }

                return exportKey;
            }
        }
    }
}
