#!/bin/dash

java -jar ./lib/antlr-4.5.3.jar Jaguara.g
javac -cp ./lib/antlr-4.5.3.jar Jaguara*.java
java -cp ./lib/antlr-4.5.3.jar:. JaguaraParser < Main.jaguara > Main.j
java -jar ./lib/jasmin-2.4.jar Main.j
java Jaguara