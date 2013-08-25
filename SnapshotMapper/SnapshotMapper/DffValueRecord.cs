using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace SnapshotMapper {
    [Serializable]
    [XmlType(TypeName = "DffValueRecord")]
    public class DffValueRecord {
        public DffValueRecord() {
            this.Name = String.Empty;
            this.Size = 0;
            this.Value = String.Empty;
        }

        public DffValueRecord(String instName, int size,  String value) {
            this.Name = instName;
            this.Size = size;
            this.Value = value;
        }

        public String Name { get; set; }

        public int Size { get; set; }

        public String Value { get; set; }
    }
}
