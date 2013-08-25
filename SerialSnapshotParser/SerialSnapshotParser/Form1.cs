using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;

namespace SerialSnapshotParser {
    public partial class Form1 : Form {
        private SerialPort port;
        private List<string> firstSnapshot, secondSnapshot;

        public Form1() {
            InitializeComponent();
            firstSnapshot = new List<String>();
            secondSnapshot = new List<String>();
            foreach (String portName in SerialPort.GetPortNames()) {
                this.portSelect.Items.Add(portName);
            }
            this.baudSelect.SelectedIndex = 0;
            this.portSelect.SelectedIndex = 0;
            this.snapShotSelect.SelectedIndex = 0;
            port = new SerialPort(this.portSelect.SelectedItem.ToString(), Int32.Parse(this.baudSelect.SelectedItem.ToString()), Parity.None, 8, StopBits.Two);
            
            port.Handshake = Handshake.None;
            port.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);
            port.ErrorReceived += new SerialErrorReceivedEventHandler(port_ErrorReceived);
        }

        private void port_DataReceived(object sender, SerialDataReceivedEventArgs e) {
            Invoke(new EventHandler<SerialDataReceivedEventArgs>(CaptureData), new object[] { sender, e });
        }

        private void port_ErrorReceived(object sender, SerialErrorReceivedEventArgs e) {
            Invoke(new EventHandler<SerialErrorReceivedEventArgs>(CaptureError), new object[] { sender, e });
        }

        private void CaptureData(object sender, SerialDataReceivedEventArgs e) {
            List<String> sb = (this.snapShotSelect.SelectedIndex == 0) ? firstSnapshot : secondSnapshot;
            while (port.BytesToRead > 0) {
                sb.Add(port.ReadByte().ToString("X2"));
            }
        }

        private void CaptureError(object sender, SerialErrorReceivedEventArgs e) {
            List<String> sb = (this.snapShotSelect.SelectedIndex == 0) ? firstSnapshot : secondSnapshot;
            while (port.BytesToRead > 0) {
                sb.Add(port.ReadByte().ToString("X2"));
            }
        }

        private void captureToggle_CheckedChanged(object sender, EventArgs e) {
            try {
                if (captureToggle.Checked) {
                    port = new SerialPort(this.portSelect.SelectedItem.ToString(), Int32.Parse(this.baudSelect.SelectedItem.ToString()), Parity.None, 8, StopBits.Two);
                    port.Open();
                    port.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);
                    port.ErrorReceived += new SerialErrorReceivedEventHandler(port_ErrorReceived);
                } else {
                    port.Close();
                }
            } catch (Exception ex) {
                MessageBox.Show(ex.Message, "COM Operation Failure", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void diffChanges_Click(object sender, EventArgs e) {
            StringBuilder sb1 = new StringBuilder();
            for(int i = 0; i < firstSnapshot.Count; i++){
                sb1.Append(firstSnapshot[i] + ((i % 10 == 9)? Environment.NewLine : " "));
            }
            StringBuilder sb2 = new StringBuilder();
            for (int i = 0; i < secondSnapshot.Count; i++) {
                sb2.Append(secondSnapshot[i] + ((i % 10 == 9) ? Environment.NewLine : " "));
            }
            sShot1Box1.Text = sb1.ToString();
            sShot1Box2.Text = sb2.ToString();
        }

        private void sShot1Box1_Click(object sender, System.EventArgs e) {
            sShot1Box1.SelectAll();
            sShot1Box1.Copy();
        }

        private void sShot1Box2_Click(object sender, System.EventArgs e) {
            sShot1Box2.SelectAll();
            sShot1Box2.Copy();
        }

        private void clearSnaps_Click(object sender, EventArgs e) {
            firstSnapshot.Clear();
            secondSnapshot.Clear();
        }
    }
}
