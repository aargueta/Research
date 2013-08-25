using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.Specialized;

namespace ShadowParser {
    class FileChangeLog {
        private string filename;
        private SortedList<int, string> changeLog;
        private List<int> origPoss;
        private List<string> changes;

        public FileChangeLog(string filename) {
            this.filename = filename;
            this.changeLog = new SortedList<int, string>();
        }

        public string Filename {
            get { return this.filename; }
        }

        /// <summary>
        /// Stores a proposed change
        /// </summary>
        /// <param name="originalPos">Location within the original file to insert characters.</param>
        /// <param name="change">String to be inserted</param>
        public void ProposeChange(int originalPos, string change){
            if (changeLog.ContainsKey(originalPos)) {
                string newChange = (string)changeLog[originalPos] + change;
                changeLog.Remove(originalPos);
                changeLog.Add(originalPos, newChange);
            } else {
                changeLog.Add(originalPos, change);
            }
            origPoss = changeLog.Keys.ToList();
        }

        /// <summary>
        /// Calculate new position for the change at the original position.
        /// </summary>
        /// <param name="originalPos">Original position in the file for proposed change.</param>
        /// <returns></returns>
        public int CalcActualPos(int originalPos) {
            if (changeLog.Count == 0)
                return originalPos;
            int newPos = originalPos;
            for (int i = 0; i < changeLog.Count; i++) {
                if (origPoss[i] >= originalPos) {
                    break;
                } else if (origPoss[i] < originalPos) {
                    newPos += ((string)changeLog[i]).Length;
                }
            }
            return newPos;
        }

        /// <summary>
        /// Finalizes change insertion positions once all changes have been proposed and returns 
        /// these positions and their corresponding strings to insert.
        /// </summary>
        /// <returns></returns>
        public List<ChangeRecord> FinalizeChangeLog() {
            List<ChangeRecord> finalChangeLog = new List<ChangeRecord>();

            origPoss = changeLog.Keys.ToList();
            changes = changeLog.Values.ToList();
            int cumulativeChangeLength = 0;
            for (int i = 0; i < changeLog.Count; i++) {
                finalChangeLog.Add(new ChangeRecord(origPoss[i], origPoss[i] + cumulativeChangeLength, changes[i]));
                cumulativeChangeLength += changes[i].Length;
            }
            return finalChangeLog;
        }

        public void RemoveChange(int originalPos) {
            changeLog.Remove(originalPos);
        }

        public struct ChangeRecord {

            public ChangeRecord(int originalPosition, int finalizedPosition, string change) {
                this.OriginalPosition = originalPosition;
                this.FinalizedPosition = finalizedPosition;
                this.Change = change;
            }

            public int OriginalPosition;
            public int FinalizedPosition;
            public string Change;
        }
    }
}
