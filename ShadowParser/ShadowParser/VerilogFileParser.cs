using System.Collections.Generic;
using Ader.Text;
using System.IO;
using System.Windows.Forms;
using System;

namespace ShadowParser {
    class VerilogFileParser {
        private VerilogProject project;
        private Stack<string> ifdefStack;
        private HashSet<string> defineSet;

        public VerilogFileParser(VerilogProject project) {
            this.project = project;
        }

        private VerilogFile ConductParse(string filename, Token bookmark = null) {
            VerilogFile vFile = new VerilogFile(filename);
            StringTokenizer tknzr = StringTokenizer.TokenizerFromFile(filename, bookmark);
            ParseForModDeclarations(tknzr, vFile);
            return vFile;
        }

        public VerilogFile Parse(string filename) {
            return ConductParse(filename);
        }


        // IS THIS EVEN NEEDED??????
        public VerilogFile Reparse(PossibleInstance pi) {
            return ConductParse(pi.ParentModule.Filename, pi.Bookmark);
        }

        private void ParseForModDeclarations(StringTokenizer tknzr, VerilogFile vFile) {
            SetupPrecompiler();
            Token prevTok = null;
            Token currTok = tknzr.Next();
            while (true) {
                if (currTok.Kind == TokenKind.EOF)
                    break;
                if (prevTok == null || prevTok.Kind == TokenKind.EOL) {
                    RunPrecompiler(tknzr, ref prevTok, ref currTok);

                    if (currTok.Value == "module") {
                        VerilogModule parsedModule = ParseModuleDeclaration(tknzr, vFile);
                        AssignDffErrorIds(parsedModule);
                        vFile.AddDeclaration(parsedModule);
                    }
                }
                prevTok = currTok;
                currTok = tknzr.Next();
            }
        }

        private void SetupPrecompiler() {
            ifdefStack = new Stack<string>();
            defineSet = new HashSet<string>();
            string[] compileDirectives = {"FPGA_SYN", "FPGA_SYN_1THREAD", "FPGA_SYN_NO_SPU", "FPGA_SYN_8TLB"};
            foreach (string directive in compileDirectives) {
                defineSet.Add(directive);
            }
        }

        private Boolean RunPrecompiler(StringTokenizer tknzr, ref Token prevTok, ref Token currTok) { 
            if (currTok.Value != "`")
                return false;
            // PRECOMPILER DIRECTIVE FOUND
            prevTok = currTok;
            currTok = tknzr.Next();
            if (currTok.Value == "ifdef") {
                prevTok = currTok;
                currTok = tknzr.Next();
                if (defineSet.Contains(currTok.Value)) {
                    //PARSE: If it is defined, parse the ifdef
                    ifdefStack.Push(currTok.Value + "@" + currTok.Line + ":" + currTok.Column);
                } else {
                    //IGNORE: Seek to end or else
                    int ifdefCount = 0;
                    while (true) {
                        if (currTok.Kind == TokenKind.EOF)
                            break;
                        prevTok = currTok;
                        currTok = tknzr.Next();
                        if (currTok.Value == "ifdef") {
                            ifdefCount++;
                        } else if(currTok.Value == "else" && ifdefCount == 0){
                            break;
                        } else if (currTok.Value == "endif") {
                            if (ifdefCount > 0) {
                                ifdefCount--;
                            } else {
                                break;
                            }
                        }
                    }
                    if (currTok.Value == "else")
                        ifdefStack.Push(currTok.Value + "@" + currTok.Line + ":" + currTok.Column);
                }
            } else if (currTok.Value == "else") {
                // IGNORE: 
                int ifdefCount = 0;
                while (true) {
                    if (currTok.Kind == TokenKind.EOF)
                        break;
                    prevTok = currTok;
                    currTok = tknzr.Next();
                    if (currTok.Value == "ifdef") {
                        ifdefCount++;
                    } else if (currTok.Value == "endif") {
                        if (ifdefCount > 0) {
                            ifdefCount--;
                        } else {
                            break;
                        }
                    }
                }
                //ifdefStack.Pop();
            } else if (currTok.Value == "endif") {
                // PARSE:
                //ifdefStack.Pop();
            } else if (currTok.Value == "define") {
                prevTok = currTok;
                currTok = tknzr.Next();
                defineSet.Add(currTok.Value);
            }
            prevTok = currTok;
            currTok = tknzr.Next();
            return true;
        }

        private VerilogModule ParseModuleDeclaration(StringTokenizer tknzr, VerilogFile vFile) {
            #region Are the ports even needed? Besides knowing where to insert the shadow chain ports

            /*
            List<string> inPorts = new List<string>();
            List<string> outPorts = new List<string>();
            List<string> inoutPorts = new List<string>();
            Token currToken = null;
            Token prevToken = new Token(TokenKind.Unknown, "", 0, 0, 0);
            while (true) {
                if (currToken == null) {
                    tknzr.Next();
                }
                currToken = tknzr.Next();
                if (currToken.Kind == TokenKind.EOF) {
                    break;
                } else if (currToken.Value == ";" && prevToken.Value == ")") {
                    break;
                } else if (currToken.Value == "input" && prevToken.Kind == TokenKind.EOL) {
                    
                }
                prevToken = currToken;
            }
            */
            #endregion
            Token prevTok = tknzr.Next();
            Token twoPrevTok = prevTok;
            Token currTok = tknzr.Next();
            VerilogModule vMod = new VerilogModule(vFile.FileName, prevTok.Value);
            bool headerParsed = false;
            while (currTok.Value != "endmodule" && currTok.Kind != TokenKind.EOF) {
                if (prevTok.Kind == TokenKind.EOL) {
                    if (!RunPrecompiler(tknzr, ref prevTok, ref currTok)) {
                        if (currTok.Value == "parameter") {
                            // PARAMETER FOUND
                            ParseParameter(tknzr, vMod.Parameters);
                        } else if (this.project.IsDff(currTok.Value)) {
                            // DFF INSTANCE FOUND
                            DffInstance dffInst = ParseDffInstance(tknzr, currTok, project.GetDffType(currTok.Value));
                            if (dffInst == null) {
                                throw new InvalidDataException("DFF Library was unable to instantiate from type retrieved from project.");
                            }
                            vMod.AddDffInstance(dffInst);
                        } else if (this.project.IsModule(currTok.Value)) {
                            // MODULE INSTANCE FOUND
                            VerilogModuleInstance vModInst = ParseModuleInstance(vMod, tknzr, currTok, project.GetModule(currTok.Value));
                            if (vModInst == null) {
                                throw new InvalidDataException("Error instantiating module from type retrieved from project.");
                            }
                            vMod.AddModuleInstance(vModInst);
                        } else if (headerParsed && !this.project.IsKeyword(currTok.Value) && currTok.Kind == TokenKind.Word) {
                            // POSSIBLE MODULE, NOT YET PARSED
                            /* OPTIMZATION:
                             * TODO: Change tokenizer to ignore everything between certain keywords and ';', 
                             * EX: "assign blah = blah blah blah;" in case there is weird indenting for 
                             * readibility. This will minimize the number of false Possibles.
                             * */
                            if(currTok.Value == "lsu_dc_parity_gen")
                                Console.Write("!");
                            StringTokenizer tempTknzr = new StringTokenizer(tknzr); // Perform deep copy to leave tknzr untouched
                            Token nameTok = tempTknzr.Next();
                            bool paramExist = false;
                            bool paramNamed = false;
                            Token paramList = null;
                            /*if (nameTok.Value == "#") {
                                paramsExist = true;
                                tempTknzr.Next();// (
                                tempTknzr.Next();// Number
                                tempTknzr.Next();// )
                                nameTok = tempTknzr.Next();
                            }*/

                            if (nameTok.Value == "#") {
                                // Run through parameter lists until parens all closed
                                paramExist = true;
                                paramList = tempTknzr.Next(); // after "#("
                                if (paramList.Value == "(") {
                                    int parenPairs = 1;
                                    while (parenPairs > 0) {
                                        nameTok = tempTknzr.Next();
                                        if (nameTok.Value.Contains("."))
                                            paramNamed = true;
                                        if (nameTok.Value == "(") {
                                            parenPairs++;
                                        } else if (nameTok.Value == ")") {
                                            parenPairs--;
                                        }
                                    }
                                }
                                nameTok = tempTknzr.Next();
                            } else {
                                paramList = currTok;
                            }
                            Token tempCurrTok = tempTknzr.Next();
                            Token tempPrevTok = tempCurrTok;
                            Token tempTwoPrevTok = tempCurrTok;
                            while (tempCurrTok.Value != ";") {
                                // Run through in/out list to end of instantiation
                                tempTwoPrevTok = tempPrevTok;   // At ')'
                                tempPrevTok = tempCurrTok;      // At ';'
                                tempCurrTok = tempTknzr.Next(); // After ';'
                            }
                            vMod.AddPossibleInstance(currTok, nameTok.Value, tempTwoPrevTok, paramExist, paramNamed, paramList);
                        }
                    }
                }
                twoPrevTok = prevTok;
                prevTok = currTok;
                currTok = tknzr.Next();
                if (!headerParsed && currTok.Value == ";" /*&& prevTok.Value == ")"*/) {
                    vMod.InOutListEnd = twoPrevTok;
                    vMod.PostHeader = tknzr.Next();
                    twoPrevTok = prevTok;
                    prevTok = (currTok.Value == ")")? currTok : prevTok;
                    currTok = vMod.PostHeader;
                    headerParsed = true;
                }
            }
            vMod.PrevEndModule = prevTok;
            return vMod;
        }

        private void ParseParameter(StringTokenizer tknzr, Dictionary<string, int> parameters) {
            while (true) {
                string paramName = string.Empty, paramVal = string.Empty;
                Token currTok = tknzr.Next();
                while (currTok.Kind != TokenKind.Word && currTok.Kind != TokenKind.EOF)
                    currTok = tknzr.Next();
                paramName = currTok.Value;

                while (currTok.Value != "=" && currTok.Kind != TokenKind.EOF) 
                    currTok = tknzr.Next();
                
                while (true) {
                    currTok = tknzr.Next();
                    if (currTok.Value == "," || currTok.Value == ";")
                        break;
                    if (currTok.Kind == TokenKind.EOF)
                        break;
                    paramVal += currTok.Value;
                }

                if (!string.IsNullOrEmpty(paramName) && !string.IsNullOrEmpty(paramVal)) {
                    try {
                        parameters.Add(paramName, Convert.ToInt32(paramVal));
                    } catch {
                        //Value failed to convert to int, probably in the Verilog bit format (ex: 8'AF)
                        //Abort parameter add
                        //TODO: Handle those Verilog formatted numbers
                        Console.WriteLine("Parameter '" + paramName + "' has an unparsable value of '" + paramVal + "'.");
                    }
                }
                
                if (currTok.Value == ",") {
                    continue;
                } else if (currTok.Value == ";") {
                    break;
                }
            }
        }

        private DffInstance ParseDffInstance(StringTokenizer tknzr, Token possibleParameter,  DFFModule dffType) {
            DffInstance dff = new DffInstance(dffType);
            Token currToken = tknzr.Next();
            dff.ParameterBegin = possibleParameter;
            dff.ParametersExist = false;
            dff.ParametersNamed = false;
            dff.ParamsInParens = false;
            if (currToken.Value == "#") {
                dff.ParametersExist = true;
                dff.ParameterBegin = currToken;
                currToken = tknzr.Next();
                if (currToken.Value == "(") {
                    dff.ParamsInParens = true;
                    dff.ParameterBegin = currToken;
                    Token tempParamList;
                    string paramValue = tknzr.ParseToCloseParenthesis(out tempParamList);
                    dff.ParameterList = tempParamList;
                    dff.ParameterEnd = tempParamList;
                    try {
                        dff.Size = Convert.ToInt32(paramValue);
                    } catch (FormatException) {
                        if (paramValue.StartsWith("`")) {
                            // TODO: Deal with `DEFINE'd values
                            dff.Size = 1;
                        } else if (paramValue.StartsWith(".")) {
                            dff.ParametersNamed = true;
                        } else {
                            dff.ParametersExist = true;
                            dff.IsParameterized = true;
                            dff.Parameter = paramValue;
                            //throw new InvalidDataException("Wah. I don't get it. '" + currToken.Value + "' isn't a number.");
                        }
                    }
                } else {
                    dff.ParameterEnd = currToken;
                    try {
                        dff.Size = Convert.ToInt32(currToken.Value); // In case they use the weird '#12' notation instead of '#(12)'
                    } catch (FormatException) {
                        if (currToken.Value == "`") {
                            // TODO: Deal with `DEFINE'd values
                            dff.Size = 1;
                        } else {
                            throw new InvalidDataException("Wah. I don't get it. '" + currToken.Value + "' isn't a number.");
                        }
                    }
                }

                //tknzr.Next();
                currToken = tknzr.Next();
                dff.InstanceName = currToken.Value;
            } else {
                dff.Size = 1;
                dff.InstanceName = currToken.Value;
            }

            while (currToken.Value != "(") {
                currToken = tknzr.Next();
            }
            //currToken = tknzr.Next();
            dff.PortList = currToken;

            while (dff.ClockPort == null || dff.DPort == null || dff.QPort == null) {
                currToken = tknzr.Next();
                string word = currToken.Value;
                if (word == ";")
                    break;
                if (word == ".") {
                    currToken = tknzr.Next();
                    switch (currToken.Value) {
                        case "clk": {
                                tknzr.Next();
                                Token tempToken;
                                dff.ClockPort = tknzr.ParseToCloseParenthesis(out tempToken);
                                break;
                            }
                        case "q": {
                                tknzr.Next();
                                Token tempToken;
                                dff.QPort = tknzr.ParseToCloseParenthesis(out tempToken);
                                break;
                            }
                        case "din": {
                                tknzr.Next();
                                Token tempToken;
                                dff.DPort = tknzr.ParseToCloseParenthesis(out tempToken);
                                break;
                            }
                    }
                }
            }
            while (currToken.Value != ";" && currToken.Kind != TokenKind.EOF) {
                currToken = tknzr.Next();
            }
            return dff;
        }

        private void AssignDffErrorIds(VerilogModule vMod) {
            int i = 0;
            foreach (DffInstance dff in vMod.LocalDffs) {
                dff.ErrorId = i;
                i++;
            }
        }

        public VerilogModuleInstance ParseModuleInstance(VerilogModule parent, StringTokenizer tknzr, Token possibleParamList, VerilogModule modInstType) {
            string instName;
            Token paramListBegin = possibleParamList;//tknzr.Next();
            bool paramExists = false;
            bool paramsNamed = false;
            string word = tknzr.Next().Value;
            if (word == "#") {
                // Run through parameter lists until parens all closed
                paramExists = true;
                //paramListBegin = 
                tknzr.Next(); // after "#("
                int parenPairs = 1;
                while (parenPairs > 0) {
                    word = tknzr.Next().Value;
                    if (word.Contains("."))
                        paramsNamed = true;
                    if (word == "(") {
                        parenPairs++;
                    } else if (word == ")") {
                        parenPairs--;
                    }
                }
                instName = tknzr.Next().Value;
            } else {
                instName = word;
            }

            if (instName.Contains("st4_rrobin") || parent.Name == "lsu_rrobin_picker2")
                Console.Write("pOOp");

            Token currTok = tknzr.Next();
            Token prevTok = currTok;
            Token twoPrevTok = currTok;
            while (currTok.Value != ";") {
                // Run through in/out list to end of instantiation
                twoPrevTok = prevTok;   // At ')'
                prevTok = currTok;      // At ';'
                currTok = tknzr.Next(); // After ';'
            }
            VerilogModuleInstance vModInst = modInstType.Instantiate(parent, instName, twoPrevTok);
            vModInst.ParameterList = paramListBegin;
            vModInst.Parameterized = paramExists;
            vModInst.ParametersNamed = paramsNamed;
            return vModInst;
        }

        public void ParseDFFLibrary(string filename) {
            VerilogFile dffLibrary = Parse(filename);
            DffImportDialog did = new DffImportDialog();
            foreach (DFFModule dff in did.Import(dffLibrary)) {
                project.AddDffToLibrary(dff);
            }
        }
    }
}
