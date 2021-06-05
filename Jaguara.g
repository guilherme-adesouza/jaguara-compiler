grammar Jaguara;

/*---------------- COMPILER INTERNALS ----------------*/

@header {
import java.util.ArrayList;
}

@members {
    private static ArrayList<String> symbol_table;
    private static ArrayList<Character> type_table;

    private static int stack_cur = 1;
    private static int stack_max = 1;

    private static boolean has_error;
    private static int if_count = 0;
    private static int while_count = 0;

    public static void emit(String bytecode, int delta) {
        System.out.println("    " + bytecode);
        stack_cur += delta;
        if (stack_cur > stack_max) {
            stack_max = stack_cur;
        }
    }

    public static void main(String[] args) throws Exception
    {
        ANTLRInputStream input = new ANTLRInputStream(System.in);
        JaguaraLexer lexer = new JaguaraLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        JaguaraParser parser = new JaguaraParser(tokens);

        symbol_table = new ArrayList<String>();
        type_table = new ArrayList<Character>();

        has_error = false;

        parser.program();

        if (has_error == true) {
            System.err.println("Errors found!");
            System.exit(1);
        }
    }
}

/*---------------- LEXER RULES ----------------*/

PLUS     : '+';
MINUS    : '-';
TIMES    : '*';
OVER     : '/';
REMAINDER: '%';

OPEN_C : '{';
CLOSE_C: '}';
OPEN_P : '(';
CLOSE_P: ')';
ATTRIB : '=';
SEMI_C : ';';

EQ: '==' ;
NE: '!=' ;
GT: '>'  ;
GE: '>=' ;
LT: '<'  ;
LE: '<=' ;

FUNC   : 'function';
MAIN   : 'main';
PRINT  : 'print';
IF     : 'if';
ELSE   : 'else';
WHILE  : 'while';

VAR    : 'a' ..'z'+;
STRING : '"' ~["]* '"';
NUMBER : '0' ..'9'+;
NL     : ('\r')? '\n';
SPACE  : (' ' | '\t')+ { skip(); };

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

statement: NL | st_print | st_if | st_attrib | st_while;

st_print:
    PRINT OPEN_P
    {
        emit("    getstatic java/lang/System/out Ljava/io/PrintStream;", -1);
    } expression CLOSE_P NL
    {
        emit("    invokevirtual java/io/PrintStream/println(I)V\n", -1);
	};

st_if:
    {
        if_count++;
        int if_local = if_count;
    }
    IF OPEN_P comparison_if CLOSE_P OPEN_C (statement) + CLOSE_C
    { emit("NOT_IF_" + if_local + ":", -1); }
    ;

comparison_if:
    e1 = expression op = (EQ | NE | GT | GE | LT | LE) e2 = expression
    {
        if ($e1.type == 'l' || $e2.type == 'l') {
            System.err.println("Error: cannot use List without index.");
            has_error = true;
        }

        if ($e1.type != $e2.type) {
            System.err.println("Error: impossible to compare different types.");
            has_error = true;
        }

        if ($op.type == EQ) { emit("\nif_icmpne NOT_IF_" + if_count, - 2); }
        else if ($op.type == NE) { emit("\nif_icmpeq NOT_IF_" + if_count, - 2); }
        else if ($op.type == GT) { emit("\nif_icmple NOT_IF_" + if_count, - 2); }
        else if ($op.type == GE) { emit("\nif_icmplt NOT_IF_" + if_count, - 2); }
        else if ($op.type == LT) { emit("\nif_icmpge NOT_IF_" + if_count, - 2); }
        else if ($op.type == LE) { emit("\nif_icmpgt NOT_IF_" + if_count, - 2); }
    }
    ;

st_attrib:
    VAR ATTRIB e = expression SEMI_C
    {
        if (!symbol_table.contains($VAR.text)) {
            symbol_table.add($VAR.text);
            type_table.add($e.type);
        } else {
            if (type_table.get(symbol_table.indexOf($VAR.text)) != $e.type) {
               System.err.println("Error: impossible to change variable type.");
               has_error = true;
            }
        }

        if ($e.type == 'i') {
            emit("istore " + symbol_table.indexOf($VAR.text), - 1);
        } else {
            emit("astore " + symbol_table.indexOf($VAR.text), - 1);
        }
    }
    ;

st_while:
    {
        while_count++;
        int while_local = while_count;
    }
    { emit("BEGIN_WHILE_" + while_local + ":", -1); }

    WHILE OPEN_P comparison_while CLOSE_P OPEN_C (statement) + CLOSE_C
    {
        emit("    goto BEGIN_WHILE_" + while_local, 1);
        emit("NOT_WHILE_" + while_local + ":", -1);
    }
    ;

comparison_while:
    e1 = expression
    op = (EQ | NE | GT | GE | LT | LE)
    e2 = expression
    {
        if ($e1.type == 'l' || $e2.type == 'l') {
            System.err.println("Error: cannot use List without index.");
            has_error = true;
        }

        if ($e1.type != $e2.type) {
            System.err.println("Error: impossible to compare different types.");
            has_error = true;
        }

        if ($op.type == EQ) { emit("\nif_icmpne NOT_WHILE_" + while_count, - 2); }
        else if ($op.type == NE) { emit("\nif_icmpeq NOT_WHILE_" + while_count, - 2); }
        else if ($op.type == GT) { emit("\nif_icmple NOT_WHILE_" + while_count, - 2); }
        else if ($op.type == GE) { emit("\nif_icmplt NOT_WHILE_" + while_count, - 2); }
        else if ($op.type == LT) { emit("\nif_icmpge NOT_WHILE_" + while_count, - 2); }
        else if ($op.type == LE) { emit("\nif_icmpgt NOT_WHILE_" + while_count, - 2); }
    }
    ;

expression returns [char type]:
    t1 = term ( op = ( PLUS | MINUS ) t2 = term
    {
        if ($t1.type != 'i' || $t2.type != 'i') {
            System.err.println("Error: impossible to compare different types.");
            has_error = true;
        }
        emit(($op.type == PLUS) ? "    iadd" : "    isub", - 1);
    }
    )*
    { $type = $t1.type; }
    ;

term returns [char type]:
    f1 = factor ( op = ( TIMES | OVER | REMAINDER ) f2 = factor
    {
        if ($f1.type != 'i' || $f2.type != 'i') {
            System.err.println("Error: impossible to compare different types.");
            has_error = true;
        }

        if ($op.type == TIMES)     { emit("imul", - 1); }
        else if ($op.type == OVER) { emit("idiv", - 1); }
        else                       { emit("irem", - 1); }
    }
    )*
    { $type = $f1.type; }
    ;

factor returns [char type]:
    NUMBER
    {
       emit("ldc " + $NUMBER.text, + 1);
       $type = 'i';
    }
    |  STRING
        {
            emit("ldc " + $STRING.text, + 1);
            $type = 'a';
        }
    | OPEN_P expression CLOSE_P;

