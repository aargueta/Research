/********************************************************
 *	Author: Andrew Deren
 *	Date: July, 2004
 *	http://www.adersoftware.com
 * 
 *	StringTokenizer class. You can use this class in any way you want
 * as long as this header remains in this file.
 * 
 **********************************************************/

using System;

namespace Ader.Text
{
	public enum TokenKind
	{
		Unknown,
		Word,
		Number,
		QuotedString,
		WhiteSpace,
		Symbol,
		EOL,
		EOF
	}

	public class Token
	{
		int line;
		int column;
        int pos;
		string value;
		TokenKind kind;

		public Token(TokenKind kind, string value, int line, int column, int pos)
		{
			this.kind = kind;
			this.value = value;
			this.line = line;
			this.column = column;
            this.pos = pos;
		}

		public int Column
		{
			get { return this.column; }
		}

		public TokenKind Kind
		{
			get { return this.kind; }
		}

		public int Line
		{
			get { return this.line; }
		}

		public string Value
		{
			get { return this.value; }
		}

        public int Pos {
            get { return this.pos; }
        }
	}

}
