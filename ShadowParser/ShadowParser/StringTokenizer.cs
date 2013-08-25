/********************************************************8
 *	Author: Andrew Deren
 *	Date: July, 2004
 *	http://www.adersoftware.com
 * 
 *	StringTokenizer class. You can use this class in any way you want
 * as long as this header remains in this file.
 * 
 **********************************************************/
using System;
using System.IO;
using System.Text;

namespace Ader.Text
{
	/// <summary>
	/// StringTokenizer tokenized string (or stream) into tokens.
	/// </summary>
	public class StringTokenizer
	{
		const char EOF = (char)0;

		int line;
		int column;
		int pos;	// position within data

		string data;

		bool ignoreWhiteSpace;
		char[] symbolChars;

		int saveLine;
		int saveCol;
		int savePos;

        public static StringTokenizer TokenizerFromFile(string filename, Token bookmark = null) {
            FileInfo fi;
            StreamReader sr;
            fi = new FileInfo(filename);
            sr = fi.OpenText();
            
            StringTokenizer tknzr = (bookmark == null) ? new StringTokenizer(sr.ReadToEnd()) : new StringTokenizer(sr.ReadToEnd(), bookmark);
            sr.Close();
            tknzr.IgnoreWhiteSpace = true;
            return tknzr;
        }

        public StringTokenizer(StringTokenizer tknzr) {
            this.line = tknzr.line;
            this.column = tknzr.column;
            this.pos = tknzr.pos;
            this.data = tknzr.data;
            this.ignoreWhiteSpace = tknzr.ignoreWhiteSpace;
            this.symbolChars = tknzr.SymbolChars;
            this.saveLine = tknzr.saveLine;
            this.saveCol = tknzr.saveCol;
            this.savePos = tknzr.savePos;
        }

		public StringTokenizer(TextReader reader)
		{
			if (reader == null)
				throw new ArgumentNullException("reader");

			data = reader.ReadToEnd();

			Reset();
		}

		public StringTokenizer(string data)
		{
			if (data == null)
				throw new ArgumentNullException("data");

			this.data = data;

			Reset();
		}

        /// <summary>
        /// Used to restart parsing from a previously stored Token
        /// </summary>
        /// <param name="data">Data originally parsed to produce the bookmark Token</param>
        /// <param name="bookmark">Token used as a bookmark</param>
        public StringTokenizer(string data, Token bookmark) {
            if (data == null)
                throw new ArgumentNullException("data");
            if (bookmark == null)
                throw new ArgumentNullException("bookmark");
            this.data = data;
            Reset();
            this.line = bookmark.Line;
            this.column = bookmark.Column;
            this.pos = bookmark.Pos;
        }

        /// <summary>
        /// Called to get everything within a previously tokenized parenthesis.
        /// </summary>
        /// <returns>String between parent parenthesis</returns>
        public string ParseToCloseParenthesis(out Token endParenToken) {
            int numParens = 1;
            StringBuilder sb = new StringBuilder();
            Token curr = null;
            while (numParens > 0) {
                curr = this.Next();
                if (curr.Value == "(") {
                    numParens++;
                } else if (curr.Value == ")") {
                    numParens--;
                }
                if (numParens <= 0)
                    break;
                sb.Append(curr.Value);
            }
            endParenToken = curr;
            return sb.ToString();
        }

		/// <summary>
		/// gets or sets which characters are part of TokenKind.Symbol
		/// </summary>
		public char[] SymbolChars
		{
			get { return this.symbolChars; }
			set { this.symbolChars = value; }
		}

		/// <summary>
		/// if set to true, white space characters will be ignored,
		/// but EOL and whitespace inside of string will still be tokenized
		/// </summary>
		public bool IgnoreWhiteSpace
		{
			get { return this.ignoreWhiteSpace; }
			set { this.ignoreWhiteSpace = value; }
		}

        public bool JumpToToken(Token bookmark) {
            if (pos <= data.Length) {
                this.column = bookmark.Column;
                this.pos = bookmark.Pos;
                this.line = bookmark.Line;
                return true;
            } else {
                return false;
            }
        }

		private void Reset()
		{
			this.ignoreWhiteSpace = false;
			this.symbolChars = new char[]{'=', '+', '-', '/', ',', '.', '*', '~', '!', '@', '#', '$', '%', '^', '&', '(', ')', '{', '}', '[', ']', ':', ';', '<', '>', '?', '|', '\\'};

			line = 1;
			column = 1;
			pos = 0;
		}

		protected char LA(int count)
		{
			if (pos + count >= data.Length)
				return EOF;
			else
				return data[pos+count];
		}

		protected char Consume()
		{
            if (pos >= data.Length - 1) {
                //Protects against files not ending in EOF
                pos++;
                column++;
                return EOF;
            }
			char ret = data[pos];
			pos++;
			column++;

			return ret;
		}

		protected Token CreateToken(TokenKind kind, string value)
		{
			return new Token(kind, value, line, column, pos);
		}

		protected Token CreateToken(TokenKind kind)
		{
			string tokenData = data.Substring(savePos, pos-savePos);
			return new Token(kind, tokenData, saveLine, saveCol, pos);
		}

		public Token Next()
		{
			ReadToken:
			char ch = LA(0);
			switch (ch)
			{
				case EOF:
					return CreateToken(TokenKind.EOF, string.Empty);

				case ' ':
				case '\t':
				{
					if (this.ignoreWhiteSpace)
					{
						Consume();
						goto ReadToken;
					}
					else
						return ReadWhitespace();
				}
				/*case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					return ReadNumber();*/

				case '\r':
				{
					StartRead();
					Consume();
					if (LA(0) == '\n')
						Consume();	// on DOS/Windows we have \r\n for new line

					line++;
					column=1;

					return CreateToken(TokenKind.EOL);
				}
				case '\n':
				{
					StartRead();
					Consume();
					line++;
					column=1;
					
					return CreateToken(TokenKind.EOL);
				}

				case '"':
				{
					return ReadString();
				}

				default:
				{
                    if (Char.IsLetter(ch) || ch == '_' || Char.IsDigit(ch) || ch == '[' || ch == ':' || ch == ']')
						return ReadWord();
					else if (IsSymbol(ch))
					{
                        if (ch == '/') {
                            if (data[pos+1] == '/') {
                                // Comment line detected
                                Consume();
                                char commentChar = Consume();
                                while (data[pos] != '\n' /*commentChar != '\n'*/ && commentChar != EOF) {
                                    //Read to the end of the line
                                    commentChar = Consume();
                                }
                                //line++;
                                //column = 1;
                                return Next();
                            } else if (data[pos + 1] == '*') {
                                // Comment section detected
                                Consume();
                                char commentChar = Consume();
                                char nextChar = Consume();
                                while(!(commentChar == '*' && nextChar == '/')){
                                    //Read to the end of the commented section
                                    commentChar = nextChar;
                                    if (commentChar == '\n' ) {
                                        line++;
                                        column = 1;
                                    }
                                    nextChar = Consume();
                                    if (nextChar == EOF)
                                        break;
                                }
                                return Next();
                            }
                            StartRead();
                            Consume();
                            return CreateToken(TokenKind.Symbol);
                        } else {
                            StartRead();
                            Consume();
                            return CreateToken(TokenKind.Symbol);
                        }
					}
					else
					{
						StartRead();
						Consume();
						return CreateToken(TokenKind.Unknown);						
					}
				}

			}
		}

		/// <summary>
		/// save read point positions so that CreateToken can use those
		/// </summary>
		private void StartRead()
		{
			saveLine = line;
			saveCol = column;
			savePos = pos;
		}

		/// <summary>
		/// reads all whitespace characters (does not include newline)
		/// </summary>
		/// <returns></returns>
		protected Token ReadWhitespace()
		{
			StartRead();

			Consume(); // consume the looked-ahead whitespace char

			while (true)
			{
				char ch = LA(0);
				if (ch == '\t' || ch == ' ')
					Consume();
				else
					break;
			}

			return CreateToken(TokenKind.WhiteSpace);
			
		}

		/// <summary>
		/// reads number. Number is: DIGIT+ ("." DIGIT*)?
		/// </summary>
		/// <returns></returns>
		protected Token ReadNumber()
		{
			StartRead();

			bool hadDot = false;

			Consume(); // read first digit

			while (true)
			{
				char ch = LA(0);
				if (Char.IsDigit(ch))
					Consume();
				else if (ch == '.' && !hadDot)
				{
					hadDot = true;
					Consume();
				}
				else
					break;
			}

			return CreateToken(TokenKind.Number);
		}

		/// <summary>
		/// reads word. Word contains any alpha character or _
		/// </summary>
		protected Token ReadWord()
		{
			StartRead();

			Consume(); // consume first character of the word

			while (true)
			{
				char ch = LA(0);
                if (Char.IsLetter(ch) || ch == '_' || Char.IsDigit(ch) || ch == ':')// || ch == '[' || ch == ']')
					Consume();
				else
					break;
			}

			return CreateToken(TokenKind.Word);
		}

		/// <summary>
		/// reads all characters until next " is found.
		/// If "" (2 quotes) are found, then they are consumed as
		/// part of the string
		/// </summary>
		/// <returns></returns>
		protected Token ReadString()
		{
			StartRead();

			Consume(); // read "

			while (true)
			{
				char ch = LA(0);
				if (ch == EOF)
					break;
				else if (ch == '\r')	// handle CR in strings
				{
					Consume();
					if (LA(0) == '\n')	// for DOS & windows
						Consume();

					line++;
					column = 1;
				}
				else if (ch == '\n')	// new line in quoted string
				{
					Consume();

					line++;
					column = 1;
				}
				else if (ch == '"')
				{
					Consume();
					if (LA(0) != '"')
						break;	// done reading, and this quotes does not have escape character
					else
						Consume(); // consume second ", because first was just an escape
				}
				else
					Consume();
			}

			return CreateToken(TokenKind.QuotedString);
		}

		/// <summary>
		/// checks whether c is a symbol character.
		/// </summary>
		protected bool IsSymbol(char c)
		{
			for (int i=0; i<symbolChars.Length; i++)
				if (symbolChars[i] == c)
					return true;

			return false;
		}
	}
}
