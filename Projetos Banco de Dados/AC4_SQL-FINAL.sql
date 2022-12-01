
--- AC 4 ---
/*  INTEGRANTES DO GRUPO

CAMILA LIMA FERREIRA DE SOUZA RA - 2100218
JULIA CAMILA MATIAS DE ARAUJO - RA 2100236
GUILHERME SILVA MONTEIRO RA - 2100299
DANIELA ALEXANDRA DA SILVA - RA 2100282

*/


/*EXERCICIO 1


Usando a base Temp, com o modelo estendido da Concessionaria (Cliente,
Vendas2013,Vendas2014, Vendas2015, ...), criar os objetos abaixo conforme as descrições:

1. Crie uma função X que receba um parâmetro referente ao número do veículo e outro
referente ao Ano de Venda. A função deve retornar o número de vendas referentes ao
veículo no dado ano.

Exemplo:
Cliente 47 no ano 2013: 2 compras
Cliente 15 no ano 2014: 3 compras
Cliente 27 no ano 2015: 1 compra

*/

--

DROP FUNCTION FUNC_AC04VENDAS


create FUNCTION FUNC_AC04VENDAS(@IDVEICULO SMALLINT, @ANO SMALLINT)
returns SMALLINT
as
begin

 declare @qtd smallint
select       @qtd = case  @ANO 
						WHEN 2013 THEN  (SELECT COUNT (*) AS QTD FROM [2100282].Vendas2013  WHERE idVeiculo = @IDVEICULO )
						WHEN 2014 THEN  (SELECT COUNT (*) AS QTD FROM [2100282].Vendas2014  WHERE idVeiculo = @IDVEICULO)
						WHEN 2015 THEN  (SELECT COUNT (*) AS QTD FROM [2100282].Vendas2015  WHERE idVeiculo = @IDVEICULO)
					END

FROM  [2100282].[Veiculo] A
      	INNER JOIN [2100218].Vendas2013 VD
      		ON A.idVeiculo = VD.IDVEICULO
      	INNER JOIN [2100218].Vendas2014 VV 
      		ON A.idVeiculo = VV.idVeiculo
      	INNER JOIN [2100218].Vendas2015 VDS
      		ON A.idVeiculo = VDS.idVeiculo                        

return @qtd

end


SELECT [2100282].[FUNC_AC04VENDAS](4,2013) as quantidade


--- EXERCio 2

--Crie uma função Y que receba um parâmetro referente ao número do cliente e retorne
--todas as compras feitas por este cliente, trazendo as informações abaixo:


create FUNCTION [2100282].[FUNC_AC04CLIENTE](@IDCLIENTE TINYINT)
RETURNS TABLE
AS
RETURN(
SELECT 
  CL.idCliente,
  CL.nome,
  CL.SEXO,
  CL.dtNascimento,
  B.dataVenda,
  VC.idVeiculo,
  VC.descricao as veiculo,
  MD.descricao as modelo,
  FB.NOME AS fabricante
FROM CLIENTE CL
     	LEFT JOIN ( SELECT * FROM [2100282].VENDAS2013
                     UNION ALL SELECT * FROM [2100282].VENDAS2014
                     UNION ALL SELECT * FROM [2100282].VENDAS2015
                  ) AS B
		ON CL.IDCLIENTE = B.IDCLIENTE
		INNER JOIN [2100282].[Veiculo] VC
		ON B.idVeiculo = VC.idVeiculo
		INNER JOIN [2100282].Modelo MD
			ON VC.idModelo = MD.idModelo
		INNER JOIN Fabricante FB
			ON FB.idFabricante = VC.idFabricante
where CL.idCliente = @IDCLIENTE  

)

--SELECT * FROM [FUNC_AC04CLIENTE](2)


---- exercicio 3

ALTER FUNCTION [2100282].[FUNC_AC04GERAL](@IDCLIENTE SMALLINT)
RETURNS @TABELA 
TABLE					(IDCLIENTE SMALLINT,
						ID SMALLINT IDENTITY,
						NOME VARCHAR(40),
						SEXO BIT,
						DATANASCIMENTO DATE,
						DATAVENDA DATE,
						IDVEICULO SMALLINT,
						VEICULO VARCHAR(20),
						MODELO VARCHAR(20),
						FABRICANTE VARCHAR(20), 
						TotalVendasVeiculo2013 SMALLINT , 
						TotalVendasVeiculo2014 SMALLINT,
						TotalVendasVeiculo2015 SMALLINT )
AS 
 BEGIN
					
	    INSERT  @TABELA  (IDCLIENTE,
						  NOME,
						  SEXO,
						  DATANASCIMENTO,
						  DATAVENDA , 
						  IDVEICULO, 
						  VEICULO, 
						  MODELO, 
						  FABRICANTE)
		SELECT * FROM [FUNC_AC04CLIENTE](@IDCLIENTE) 

		
	DECLARE @ID SMALLINT = 0

	WHILE exists (select * from @TABELA where @ID <=ID)
	BEGIN

		
		UPDATE  @TABELA SET TotalVendasVeiculo2013 = (SELECT [2100282].FUNC_AC04VENDAS(IDVEICULO, 2013)), 
						 TotalVendasVeiculo2014 = (SELECT [2100282].FUNC_AC04VENDAS(IDVEICULO, 2014)),
						 TotalVendasVeiculo2015 =  (SELECT [2100282].FUNC_AC04VENDAS(IDVEICULO, 2015))
						WHERE  @ID = ID

		
		SET @ID +=1
	END
	RETURN
			
   
 END
GO
SELECT * FROM  [2100282].[FUNC_AC04GERAL](4)