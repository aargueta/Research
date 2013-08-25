using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Ader.Text;

namespace ShadowSnapshot {
    class DFFModule {

        public string name;
        public string qName;
        public int numDFFs;

        static public DFFModule ParseDFF(StringTokenizer tok) {
            DFFModule dff = new DFFModule();
            while (true) {
                Token currToken = tok.Next();
                string word = currToken.Value;

                if (word == "#") {
                    tok.Next();
                    currToken = tok.Next();
                    word = currToken.Value;
                    dff.numDFFs = Convert.ToInt32(word);

                    tok.Next();
                    currToken = tok.Next();
                    dff.name = currToken.Value;
                    continue;
                } else {
                    dff.name = word;
                }

                if (word == ".") {
                    currToken = tok.Next();
                    if (currToken.Value == "q") {
                        tok.Next();
                        currToken = tok.Next();
                        dff.qName = currToken.Value;
                        if (currToken.Value == "{") {
                            while (currToken.Value != "}") {
                                currToken = tok.Next();
                                dff.qName += currToken.Value;
                            }
                        }
                        break;
                    }
                }
            }
            if (dff.numDFFs == 0) dff.numDFFs = 1;
            return dff;
        }

        static public List<Token> ParseModuleHeader(StringTokenizer tok) {
            List<Token> bkmrks = new List<Token>();
            Token currToken = null;
            Token prevToken = new Token(TokenKind.Unknown, "", 0, 0, 0);
            while (true) {
                if (currToken == null) {
                    bkmrks.Add(tok.Next());
                }
                currToken = tok.Next();
                if (currToken.Kind == TokenKind.EOF) {
                    return null;
                }else if (currToken.Value == ";" && prevToken.Value == ")") {
                    bkmrks.Add(prevToken);
                }else if (currToken.Value == "input" && prevToken.Kind == TokenKind.EOL) {
                    bkmrks.Add(prevToken);
                    return bkmrks;
                }
                prevToken = currToken;
            }
        }
    }
}
