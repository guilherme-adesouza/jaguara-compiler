# jaguara-compiler
Compiler for Jaguara language for the Compilers class

# Run project

`./compile.sh`

### WTF compile.sh do?

This executes a script that compile `Jaguara.g` file with [ANTLR](https://github.com/antlr/antlr4), generating the ANTLR files following:

- JaguaraBaseListener.java
- JaguaraLexer.java
- JaguaraListener.java
- JaguaraParser.java
- JaguaraLexer.tokens

These Java files are compiled by ANTLR in the script, making it possible to create a "Jaguara code" and compile.

After this, the Java Assembler [Jasmin](https://github.com/davidar/jasmin) to convert ANTLR code into JVM code.

Finally, the Jaguara.class code is available to execute and produce our code!
