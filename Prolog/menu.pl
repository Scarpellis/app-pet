:- use_module("cliente").

main :- 
	apresentacao, 
	mostraMenu, nl.
	
apresentacao :- 
	writeln("Bem-vindo ao sistema do PETSHOP!"), nl.

mostraMenu :- 
	writeln("Selecione uma das opções abaixo:"),
	writeln("1 - Sou Administrador"),
	writeln("2 - Sou Cliente"),
	writeln("3 - Encerrar programa"),
	read_line_to_string(user_input, Option),
	(Option == "2" -> menuCliente;
	Option == "3" -> sair;
	opcaoInvalida,
	mostraMenu, nl, halt).

menuCliente :-
	writeln("Selecione uma das opções abaixo:"),
	writeln("1 - Se cadastrar como cliente"),
	writeln("2 - Logar no sistema como cliente"),
	writeln("0 - Retornar ao menu principal"),
	read_line_to_string(user_input, Option),
	(Option == "1" -> cliente:cadastraCliente, menuCliente;
	Option == "2" -> (cliente:login_cliente(Email) -> segundoMenuCliente(Email) ; mostraMenu);
	Option == "0" -> mostraMenu;
	opcaoInvalida,
	menuCliente).

segundoMenuCliente(Email) :-
	writeln("Selecione uma das opções abaixo:"),
	writeln("1 - Cadastrar um animal"),
	writeln("0 - Retornar ao menu principal"),
	read_line_to_string(user_input, Option),
	(Option == "1" -> (cliente:cadastraAnimal(Email), segundoMenuCliente(Email));
	Option == "0" -> mostraMenu;
	opcaoInvalida,
	segundoMenuCliente).

sair :- halt.

opcaoInvalida :-
	 writeln("Opcao invalida!"), nl.