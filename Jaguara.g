grammar Jaguara;

/*---------------- COMPILER INTERNALS ----------------*/

@header {
}

@members {

    public static void main(String[] args) throws Exception
    {
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        JaguaraLexer lexer = new JaguaraLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        JaguaraParser parser = new JaguaraParser(tokens);

        //symbol_table = new ArrayList<String>();        
        parser.program();
        //System.out.println("symbols: " + symbol_table);
    }
}

/*---------------- LEXER RULES ----------------*/

PLUS: '+';
MINUS: '-';
TIMES: '*';
OVER: '/';
REMAINDER: '%';
OPEN_C: '{';
CLOSE_C: '}';
OPEN_P: '(';
CLOSE_P: ')';
ATTRIB: '=';

FUNC: 'function';
MAIN: 'main';
PRINT: 'print';

VAR: 'a' ..'z'+;
NUM: '0' ..'9'+;
NL: ('\r')? '\n';
SPACE: (' ' | '\t')+ { skip(); };

/*---------------- PARSER RULES ----------------*/

program: main;

main:
	FUNC MAIN OPEN_P CLOSE_P OPEN_C {
                System.out.println(".source Jaguara.j");
                System.out.println(".class  public Jaguara");
                System.out.println(".super  java/lang/Object\n");
                System.out.println(".method public <init>()V");
                System.out.println("    aload_0");
                System.out.println("    invokenonvirtual java/lang/Object/<init>()V");
                System.out.println("    return");
                System.out.println(".end method\n");
                System.out.println(".method public static main([Ljava/lang/String;)V\n");
            } (statement)* CLOSE_C NL {
                System.out.println("    return");
                System.out.println(".limit stack 10");
                System.out.println(".end method");
            };

statement:
	NL
	| PRINT OPEN_P {   System.out.println("    getstatic java/lang/System/out Ljava/io/PrintStream;");
		} expression CLOSE_P NL {   System.out.println("    invokevirtual java/io/PrintStream/println(I)V\n");  
		};

expression:
	term (
		op = (PLUS | MINUS) term { System.out.println(($op.type == PLUS) ? "    iadd" : "    isub"); 
			}
	)*;

term:
	factor (
		op = (TIMES | OVER) factor { System.out.println(($op.type == TIMES) ? "    imul" : "    idiv"); 
			}
	)*;

factor:
	NUM { System.out.println("    ldc " + $NUM.text); }
	| OPEN_P expression CLOSE_P;

