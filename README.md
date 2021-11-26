# Projekt_im_Bachelor_Künstliche_Intelligenz

Für das "Praktikum: Fortgeschrittenenprojekt / Projekt im Bachelor Künstliche Intelligenz", im WS21/22
Veranstaltungsnummer 	W 1305


### Running the server

You can run the server directly through the file server-[version]-jar-with-dependencies.jar without the need for additional shell scripts.

The standard command for that would be

java -jar server-[version]-jar-with-dependencies.jar

Make sure that the conf folder is located in your current working directory, when you execute that command.

You may also directly pass a configuration file to the java command with the -conf [conf-file] parameter. Also, you can pass a complete configuration string value to the command with the -confString [conf-string] option.

To enable the web monitor (to view what's happening), you need to call the server with the --monitor option. The monitor will be available at http://localhost:8000/ by default.
