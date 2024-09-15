create database livraria;

use livraria;

create table usuario(
id_usuario int primary key not null,
nome varchar (45) not null,
sobrenome varchar (45) not null,
data_nascimento date not null,
cpf int not null);

create table livro(
id_livro int primary key not null,
nome varchar (45) not null,
autor varchar (45) not null);

create table emprestimo(
id_emprestimo int primary key,
id_livro int,
id_usuario int,
foreign key (id_livro) references livro (id_livro),
foreign key (id_usuario) references usuario (id_usuario));

create table multa(
id_multa int auto_increment primary key,
id_usuario int,
valor_multa decimal (10,2),
data_multa date,
foreign key (id_usuario) references usuario (id_usuario));

create table devolucoes(
id int auto_increment primary key,
id_livro int,
id_usuario int,
data_devolucao date,
data_devolucao_esperada date,
foreign key (id_livro) references usuario (id_usuario));

create table livros_atualizados(
id_livro_atualizado int primary key,
id_livro int,
titulo varchar (100),
autor varchar (300),
data_atualizacao datetime default current_timestamp);

create table livros_excluido(
id_livro_excluido int primary key,
id_livro int,
titulo varchar (110),
autor varchar (110),
dataExclusao datetime default current_timestamp);

create table mensagem (
Id_mensagem int primary key,
assunto varchar (45),
corpo varchar (45));

create table multas(
id_multa int auto_increment primary key,
id_usuario int,
valor_multa decimal (10,2),
data_multa date,
foreign key (id_usuario) references usuario (id_usuario));

insert into usuario values ("1","Enrico", "Vicco","21/02/1999","284472983");

select * from usuario;

insert into livro values ("1", "Capitu", "Machado de Assis");
select * from livro;
insert into livros_excluido values ( 1,1,"Livro", "Pedro", "2024/08/29");

select * from livros_excluido;

insert into multa values ("1", "1","10","2024/08/28");

select * from multa;
select * from livro;

insert into devolucoes values ("1", "1", "1", "2024/08/27", "2024/09/05");

insert into livros_atualizados values ("2", "1", "Pequeno Principe", "Joao", "2024/08/28");

select * from livros_atualizados;

select * from devolucoes;

 -- DELIMITER //
-- create trigger trigger_multa after insert on devolucoes for each row
-- begin declare atraso int; 
-- declare valor_multa decimal (10,2);

-- set atraso = datediff(new.data_devolucao_esperada, new data_devolucao);

 -- if atraso>0 then
-- set valor_multa = atraso * 2.00;

-- insert into multa (id_usuario, valor_multa, data_multa)
-- values (new.id_usuario, valor_multa, now());
-- end if;
-- end
-- //
-- DELIMITER ; --


DELIMITER //

CREATE TRIGGER trigger_multa
AFTER INSERT ON devolucoes
FOR EACH ROW
BEGIN
    DECLARE atraso INT;
    DECLARE valor_multa DECIMAL(10,2);

    -- Verifique se as colunas de data não são NULL
    IF NEW.data_devolucao_esperada IS NOT NULL AND NEW.data_devolucao IS NOT NULL THEN
        -- Calcular o atraso em dias
        SET atraso = DATEDIFF(NEW.data_devolucao_esperada, NEW.data_devolucao);

        -- Verificar se há atraso e calcular a multa
        IF atraso > 0 THEN
            SET valor_multa = atraso * 2.00;

            -- Inserir os dados na tabela de multas
            INSERT INTO multa (id_usuario, valor_multa, data_multa)
            VALUES (NEW.id_usuario, valor_multa, NOW());
        END IF;
    END IF;
END //

DELIMITER ;


DELIMITER //
create trigger trigger_verificar_atraso
before insert on devolucoes
for each row 
begin
declare atraso int;
set atraso = datediff(new.data_devolucao_esperada,new.data_devolucao);
if atraso >0 then

insert into mensagem (destinatario, assunto, corpo) 
values ("bibliotecario", "alerta de atraso", concat ("O livro com id", new.id_livro, 
"nao foi devolvido na data de devolucao esperada"));
end if;
end; //
DELIMITER;

DELIMITER //

CREATE TRIGGER trigger_verificar_atraso
BEFORE INSERT ON devolucoes
FOR EACH ROW 
BEGIN
    DECLARE atraso INT;

    -- Calcular a diferença entre as datas
    SET atraso = DATEDIFF(NEW.data_devolucao_esperada, NEW.data_devolucao);

    -- Verificar se há atraso
    IF atraso > 0 THEN
        -- Inserir uma mensagem de alerta
        INSERT INTO mensagem (destinatario, assunto, corpo) 
        VALUES (
            'bibliotecario', 
            'alerta de atraso', 
            CONCAT('O livro com id ', NEW.id_livro, ' não foi devolvido na data de devolução esperada.')
        );
    END IF;
END //

DELIMITER ;

delimiter //
create trigger 
trigger_atualizarStatusEmprestado
after insert on emprestimo
for each row
begin
update livro
set status_livro = "emprestado"
where id = new.id_livro;
end //
demiliter;

delimiter //
create trigger 
trigger_atualizarTotalExemplares
after insert on livro
for each row
begin
update livro
set totalExemplares = totalExemplares + 1 where id_livro = new.id_livro;
end  //
delimiter;

DELIMITER //

CREATE TRIGGER trigger_atualizarTotalExemplares
AFTER INSERT ON livro
FOR EACH ROW
BEGIN
    UPDATE livro
    SET totalExemplares = totalExemplares + 1
    WHERE id = NEW.id;
END //

DELIMITER ;

-- nao rodou essa trigger, ve com o professor
delimiter //

create trigger 
trigger_registrarAtualizacaoLivro
after update on livro
for each row
begin
insert into livros_atualizado (id_livro, titulo, autor, data_atualizacao)
values (old.id_livro, old.nome, old.autor, now());
end;
//
delimiter


DELIMITER //

create trigger trigger_registrarExclusaoLivro
after delete on livro
for each row
begin
insert into livros_excluido (id_livro, titulo, autor, dataexclusao)
values ( old.id_livro, old.nome,old.autor,  now());
end;
//
delimiter

delimiter //
drop Trigger trigger_registrarExclusaoLivro;
drop Trigger trigger_registrarAtualizacaoLivro;
