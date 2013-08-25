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

namespace SnapshotMapper {
    public partial class MainWindow : Form {
        private Stream snapKeyStream;
        private Stream rawDumpStream;
        private String rawDumpFilename;
        private List<List<DffBitRecord>> snapKey;
        private Dictionary<String, List<int>> mappedDump;
        private Dictionary<String, int> sizeDictionary;

        public MainWindow() {
            InitializeComponent();
        }

        private void browseSnapKey_Click(object sender, EventArgs e) {
            OpenFileDialog fileDlg = new OpenFileDialog();
            fileDlg.InitialDirectory = snapKeyUrl.Text;
            fileDlg.Multiselect = false;
            fileDlg.Filter = "SnapKey|*.snpkey";
            if (fileDlg.ShowDialog() == DialogResult.Cancel)
                return;
            snapKeyStream = fileDlg.OpenFile();
            snapKeyUrl.Text = fileDlg.FileName;
            XmlSerializer xml = new XmlSerializer(typeof(List<List<DffBitRecord>>));
            snapKey = (List<List<DffBitRecord>>)xml.Deserialize(snapKeyStream);
        }

        private void browseRadDump_Click(object sender, EventArgs e) {
            OpenFileDialog fileDlg = new OpenFileDialog();
            fileDlg.InitialDirectory = rawDumpUrl.Text;
            fileDlg.Multiselect = false;
            fileDlg.Filter = "SnapDump|*.snpdmp";
            if (fileDlg.ShowDialog() != DialogResult.OK)
                return;
            rawDumpStream = fileDlg.OpenFile();
            rawDumpUrl.Text = fileDlg.FileName;
            rawDumpFilename = fileDlg.FileName;
        }

        private void mapDump_Click(object sender, EventArgs e) {

            mappedDump = new Dictionary<String, List<int>>();
            sizeDictionary = new Dictionary<string, int>();
            StreamReader dumpRdr = new StreamReader(rawDumpStream);
            for (int i = 0; i < snapKey.Count; i++) {
                if (dumpRdr.EndOfStream) {
                    MessageBox.Show("Exited early. Expected " + snapKey.Count + " values, but only found " + i);
                    break;
                }
                String dumpLine = dumpRdr.ReadLine();
                int dumpVal = Convert.ToInt32(dumpLine, 16);
                for (int j = 0; j < snapKey[i].Count; j++) {
                    string dffName = snapKey[i][j].Name;
                    if (dffName == String.Empty)
                        continue;
                    int dffSize = snapKey[i][j].Size;
                    if(!sizeDictionary.ContainsKey(dffName))
                        sizeDictionary.Add(dffName, dffSize);
                    int bitNum = snapKey[i][j].BitNum;

                    if(!mappedDump.ContainsKey(dffName)){
                        mappedDump.Add(dffName, new List<int>());
                        int allocSize = dffSize / 32 + ((dffSize % 32 > 0)? 1 : 0);
                        for (int k = 0; k < allocSize; k++) {
                            mappedDump[dffName].Add(0);
                        }
                    }
                    int bitVal = (dumpVal >> j) & 0x1;
                    int bitOffset = bitNum % 32;
                    int wordOffset = bitNum / 32;

                    bitVal = bitVal << bitOffset;
                    mappedDump[dffName][wordOffset] |= bitVal;
                }
            }
            dumpRdr.Close();

            XmlSerializer serializer = new XmlSerializer(typeof(List<DffValueRecord>));
            using (FileStream stream = File.OpenWrite(rawDumpFilename + ".map")) {
                serializer.Serialize(stream, WriteDffValues());
                stream.Close();
            }
        }

        private List<DffValueRecord> WriteDffValues() {
            Dictionary<String, String> readyMappedDump = new Dictionary<string, string>();
            foreach (KeyValuePair<String, List<int>> dffEntry in this.mappedDump) {
                readyMappedDump.Add(dffEntry.Key, String.Empty);
                for (int i = 0; i < dffEntry.Value.Count; i++) {
                    String hexString;
                    if (i == dffEntry.Value.Count - 1) {
                        hexString = dffEntry.Value[i].ToString("X");
                    } else {
                        hexString = dffEntry.Value[i].ToString("X8");
                    }
                    readyMappedDump[dffEntry.Key] = hexString + readyMappedDump[dffEntry.Key];
                }
            }
            List<DffValueRecord> serialMappedDump = new List<DffValueRecord>();
            foreach (KeyValuePair<String, String> dffEntry in readyMappedDump) {
                serialMappedDump.Add(new DffValueRecord(dffEntry.Key, sizeDictionary[dffEntry.Key], dffEntry.Value));
            }
            return serialMappedDump;
        }

    }
}
