using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace SnapshotMapper {
    [Serializable]
    [XmlType(TypeName="DffBitRecord")]
    public class DffBitRecord {
        public DffBitRecord() {
            this.Name = String.Empty;
            this.Size = 0;
            this.BitNum = 0;
        }

        public DffBitRecord(String instName, int size, int bitNum) {
            this.Name = instName;
            this.Size = size;
            this.BitNum = bitNum;
        }

        public String Name { get; set; }

        public int Size { get; set; }

        public int BitNum { get; set; }
    }
}
