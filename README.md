# Flutter_CRUD 

Versão do Flutter 2.2.0

## Requisitos
- cadastro de clientes (simples) 
- cadastro de Emprestimos (simples) 
  - data do empréstimo 
  - moeda (de preferência utilizar a lista do Banco Central) 
  - valor obtido 
  - data de vencimento
  - taxa de conversão para reais em data atual (de preferência obtida no Banco Central) (somente UI)
 
O sistema deve informar:  
- número de meses entre a data de vencimento e a data de financiamento 
- valor que deve ser pago no vencimento (calculado com juros compostos)

Os dados devem ser persistidos em banco de dados, preferencialmente Postgresql. 

Preferencialmente as moedas e a cotação em data atual devem ser obtidas via chamadas ao sistema do Banco Central do Brasil (BCB) https://dadosabertos.bcb.gov.br/dataset/taxas-de-cambio-todos-os-boletins-diarios

moedas = https://dadosabertos.bcb.gov.br/dataset/taxas-de-cambio-todos-os-boletins-diarios/resource/9d07b9dc-c2bc-47ca-af92-10b18bcd0d69
