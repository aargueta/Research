using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Xml.Serialization;

namespace ShadowParser {
    class ChangeInserter {
        private static string SHADOW_MOD_NAME = "shadow_capture";
        private static string SHADOW_CLOCK = "sh_clk";
        private static string SHADOW_RESET = "sh_rst";
        private static string CAPTURE_ENABLE = "c_en";
        private static string DUMP_ENABLE = "dump_en";

        private static string CHAINS_OUT = "ch_out";
        private static string CHAINS_OUT_DONE = "ch_out_done";
        private static string CHAINS_OUT_VALID = "ch_out_vld";
        
        private static string CHAINS_DUMP_ENABLE = "ch_dump_en";

        private static string INST_CHAINS_OUT = "inst_ch_out";
        private static string INST_CHAINS_OUT_VALID = "inst_ch_out_vld";
        private static string INST_CHAINS_OUT_DONE = "inst_ch_out_done";

        private static string ERROR_LCL_MOD_NAME = "local_err_router";
        private static string ERROR_SUB_MOD_NAME = "sub_err_splitter";
        private static string ERROR_ENABLE = "err_en";
        private static string ERROR_CONTROL = "err_ctrl";
        private static string ERROR_LOCAL_CONTROL = "lcl_err";

        private static string ERROR_PARAMETER = "NO_ERR";

        private VerilogProject project;
        private VerilogModuleTree heirarchy;

        private StringBuilder snapArgLog;

        public ChangeInserter(VerilogProject project,VerilogModuleTree heirarchy) {
            this.project = project;
            this.heirarchy = heirarchy;
            this.snapArgLog = new StringBuilder();
            string[] args = new string[] {"Module Name", "# Local Dff Bits" , "# Chains In", "# Chains Out", "Discrete DFFs" };
            snapArgLog.AppendLine(string.Join(",", args));
        }

        public void UpdateHeirarchy(VerilogModuleTree heirarchy) {
            this.heirarchy = heirarchy;
        }

        public void InsertChanges(InserterMode mode, int numTopChains) {
            heirarchy.PopulateHeirarchy(numTopChains);
            Dictionary<string, FileChangeLog> projectChangeLogs = new Dictionary<string, FileChangeLog>();
            foreach (VerilogModule vMod in heirarchy.FlattenedHeirarchy) {
                if (vMod.NumChainsOut == 0)
                    continue; //No changes to file required. Skip file.
              
                string vFileName = project.GetWorkingCopyPath(vMod);
                FileChangeLog changeLog;
                if (projectChangeLogs.ContainsKey(vFileName)) {
                    changeLog = projectChangeLogs[vFileName];
                } else {
                    changeLog = new FileChangeLog(vFileName);
                    projectChangeLogs.Add(vFileName, changeLog);
                }
                UpdateInstantiations(mode, vMod, changeLog);

                if (mode == InserterMode.Error || mode == InserterMode.Both) {
                    UpdateDffs(mode, vMod, changeLog);
                    InstantiateLocalErrorSplitter(vMod, changeLog);
                    InstantiateSubErrorSplitters(vMod, changeLog);
                }

                if (mode == InserterMode.Shadow || mode == InserterMode.Both)
                    InstantiateShadowCapture(vMod, changeLog);

                InsertLocalPorts(mode, vMod, changeLog);
                InstantiateWires(mode, vMod, changeLog);
            }
            foreach (KeyValuePair<string, FileChangeLog> changeLogEntry in projectChangeLogs) {
                WriteAllChangesToFile(changeLogEntry.Value);
            }

            heirarchy.GenerateHeirarchySnapshotKey();
            string snapKeyFile = Path.Combine(project.Directory, project.Name + ".snpkey");
            string snapArgFile = Path.Combine(project.Directory, project.Name + ".snparg");
            if(!File.Exists(snapKeyFile)){
                FileStream fs = File.Create(snapKeyFile);
                fs.Close();
            }
            if (!File.Exists(snapArgFile)) {
                FileStream fs = File.Create(snapKeyFile);
                fs.Close();
            }
            XmlSerializer serializer = new XmlSerializer(typeof(List<List<DffBitRecord>>));
            using (FileStream stream = File.OpenWrite(snapKeyFile)) {
                List<List<DffBitRecord>> exported = heirarchy.SnapshotKey.RotateExport();
                serializer.Serialize(stream, exported);
                stream.Close();
            }
            File.WriteAllText(snapArgFile, snapArgLog.ToString());
        }

        /// <summary>
        /// Instantiates all wires required for routing signals to/from the shadow capture module
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        private void InstantiateWires(InserterMode mode,VerilogModule vMod, FileChangeLog changeLog) {
            StringBuilder wireInst = new StringBuilder(Environment.NewLine);
            if (mode == InserterMode.Error || mode == InserterMode.Both) {
                wireInst.AppendLine("\t//*****[ERROR WIRE INSTANTIATIONS]******");
                if (vMod.NumLocalDffs > 0)
                    wireInst.AppendLine("\twire [" + (vMod.NumLocalDffs - 1) + ":0] " + ERROR_LOCAL_CONTROL + ";");
                foreach (VerilogModuleInstance vmi in vMod.InstantiatedModules) {
                    if (vmi.Type.ErrorControlWidth <= 0)
                        continue;
                    wireInst.AppendLine("\twire " + vmi.InstanceName + "_" + ERROR_ENABLE + ";");
                    wireInst.AppendLine("\twire " + ((vmi.Type.ErrorControlWidth == 0)? string.Empty :  "[" + (vmi.Type.ErrorControlWidth - 1) + ":0] ") + vmi.InstanceName + "_" + ERROR_CONTROL + ";");
                }
                changeLog.ProposeChange(vMod.PostHeader.Pos, wireInst.ToString());
                wireInst.Clear();
            }


            if (mode == InserterMode.Shadow || mode == InserterMode.Both) {
                if (vMod.NumChainsIn == 0)
                    return;

                string bitLimits = (vMod.NumChainsIn == 1) ? string.Empty : "[" + (vMod.NumChainsIn - 1).ToString() + ":0] ";

                wireInst.AppendLine(Environment.NewLine + "//*****[SHADOW WIRE INSTANTIATIONS]*****");
                wireInst.AppendLine("\twire " + bitLimits + INST_CHAINS_OUT + ";");
                wireInst.AppendLine("\twire " + bitLimits + INST_CHAINS_OUT_VALID + ";");
                wireInst.AppendLine("\twire " + bitLimits + INST_CHAINS_OUT_DONE + ";");
                wireInst.AppendLine("\twire " + bitLimits + CHAINS_DUMP_ENABLE + ";");
                wireInst.AppendLine("");
                changeLog.ProposeChange(vMod.PostHeader.Pos, wireInst.ToString());
            }
        }

        /// <summary>
        /// Updates the modules instantiated within vMod by inserting shadow clock in and chain out ports.
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        private void UpdateInstantiations(InserterMode mode, VerilogModule vMod, FileChangeLog changeLog) {
            //Propose changes in order to generate finalized change list
            int chainOutBit = 0;
            foreach (VerilogModuleInstance vmi in vMod.InstantiatedModules) {

                StringBuilder update = new StringBuilder("," + Environment.NewLine);
                if (mode == InserterMode.Error || mode == InserterMode.Both) {
                    if (vmi.Type.ErrorControlWidth > 0) {
                        String paramChange = String.Empty;
                        if (vmi.Parameterized) {
                            if (vmi.ParametersNamed) {
                                paramChange = " ." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + "),";
                            } else {
                                paramChange = " " + ERROR_PARAMETER + ", ";
                            }
                        } else {
                            paramChange = " #(." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + ")) ";
                        }
                        changeLog.ProposeChange(vmi.ParameterList.Pos, paramChange.ToString());

                        update.AppendLine("\t\t." + ERROR_ENABLE + "(" + vmi.InstanceName + "_" + ERROR_ENABLE + "), // [ERROR]");
                        update.AppendLine("\t\t." + ERROR_CONTROL + "(" + vmi.InstanceName + "_" + ERROR_CONTROL + ") // [ERROR]");
                    }
                }

                if (mode == InserterMode.Shadow || mode == InserterMode.Both) {
                    if (vmi.Type.NumChainsOut > 0) {
                        int chainOutBitUpperLimit = (chainOutBit + vmi.Type.NumChainsOut - 1);
                        string bitLimits = (chainOutBit == chainOutBitUpperLimit) ? ((vMod.NumChainsIn == 1) ? string.Empty : "[" + chainOutBit.ToString() + "]") : "[" + (chainOutBitUpperLimit + ":" + chainOutBit) + "]";
                        update.AppendLine(",");
                        update.AppendLine("\t\t." + SHADOW_CLOCK + "(" + SHADOW_CLOCK + "),   // [SHADOW]");
                        update.AppendLine("\t\t." + SHADOW_RESET + "(" + SHADOW_RESET + "),   // [SHADOW]");
                        update.AppendLine("\t\t." + CAPTURE_ENABLE + "(" + CAPTURE_ENABLE + "),   // [SHADOW]");
                        update.AppendLine("\t\t." + DUMP_ENABLE + "(" + CHAINS_DUMP_ENABLE + bitLimits + "),   // [SHADOW]");
                        update.AppendLine("\t\t." + CHAINS_OUT + "(" + INST_CHAINS_OUT + bitLimits + "),   // [SHADOW]");
                        update.AppendLine("\t\t." + CHAINS_OUT_DONE + "(" + INST_CHAINS_OUT_DONE + bitLimits + "),    // [SHADOW]");
                        update.AppendLine("\t\t." + CHAINS_OUT_VALID + "(" + INST_CHAINS_OUT_VALID + bitLimits + ") // [SHADOW]");

                        chainOutBit += vmi.Type.NumChainsOut;
                    }
                }
                if (update.ToString() == ("," + Environment.NewLine))
                    continue;
                changeLog.ProposeChange(vmi.InOutListEnd.Pos, update.ToString());
                
            }
        }

        /// <summary>
        /// Updates DFFs to support error injections
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        private void UpdateDffs(InserterMode mode, VerilogModule vMod, FileChangeLog changeLog) {
            int i = 0;
            foreach (DffInstance dff in vMod.LocalDffs) {
                if (dff.ParametersExist) {
                    if (dff.ParametersNamed) {
                        changeLog.ProposeChange(dff.ParameterBegin.Pos, " ." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + "), ");
                    } else {
                        if (dff.ParamsInParens) {
                            changeLog.ProposeChange(dff.ParameterBegin.Pos, " ." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + "), .SIZE(");
                            changeLog.ProposeChange(dff.ParameterEnd.Pos, ") ");
                        } else {
                            changeLog.ProposeChange(dff.ParameterBegin.Pos, "( ." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + "), .SIZE(");
                            changeLog.ProposeChange(dff.ParameterEnd.Pos, ")) ");
                        }
                    }
                } else {
                    changeLog.ProposeChange(dff.ParameterBegin.Pos, " #( ." + ERROR_PARAMETER + "(" + ERROR_PARAMETER + ")) ");
                }
                changeLog.ProposeChange(dff.PortList.Pos, Environment.NewLine + ".err_en(lcl_err" + ((vMod.ErrorControlWidth > 1)? "[" + i + "]" : string.Empty) + "),");
                i++;
            }
        }

        private void InstantiateLocalErrorSplitter(VerilogModule vMod, FileChangeLog changeLog) {
            if (vMod.NumLocalDffs == 0)
                return;

            StringBuilder lesSB = new StringBuilder(Environment.NewLine);
            lesSB.AppendLine("\t//[Local Error Control Splitter Instantiation here]");

            lesSB.AppendLine("\tlclErrCtrlSplitter #(.INW(" + vMod.ErrorControlWidth + 
                "), .LCL(" + vMod.NumLocalDffs + ")) " + 
                ERROR_LCL_MOD_NAME + "_" + vMod.Name + "(");
            lesSB.AppendLine("\t\t.err_en(err_en),");
            lesSB.AppendLine("\t\t.err_ctrl(err_ctrl),");
            lesSB.AppendLine("\t\t.lcl_err(lcl_err)");
            lesSB.AppendLine("\t);");
            lesSB.AppendLine(Environment.NewLine);
            changeLog.ProposeChange(vMod.PrevEndModule.Pos, lesSB.ToString());
        }

        private void InstantiateSubErrorSplitters(VerilogModule vMod, FileChangeLog changeLog) {
            if (vMod.InstantiatedModules.Count < 1)
                return;

            StringBuilder sesSB = new StringBuilder(Environment.NewLine);
            sesSB.AppendLine("\t//[Sub Error Control Splitter Instantiations here]");
            foreach (VerilogModuleInstance vmi in vMod.InstantiatedModules) {
                if (vmi.Type.ErrorControlWidth <= 0)
                    continue;
                sesSB.AppendLine("\tsubErrCtrlSplitter #(" +
                    ".INW(" + vMod.ErrorControlWidth + "), " +
                    ".OUTW(" + vmi.Type.ErrorControlWidth + "), " +
                    ".LOW(" + vmi.LowerLocalErrorId + "), " +
                    ".HIGH(" + vmi.UpperLocalErrorId + ")) " +
                    ERROR_SUB_MOD_NAME + "_" + vmi.InstanceName + "(");
                sesSB.AppendLine("\t\t.err_en(err_en),");
                sesSB.AppendLine("\t\t.err_ctrl(err_ctrl),");
                sesSB.AppendLine("\t\t.sub_err_en(" + vmi.InstanceName + "_" + ERROR_ENABLE + "),");
                sesSB.AppendLine("\t\t.sub_err_ctrl(" + vmi.InstanceName + "_" + ERROR_CONTROL + ")");
                sesSB.AppendLine("\t);");
                sesSB.AppendLine(Environment.NewLine);

            }
            changeLog.ProposeChange(vMod.PrevEndModule.Pos, sesSB.ToString());
        }

        /// <summary>
        /// Insert actual instantiation of shadow capture module
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        private void InstantiateShadowCapture(VerilogModule vMod, FileChangeLog changeLog) {
            StringBuilder shadowCapture = new StringBuilder(Environment.NewLine);
            shadowCapture.AppendLine("\t//[Shadow Module Instantiation here]"); 

            string discreteDffs, dffWidths, dclks;
            DffWidthParameters(vMod, out discreteDffs, out dffWidths, out dclks);
            shadowCapture.AppendLine("\tshadow_capture #(.DFF_BITS(" + vMod.NumLocalDffBits + 
                "), .USE_DCLK(" + ((vMod.LocalDffs.Count > 0) ? "1" : "0") + 
                "), .CHAINS_IN(" + vMod.NumChainsIn + 
                "), .CHAINS_OUT(" + vMod.NumChainsOut + 
                "), .DISCRETE_DFFS(" + discreteDffs + 
                "), .DFF_WIDTHS(" + dffWidths + ")) " + 
                SHADOW_MOD_NAME + "_" + vMod.Name + " (");
            shadowCapture.AppendLine("\t\t.clk(" + SHADOW_CLOCK + "), ");
            shadowCapture.AppendLine("\t\t.rst(" + SHADOW_RESET + "), ");
            shadowCapture.AppendLine("\t\t.capture_en(" + CAPTURE_ENABLE + "), ");
            shadowCapture.AppendLine("\t\t.dclk(" + dclks + "), ");
            shadowCapture.AppendLine("\t\t.din(" + RouteLocalDffs(vMod) + "),");
            shadowCapture.AppendLine("\t\t.dump_en(" + DUMP_ENABLE + "), ");
            shadowCapture.AppendLine("\t\t.chains_in(" + RouteInstanceShadowChains(vMod) + "), ");
            shadowCapture.AppendLine("\t\t.chains_in_vld(" + ((vMod.NumChainsIn > 0) ? INST_CHAINS_OUT_VALID : "") + "), ");
            shadowCapture.AppendLine("\t\t.chains_in_done(" + ((vMod.NumChainsIn == 0) ? "" : INST_CHAINS_OUT_DONE) + "), ");
            shadowCapture.AppendLine("\t\t.chain_dump_en(" + ((vMod.NumChainsIn == 0) ? "" : CHAINS_DUMP_ENABLE) + "), ");
            shadowCapture.AppendLine("\t\t.chains_out(" + CHAINS_OUT + "), ");
            shadowCapture.AppendLine("\t\t.chains_out_vld(" + CHAINS_OUT_VALID + "), ");
            shadowCapture.AppendLine("\t\t.chains_out_done(" + CHAINS_OUT_DONE + ")");
            shadowCapture.AppendLine("\t);");
            changeLog.ProposeChange(vMod.PrevEndModule.Pos, shadowCapture.ToString());
            string[] args = new string[]{vMod.Name, vMod.NumLocalDffBits.ToString(), vMod.NumChainsIn.ToString(), vMod.NumChainsOut.ToString(), discreteDffs.ToString()};
            snapArgLog.AppendLine(string.Join(",", args ));
        }

        private void DffWidthParameters(VerilogModule vMod, out string discreteDffs, out string dffWidths, out string dclks) {
            if (vMod.LocalDffs.Count == 0) {
                discreteDffs = string.Empty;
                dffWidths = string.Empty;
                dclks = string.Empty;
                return;
            }
            List<int> commonClkWidths = new List<int>();
            List<string> commonClks = new List<string>();

            List<DffInstance> dffs = vMod.LocalDffs;
            string currClk = dffs[0].ClockPort;
            int currClkWidth = 0;
            for (int i = 0; i < dffs.Count; i++) {
                if (currClk == dffs[i].ClockPort) {
                    currClkWidth += dffs[i].Size;
                } else {
                    commonClks.Add(currClk);
                    commonClkWidths.Add(currClkWidth);
                    currClk = dffs[i].ClockPort;
                    currClkWidth = dffs[i].Size;
                }
                if (i == dffs.Count - 1) {
                    commonClks.Add(currClk);
                    commonClkWidths.Add(currClkWidth);
                }
            }

            StringBuilder clkSB = new StringBuilder("{");
            StringBuilder widthSB = new StringBuilder("{");
            for (int i = 0; i < commonClks.Count; i++) {
                clkSB.Append(commonClks[i]);
                widthSB.Append("32'd" + commonClkWidths[i]);
                if (i != commonClks.Count - 1){
                    clkSB.Append(", ");
                    widthSB.Append(", ");
                }
            }

            clkSB.Append("}");
            widthSB.Append("}");
            discreteDffs = commonClks.Count.ToString();
            dffWidths = widthSB.ToString();
            dclks = clkSB.ToString();
        }

        //private string RouteDataClocks(VerilogModule vMod) {
        //    if (vMod.LocalDffs.Count == 0)
        //        return string.Empty;
        //    StringBuilder dataClocks = new StringBuilder("{");
        //    for (int i = 0; i < vMod.LocalDffs.Count; i++) {
        //        //if (vMod.LocalDffs[i].Size != 1) {
        //        //    dataClocks.Append("{" + vMod.LocalDffs[i].Size + "{" + vMod.LocalDffs[i].ClockPort + "}}");
        //        //} else {
        //            dataClocks.Append(vMod.LocalDffs[i].ClockPort);
        //        //}
        //        if (i != vMod.LocalDffs.Count - 1)
        //            dataClocks.Append(", ");
        //    }
        //    dataClocks.Append("}");
        //    return dataClocks.ToString();
        //}

        /// <summary>
        /// Returns a string of all the outputs of the local DFFs
        /// </summary>
        /// <param name="vMod"></param>
        /// <returns></returns>
        private string RouteLocalDffs(VerilogModule vMod) {
            if (vMod.LocalDffs.Count == 0)
                return string.Empty;
            StringBuilder dffOutputs = new StringBuilder("{");
            for (int i = 0; i < vMod.LocalDffs.Count; i++) {
                dffOutputs.Append(vMod.LocalDffs[i].QPort);
                if (i != vMod.LocalDffs.Count - 1)
                    dffOutputs.Append(", ");
            }
            dffOutputs.Append("}");
            return dffOutputs.ToString();
        }

        /// <summary>
        /// Returns a string of all the shadow outputs of the instantiated modules
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        /// <returns></returns>
        private string RouteInstanceShadowChains(VerilogModule vMod) {
            if (vMod.NumChainsIn == 0)
                return string.Empty;
            // TODO: Change to dynamic number of chains out
            /*
            StringBuilder shadowChains = new StringBuilder("{");
            for (int i = 0; i < vMod.InstantiatedModules.Count; i++) {
                shadowChains.Append("ch_out_" + vMod.InstantiatedModules[i].InstanceName);
                if (i != vMod.InstantiatedModules.Count - 1)
                    shadowChains.Append(", ");
            }
            shadowChains.Append("}");
            return shadowChains.ToString();*/
            return INST_CHAINS_OUT;
        }

        /// <summary>
        /// Inserts all the inputs and outputs into the module being shadowed that are required by the shadow capture module
        /// </summary>
        /// <param name="vMod"></param>
        /// <param name="changeLog"></param>
        private void InsertLocalPorts(InserterMode mode, VerilogModule vMod, FileChangeLog changeLog) {
            StringBuilder inouts = new StringBuilder(Environment.NewLine);
            if (mode == InserterMode.Error || mode == InserterMode.Both) {
                inouts.AppendLine("," + Environment.NewLine + "//*****[ERROR CAPTURE MODULE INOUTS]*****");
                inouts.AppendLine("\t" + ERROR_ENABLE + ", // Error injection enable");
                inouts.AppendLine("\t" + ERROR_CONTROL + " // Error injection control");
            }

            if (mode == InserterMode.Shadow || mode == InserterMode.Both) {
                inouts.AppendLine("," + Environment.NewLine + "//*****[SHADOW CAPTURE MODULE INOUTS]*****");
                inouts.AppendLine("\t" + SHADOW_CLOCK + ", // Shadow/data clock");
                inouts.AppendLine("\t" + SHADOW_RESET + ", // Shadow/data reset");
                inouts.AppendLine("\t" + CAPTURE_ENABLE + ", // Capture enable");
                inouts.AppendLine("\t" + DUMP_ENABLE + ", // Dump enable");
                inouts.AppendLine("\t" + CHAINS_OUT + ", // Chains out");
                inouts.AppendLine("\t" + CHAINS_OUT_VALID + ", // Chains out valid");
                inouts.AppendLine("\t" + CHAINS_OUT_DONE + " // Chains done");
            }
            changeLog.ProposeChange(vMod.InOutListEnd.Pos, inouts.ToString());

            StringBuilder inoutDeclarations = new StringBuilder(Environment.NewLine);
            if ((mode == InserterMode.Error || mode == InserterMode.Both) && vMod.ErrorControlWidth > 0) {
                inoutDeclarations.AppendLine("parameter " + ERROR_PARAMETER + " = 1;" + Environment.NewLine);
                inoutDeclarations.AppendLine("\t//*****[ERROR CAPTURE MODULE INOUTS INSTANTIATIONS]*****");
                inoutDeclarations.AppendLine("\tinput\t" + ERROR_ENABLE + "; // Error injection enable");
                inoutDeclarations.AppendLine("\tinput\t" + ((vMod.ErrorControlWidth == 1) ? string.Empty : "[" + (vMod.ErrorControlWidth - 1) + ":0] ") + ERROR_CONTROL + "; // Error injection control");
                inoutDeclarations.AppendLine("");
            }

            if (mode == InserterMode.Shadow || mode == InserterMode.Both) {
                string chainsOutLimits = "[" + (vMod.NumChainsOut - 1) + ":0]";
                inoutDeclarations.AppendLine("\t//*****[SHADOW CAPTURE MODULE INOUT INSTANTIATIONS]*****");
                inoutDeclarations.AppendLine("\tinput\t" + SHADOW_CLOCK + "; // Shadow/data clock");
                inoutDeclarations.AppendLine("\tinput\t" + SHADOW_RESET + "; // Shadow/data reset");
                inoutDeclarations.AppendLine("\tinput\t" + CAPTURE_ENABLE + "; // Capture enable");
                inoutDeclarations.AppendLine("\tinput\t" + chainsOutLimits + "\t" + DUMP_ENABLE + "; // Dump enable");
                inoutDeclarations.AppendLine("\toutput\t" + chainsOutLimits + "\t" + CHAINS_OUT + "; // Chains out");
                inoutDeclarations.AppendLine("\toutput\t" + chainsOutLimits + "\t" + CHAINS_OUT_VALID + "; // Chains out Valid");
                inoutDeclarations.AppendLine("\toutput\t" + chainsOutLimits + "\t" + CHAINS_OUT_DONE + "; // Chains done");
            }
            changeLog.ProposeChange(vMod.PostHeader.Pos, inoutDeclarations.ToString());
        }

        private void WriteAllChangesToFile(FileChangeLog changeLog) {
            StreamReader sr = new StreamReader(changeLog.Filename);
            string originalFile = sr.ReadToEnd();
            sr.Close();

            List<FileChangeLog.ChangeRecord> changes = changeLog.FinalizeChangeLog();

            StreamWriter sw = new StreamWriter(changeLog.Filename);
            int origFilePos = 0;
            FileChangeLog.ChangeRecord changeRec;
            for (int i = 0; i < changes.Count; i++) {
                changeRec = changes[i];
                sw.Write(originalFile.Substring(origFilePos, changeRec.OriginalPosition - origFilePos));
                sw.Write(changeRec.Change);
                origFilePos = changeRec.OriginalPosition; //Update the position in the original file
            }
            sw.Write(originalFile.Substring(origFilePos, originalFile.Length - origFilePos)); //Write remainder of the file
            sw.Close();
        }

        public enum InserterMode {Shadow, Error, Both }

    }
}
