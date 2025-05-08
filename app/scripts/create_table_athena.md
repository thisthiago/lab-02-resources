
---

### **1. Arquivos Parquet: Schema por arquivo (não centralizado)**
- Cada arquivo Parquet **contém seu próprio schema** dentro dos metadados do arquivo.  
- **Problema:** Se você tem vários arquivos em um diretório, eles podem:  
  - Ter **schemas diferentes** (colunas a mais ou a menos).  
  - Ter **tipos de dados diferentes** para a mesma coluna (ex.: `int` em um arquivo e `bigint` em outro).  
- **Como o Athena/Glue lê isso?**  
  - Ele **não sabe automaticamente** se todos os arquivos são compatíveis.  
  - Você **precisa definir um schema fixo** para garantir que as consultas funcionem corretamente.  

#### **Exemplo:**
Se um arquivo tem `user_id` como `int` e outro como `string`, o Athena não consegue adivinhar qual usar.  
Por isso, você **declara manualmente** o schema para evitar erros.  


```sql
CREATE EXTERNAL TABLE IF NOT EXISTS bank_accounts_parquet (
  column type,
  column type,
  column type
)
STORED AS PARQUET
LOCATION '<FULL_PATH>'
TBLPROPERTIES (
  'has_encrypted_data'='false',
  'parquet.compression'='SNAPPY'
);
```

> Exemplo parquet com dado de ./parquet

_Schema_
```text 
root
 |-- account_number: string (nullable = true)
 |-- bank_name: string (nullable = true)
 |-- dt_current_timestamp: long (nullable = true)
 |-- iban: string (nullable = true)
 |-- id: long (nullable = true)
 |-- routing_number: string (nullable = true)
 |-- swift_bic: string (nullable = true)
 |-- uid: string (nullable = true)
 |-- user_id: long (nullable = true)
```

_Create_
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS bank_accounts_parquet (
  account_number STRING,
  bank_name STRING,
  dt_current_timestamp BIGINT,
  iban STRING,
  id BIGINT,
  routing_number STRING,
  swift_bic STRING,
  uid STRING,
  user_id BIGINT
)
STORED AS PARQUET
LOCATION 's3://dev-lab-02-us-east-2-silver/teste-parquet/'
TBLPROPERTIES (
  'has_encrypted_data'='false',
  'parquet.compression'='SNAPPY'
);
```

---

### **2. Delta Lake: Schema centralizado (já vem com metadados)**
- O Delta Lake **armazena o schema em um log de transações** (`_delta_log`).  
- **Todas as alterações** (adição/remoção de colunas, mudança de tipos) são **rastreadas**.  
- **Garantia de consistência:**  
  - Todos os arquivos Parquet dentro de um Delta Lake **seguem o mesmo schema**.  
  - Se um arquivo não estiver de acordo, a transação é rejeitada (ACID compliance).  

#### **Por que não precisa declarar?**
- O Athena/Glue **lê o schema diretamente do `_delta_log`**, que já é confiável.  
- Não há risco de inconsistência, então o schema é **inferido automaticamente**.  

_Create_
```sql
--Delta
CREATE EXTERNAL TABLE database.table
LOCATION '<FULL_PATH>'
TBLPROPERTIES (
    'table_type'='DELTA'
);
```



---

### **Resumo:**
| **Formato**  | **Onde o schema é armazenado?** | **Precisa declarar?** | **Por quê?** |
|-------------|-------------------------------|------------------|------------|
| **Parquet** | Dentro de cada arquivo (pode variar) | ✅ **Sim** | Porque cada arquivo pode ter um schema diferente. |
| **Delta Lake** | No `_delta_log` (centralizado) | ❌ **Não** | O schema é único e consistente para todos os arquivos. |

### **Resumo:**
- **Parquet** → Schema descentralizado → **Você precisa declarar** para evitar erros.  
- **Delta Lake** → Schema gerenciado → **Não precisa declarar**, pois já é confiável.  
