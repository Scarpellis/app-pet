{-# OPTIONS_GHC -Wno-incomplete-patterns #-}

import Control.Applicative ()
import Control.Exception ()
import Control.Monad
import qualified Data.ByteString.Char8 as B
import Data.Char ()
import Data.List ()
import Data.Time.Clock ()
import Distribution.PackageDescription (CondTree (condTreeComponents))
import System.Directory (doesFileExist, removeFile)
import System.Exit (exitSuccess)
import System.IO
  ( IO,
    IOMode (ReadMode, ReadWriteMode, WriteMode),
    getLine,
    hClose,
    hFlush,
    hGetContents,
    hGetLine,
    hPutStr,
    hPutStrLn,
    openFile,
    putStrLn,
  )
import System.IO.Error ()
import Prelude hiding (catch)

data Animal = Animal
  { nomeAnimal :: String,
    emailCliente :: String,
    especie :: String,
    peso :: String,
    altura :: String,
    idade :: String
  }
  deriving (Read, Show)

data Cliente = Cliente
  { nomeCliente :: String,
    email :: String,
    senha :: String,
    telefone :: String
  }
  deriving (Read, Show)

data Agendamento = Agendamento
  { date :: String,
    servicos :: [String],
    concluido :: Bool,
    animal :: String
  }
  deriving (Read, Show)

obterCliente :: Cliente -> String -> String
obterCliente Cliente {nomeCliente = n, email = e, senha = s, telefone = t} prop
  | prop == "nomeCliente" = n
  | prop == "email" = e
  | prop == "senha" = s
  | prop == "telefone" = t

editCliente :: Cliente -> Animal -> Cliente
editCliente Cliente {nomeCliente = n, email = e, senha = s, telefone = t} a = Cliente {nomeCliente = n, email = e, senha = s, telefone = t}

obterAnimal :: Animal -> String -> String
obterAnimal Animal {nomeAnimal = n, emailCliente = ec, especie = e, peso = p, altura = a, idade = i} prop
  | prop == "nomeAnimal" = n
  | prop == "emailCliente" = ec
  | prop == "especie" = e
  | prop == "peso" = p
  | prop == "altura" = a
  | prop == "idade" = i

main :: IO ()
main = do
  putStrLn "Boas vindas!"
  putStrLn "Selecione uma das opções abaixo:\n"
  showMenu

showMenu :: IO ()
showMenu = do
  putStrLn "\nSelecione uma das opções abaixo:\n"

  putStrLn "1 - Sou Administrador"
  putStrLn "2 - Sou Cliente"
  putStrLn "3 - Sair"

  opcao <- getLine
  menus opcao

menus :: String -> IO ()
menus x
  | x == "1" = menuAdm
  | x == "2" = menuCliente
  | x == "3" = encerrarSessao
  | otherwise = invalidOption showMenu

encerrarSessao :: IO ()
encerrarSessao = putStrLn "Saindo... Até a próxima!"

invalidOption :: IO () -> IO ()
invalidOption f = do
  putStrLn "Selecione uma alternativa válida"
  f

menuAdm :: IO ()
menuAdm = do
  putStrLn "\nSelecione uma das opções abaixo:"
  putStrLn "1 - Ver usuários cadastrados no sistema"
  putStrLn "2 - Remover usuários"
  putStrLn "3 - Alterar disponibilidade hotelzinho"
  putStrLn "4 - listar resumo de atendimentos"
  putStrLn "5 - Atualizar contato Adm"
  putStrLn "6 - Voltar"
  opcao <- getLine
  opcaoAdm opcao

opcaoAdm :: String -> IO ()
opcaoAdm x
  | x == "1" = verClientesCadastrados
  | x == "2" = removerCliente
  | x == "3" = alterarDisponibilidadeHotelzinho
  | x == "4" = listarResumoDeAtendimentos
  | x == "5" = atualizarContatoAdm
  | x == "6" = showMenu
  | otherwise = invalidOption menuAdm

listarResumoDeAtendimentos :: IO ()
listarResumoDeAtendimentos = do
  file <- openFile "agendamentos.txt" ReadMode
  contents <- hGetContents file
  print (show contents)

alterarDisponibilidadeHotelzinho :: IO ()
alterarDisponibilidadeHotelzinho = do
  putStrLn "\nSelecione qual a disponibilidade do hotelzinho neste momento:"
  putStrLn "1 - Hotelzinho está disponível"
  putStrLn "2 - Hotelzinho NÃO está disponível"

  opcao <- getLine
  opcaoHotelzinho opcao

opcaoHotelzinho :: String -> IO ()
opcaoHotelzinho x
  | x == "1" = ativaHotelzinho
  | x == "2" = desativaHotelzinho
  | otherwise = invalidOption alterarDisponibilidadeHotelzinho

ativaHotelzinho :: IO ()
ativaHotelzinho = do
  file <- openFile "hotelzinho.txt" WriteMode
  hPutStr file "disponível"
  hClose file
  putStrLn "Hotelzinho foi configurado como disponível"
  menuAdm

desativaHotelzinho :: IO ()
desativaHotelzinho = do
  file <- openFile "hotelzinho.txt" WriteMode
  hPutStr file "indisponível"
  hClose file
  putStrLn "Hotelzinho foi configurado como indisponível"
  menuAdm

atualizarContatoAdm :: IO ()
atualizarContatoAdm = do
  putStrLn "\nTem certeza que deseja atualizar o contato do Administrador?"
  putStrLn "\n--Aperte 1 para continuar--"
  opcao <- getLine
  opcaoContato opcao

opcaoContato :: String -> IO ()
opcaoContato x
  | x == "1" = mudaContato
  | otherwise = invalidOption menuAdm

mudaContato :: IO ()
mudaContato = do
  putStrLn "\nInsira o novo número para contato abaixo"

  numero <- getLine
  file <- openFile "contato.txt" WriteMode
  hPutStr file numero
  hClose file
  putStrLn "\nContato atualizado com sucesso!"
  menuAdm

menuCliente :: IO ()
menuCliente = do
  putStrLn "\nSelecione uma das opções abaixo:"
  putStrLn "1 - Se cadastrar como cliente"
  putStrLn "2 - Logar no sistema como cliente"
  putStrLn "3 - Ver contato do administrador"
  putStrLn "4 - Voltar ao menu principal"
  opcao <- getLine
  opcaoCliente opcao

opcaoCliente :: String -> IO ()
opcaoCliente x
  | x == "1" = cadastrarComoCliente
  | x == "2" = logarComoCliente
  | x == "3" = verContatoDoAdministrador
  | x == "4" = showMenu
  | otherwise = invalidOption menuCliente

segundoMenuCliente :: String -> IO ()
segundoMenuCliente email = do
  putStrLn "\nSelecione o que deseja como cliente"
  putStrLn "1 - Cadastrar um novo animal"
  putStrLn "2 - Listar animais cadastrados"
  putStrLn "3 - Acessar Hotelzinho Pet"
  putStrLn "4 - Remover um animal"
  putStrLn "x - Retornar para o menu\n"

  opcao <- getLine
  segundaTelaCliente opcao email

segundaTelaCliente :: String -> String -> IO ()
segundaTelaCliente x email
  | x == "1" = cadastraAnimal email
  | x == "2" = listarAnimais email
  | x == "3" = menuHotelzinhoPet
  | x == "4" = removerAnimal email
  | otherwise = invalidOption menuCliente

indexCliente :: [Cliente] -> String -> Int -> Int
indexCliente (c : cs) email i
  | obterCliente c "email" == email = i
  | obterCliente c "email" /= email = next
  where
    next = indexCliente cs email (i + 1)

converterEmAnimal a = read a :: Animal

listarAnimais :: String -> IO ()
listarAnimais emailCliente = do
  file <- openFile "animais.txt" ReadMode
  contents <- hGetContents file

  let animaisStr = lines contents
  let animais = map converterEmAnimal animaisStr

  mostrarAnimaisDoCliente emailCliente animais
  showMenu

mostrarAnimaisDoCliente :: String -> [Animal] -> IO ()
mostrarAnimaisDoCliente emailCliente [] = do
  putStrLn ""
mostrarAnimaisDoCliente emailCliente (a : as) = do
  if obterAnimal a "emailCliente" /= emailCliente
    then do
      mostrarAnimaisDoCliente emailCliente as
    else do
      putStrLn ("Nome: " ++ obterAnimal a "nomeAnimal")
      putStrLn ("Especie: " ++ obterAnimal a "especie")
      putStrLn ("Peso: " ++ obterAnimal a "peso")
      putStrLn ("Altura: " ++ obterAnimal a "altura")
      putStrLn ("Idade: " ++ obterAnimal a "idade" ++ "\n")
      mostrarAnimaisDoCliente emailCliente as

toStringListCliente :: [Cliente] -> String
toStringListCliente (x : xs) = show x ++ "\n" ++ toStringListCliente xs
toStringListCliente [] = ""

toCliente c = read c :: Cliente

toObjListCliente :: [String] -> [Cliente]
toObjListCliente = map toCliente

cadastraAnimal :: String -> IO ()
cadastraAnimal email = do
  putStrLn "\nInsira o nome do animal: "
  nome <- getLine
  putStrLn "\nInsira a especie do animal: "
  especie <- getLine
  putStrLn "\nInsira a altura do animal: "
  altura <- getLine
  putStrLn "\nInsira o peso do animal: "
  peso <- getLine
  putStrLn "\nInsira o idade do animal: "
  idade <- getLine
  putStrLn ""

  let animal = Animal {nomeAnimal = nome, emailCliente = email, peso = peso, altura = altura, especie = especie, idade = idade}

  appendFile "animais.txt" (show animal ++ "\n")

  putStrLn "\nAnimal Cadastrado com sucessos!\n"
  showMenu

imprimeClientesCadastrados :: [Cliente] -> Int -> IO ()
imprimeClientesCadastrados [] 0 = putStrLn "Nenhum cliente cadastrado"
imprimeClientesCadastrados [] _ = putStrLn "Clientes listados com sucesso"
imprimeClientesCadastrados (x : xs) n = do
  putStrLn (show n ++ " - " ++ obterNomes x)
  imprimeClientesCadastrados xs (n + 1)

verClientesCadastrados :: IO ()
verClientesCadastrados = do
  file <- openFile "clientes.txt" ReadMode
  contents <- hGetContents file
  let clientes = lines contents
  imprimeClientesCadastrados [read x :: Cliente | x <- clientes] 0

removerCliente :: IO ()
removerCliente = do
  clientesCadastrados <- doesFileExist "clientes.txt"
  if not clientesCadastrados
    then do
      putStrLn "Não há clientes cadastrados!"
    else do
      putStr "\nInsira o email do cliente a ser removido: "
      email <- getLine

      file <- openFile "clientes.txt" ReadMode
      clientesContent <- hGetContents file
      let clientes = lines clientesContent
      let hasCliente = encontraCliente [read x :: Cliente | x <- clientes] email ""

      if not hasCliente
        then do
          putStrLn ("\nCliente com email: '" ++ email ++ "' não existe!")
        else do
          removeFile "clientes.txt"
          let novaListaDeClientes = [read x :: Cliente | x <- clientes, obterEmail (read x :: Cliente) /= email]
          atualizaClientes novaListaDeClientes

  showMenu

atualizaClientes :: [Cliente] -> IO ()
atualizaClientes [] = putStrLn "Cliente removido com sucesso!\n"
atualizaClientes (x : xs) = do
  clientesCadastrados <- doesFileExist "clientes.txt"
  if not clientesCadastrados
    then do
      file <- openFile "clientes.txt" WriteMode
      hPutStr file (show x)
      hFlush file
      hClose file
    else appendFile "clientes.txt" ("\n" ++ show x)
  atualizaClientes xs

obterEmail :: Cliente -> String
obterEmail Cliente {nomeCliente = c, email = e, senha = s, telefone = t} = e

obterSenha :: Cliente -> String
obterSenha (Cliente _ _ senha _) = senha

obterNomes :: Cliente -> String
obterNomes (Cliente nomeCliente _ _ _) = nomeCliente

encontraCliente :: [Cliente] -> String -> String -> Bool
encontraCliente [] email senha = False
-- Procura Cliente somente verificando o email
encontraCliente (c : cs) email ""
  | obterCliente c "email" == email = True
  | obterCliente c "email" /= email = encontrar
  where
    encontrar = encontraCliente cs email ""
-- Procura Cliente verificando o email e a senha
encontraCliente (c : cs) email senha
  | obterCliente c "email" == email && obterCliente c "senha" == senha = True
  | obterCliente c "email" /= email || obterCliente c "senha" /= senha = encontrar
  where
    encontrar = encontraCliente cs email senha

encontraAnimal :: [Animal] -> String -> String -> Bool
encontraAnimal [] nome emailDonoDoAnimal = False
encontraAnimal (c : cs) nome emailDonoDoAnimal
  | obterAnimal c "nomeAnimal" == nome && obterAnimal c "emailCliente" == emailDonoDoAnimal = True
  | not (obterAnimal c "nomeAnimal" == nome && obterAnimal c "emailCliente" == emailDonoDoAnimal) = encontrar
  where
    encontrar = encontraAnimal cs nome emailDonoDoAnimal

cadastrarComoCliente :: IO ()
cadastrarComoCliente = do
  putStrLn "\nInsira seu nome:"
  nome <- getLine

  putStrLn "Insira seu email:"
  email <- getLine

  putStrLn "Insira sua senha:"
  senha <- getLine

  putStrLn "Insira seu telefone:"
  telefone <- getLine

  putStrLn ""

  fileExists <- doesFileExist "clientes.txt"
  if fileExists
    then do
      file <- openFile "clientes.txt" ReadMode
      contents <- hGetContents file
      let clientes = lines contents
      let hasThisClient = encontraCliente ([read x :: Cliente | x <- clientes]) email ""

      if hasThisClient
        then do
          putStrLn "Usuario ja existente"
          showMenu
        else do
          criarCliente nome email senha telefone
    else do
      criarCliente nome email senha telefone

criarCliente :: String -> String -> String -> String -> IO ()
criarCliente nome email senha telefone = do
  let cliente = Cliente {nomeCliente = nome, email = email, senha = senha, telefone = telefone}
  file <- appendFile "clientes.txt" (show cliente ++ "\n")
  putStrLn "\nCliente cadastrado com sucesso!"
  putStrLn ""
  showMenu

logarComoCliente :: IO ()
logarComoCliente = do
  putStrLn "Insira seu email"
  email <- getLine
  fileExists <- doesFileExist "clientes.txt"

  if fileExists
    then do
      putStrLn "Insira sua senha"
      senha <- getLine
      file <- openFile "clientes.txt" ReadMode
      contents <- hGetContents file
      let clientes = lines contents
      let hasCliente = encontraCliente [read x :: Cliente | x <- clientes] email senha

      if hasCliente
        then do
          putStrLn "Login realizado com sucesso"
          segundoMenuCliente email
        else do
          putStrLn "Nome ou senha incorretos"
          menuCliente
      hClose file
    else do
      putStrLn "Nenhum cliente não cadastrado. Por favor, cadastre-se"
      cadastrarComoCliente

menuHotelzinhoPet :: IO ()
menuHotelzinhoPet = do
  putStrLn "O Hotelzinho Pet é o serviço de hospedagem de animaizinhos!"
  putStrLn "Você deseja hospedar algum animalzinho no nosso serviço?"
  putStrLn "1 - Agendar animal"
  putStrLn "Caso não tenha interesse, prima qualquer outra tecla"

  opcao <- getLine
  segundaOpcaoHotelzinho opcao

segundaOpcaoHotelzinho :: String -> IO ()
segundaOpcaoHotelzinho x
  | x == "1" = agendaHotelzinho
  | otherwise = invalidOption menuAdm

agendaHotelzinho :: IO ()
agendaHotelzinho = do
  file <- openFile "agendamentos.txt" ReadMode
  disponibilidade <- hGetContents file

  if disponibilidade == "disponível"
    then do
      file <- openFile "hotelzinho.txt" WriteMode
      putStrLn "\nInsira a especie do animalzinho a ser hospedado: "
      especie <- getLine
      putStrLn "\nInsira o nome do animalzinho "
      nome <- getLine
      putStrLn "\nQual o período de tempo que o animalzinho vai ficar hospedado?: "
      tempo <- getLine
      file <- appendFile "animais.txt" "especie: "
      file <- appendFile "animais.txt" especie
      file <- appendFile "animais.txt" "; "
      file <- appendFile "animais.txt" "nome: "
      file <- appendFile "animais.txt" nome
      file <- appendFile "animais.txt" "; "
      file <- appendFile "animais.txt" "período de tempo: "
      file <- appendFile "animais.txt" tempo
      file <- appendFile "animais.txt" "\n"
      putStrLn "\nAnimal agendado com sucesso"
      putStrLn ""
      showMenu
    else do
      putStrLn "Infelizmente o serviço de hotelzinho não está disponível para receber animaizinhos no momento."

      putStrLn "Cliente não cadastrado."
      putStrLn "Deseja fazer o cadastro agora? (s/n):"
      op <- getLine
      if op == "s"
        then do
          cadastrarComoCliente
        else menuCliente

verContatoDoAdministrador :: IO ()
verContatoDoAdministrador = do
  file <- openFile "contato.txt" ReadMode
  contato <- hGetContents file
  putStrLn contato

  showMenu

removerAnimal :: String -> IO ()
removerAnimal emailDonoDoAnimal = do
  clientesCadastrados <- doesFileExist "animais.txt"
  if not clientesCadastrados
    then do
      putStrLn "Não há animais cadastrados!"
    else do
      putStr "\nInsira o nome do animal a ser removido: "
      nomeAnimal <- getLine

      animaisContent <- readFile "animais.txt"
      let animais = lines animaisContent
      let hasAnimal = encontraAnimal [read x :: Animal | x <- animais] nomeAnimal emailDonoDoAnimal

      if not hasAnimal
        then do
          putStrLn ("\nAnimal de nome: '" ++ nomeAnimal ++ "' não existe!")
        else do
          removeFile "animais.txt"
          let novaListaDeAnimais = [read x :: Animal | x <- animais, not (encontrarAnimalASerRemovido (read x :: Animal) nomeAnimal emailDonoDoAnimal)]
          atualizaAnimais novaListaDeAnimais

  showMenu

encontrarAnimalASerRemovido:: Animal -> String -> String -> Bool 
encontrarAnimalASerRemovido animal nomeDoAnimal emailDoDono = do
  obterNomeDoAnimal animal == nomeDoAnimal && obterEmailDoDonoDoAnimal animal == emailDoDono

atualizaAnimais :: [Animal] -> IO ()
atualizaAnimais [] = putStrLn "Animal removido com sucesso!\n"
atualizaAnimais (x : xs) = do
  animaisCadastrados <- doesFileExist "animais.txt"
  if not animaisCadastrados
    then do
      file <- openFile "animais.txt" WriteMode
      hPutStr file (show x)
      hFlush file
      hClose file
    else appendFile "animais.txt" ("\n" ++ show x)
  atualizaAnimais xs

obterNomeDoAnimal :: Animal -> String
obterNomeDoAnimal (Animal nomeAnimal _ _ _ _ _) = nomeAnimal

obterEmailDoDonoDoAnimal :: Animal -> String
obterEmailDoDonoDoAnimal (Animal _ email _ _ _ _) = email