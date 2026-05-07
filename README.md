# Music Recommendation Neo4j

Projeto de recomendação musical usando Neo4j Aura e Cypher. O banco modela usuários, músicas, artistas e gêneros, permitindo consultas de recomendação a partir de gostos em comum, artistas seguidos, artista da música e gênero musical.

## Estrutura Do Grafo

![Visualização do grafo no Neo4j Aura](images/visualization-neo4j.png)

O grafo usa quatro tipos principais de nós:

| Label | Descrição | Propriedades principais |
| --- | --- | --- |
| `User` | Pessoa que escuta, curte músicas e segue artistas | `name`, `age` |
| `Music` | Música disponível no catálogo | `title` |
| `Artist` | Artista responsável por músicas | `name` |
| `Genre` | Gênero musical associado às músicas | `name` |

Relacionamentos usados:

| Relacionamento | Direção | Significado |
| --- | --- | --- |
| `(:User)-[:LIKED]->(:Music)` | usuário para música | Usuário curtiu a música |
| `(:User)-[:LISTENED {times}]->(:Music)` | usuário para música | Usuário ouviu a música algumas vezes |
| `(:User)-[:FOLLOWS]->(:Artist)` | usuário para artista | Usuário segue o artista |
| `(:Music)-[:PERFORMED_BY]->(:Artist)` | música para artista | Música é performada pelo artista |
| `(:Music)-[:BELONGS_TO]->(:Genre)` | música para gênero | Música pertence ao gênero |

## Arquivos

| Caminho | Descrição |
| --- | --- |
| `cypher-queries/populate_music_database.cypher` | Popula o banco Neo4j |
| `cypher-queries/recommend_music_by_users.cypher` | Recomenda músicas por usuários que curtiram a mesma música |
| `cypher-queries/recommended_artist_by_artist.cypher` | Recomenda artistas a partir de um artista seguido |
| `cypher-queries/recommended_music_by_artist.cypher` | Recomenda músicas do mesmo artista |
| `cypher-queries/recommended_music_by_genre.cypher` | Recomenda músicas do mesmo gênero |
| `csv-results/*.csv` | Resultados exportados das consultas |
| `images/visualization-neo4j.png` | Imagem da estrutura do grafo no Neo4j Aura |

## População Do Banco

O arquivo `populate_music_database.cypher` cria:

| Tipo | Quantidade |
| --- | ---: |
| Usuários | 30 |
| Músicas | 30 |
| Artistas | 10 |
| Gêneros | 10 |

A população usa `MERGE` para evitar duplicação caso o script seja executado mais de uma vez. Primeiro são criados os nós de usuários, artistas, gêneros e músicas. Depois são criados os relacionamentos:

- cada música é conectada ao seu artista com `PERFORMED_BY`;
- cada música é conectada a dois gêneros com `BELONGS_TO`;
- usuários seguem artistas com `FOLLOWS`;
- usuários escutam músicas com `LISTENED`, incluindo a propriedade `times`;
- usuários curtem músicas com `LIKED`.

Além da distribuição pseudoaleatória, o script cria grupos de gosto, chamados de `cohorts`. Esses grupos fazem vários usuários compartilharem músicas em comum, o que melhora as consultas de recomendação. Sem isso, muitas recomendações retornavam `usersWhoAlsoLiked = 1`, porque havia pouca sobreposição entre os usuários.

Para recriar o banco do zero no Neo4j Aura:

```cypher
MATCH (n)
DETACH DELETE n;
```

Depois execute o conteúdo de:

```text
cypher-queries/populate_music_database.cypher
```

Ao final, o script retorna um resumo:

```cypher
RETURN users, songs, artists, genres, count(r) AS relationships;
```

## Consultas De Recomendação

### 1. Músicas Por Usuários Em Comum

Arquivo: `cypher-queries/recommend_music_by_users.cypher`

Consulta usada para responder: "eu gosto da música X; quais outras músicas usuários parecidos também gostam?"

```cypher
MATCH (:Music {title: "Blinding Lights"})<-[:LIKED]-(u:User)-[:LIKED]->(recommended:Music)
WHERE recommended.title <> "Blinding Lights"
OPTIONAL MATCH (u)-[listen:LISTENED]->(recommended)
RETURN
  recommended.title AS music,
  count(DISTINCT u) AS usersWhoAlsoLiked,
  coalesce(sum(listen.times), 0) AS accumulatedListens
ORDER BY accumulatedListens DESC, usersWhoAlsoLiked DESC, music;
```

Ela parte de `Blinding Lights`, encontra usuários que curtiram essa música, busca outras músicas que esses usuários também curtiram e ordena pelo total acumulado de audições.

Resultado exportado em `csv-results/result_recommend_music_by_users.csv`:

| music | usersWhoAlsoLiked | accumulatedListens |
| --- | ---: | ---: |
| Style | 6 | 191 |
| Cruel Summer | 7 | 177 |
| Levitating | 7 | 165 |
| Midnight City | 6 | 163 |
| bad guy | 6 | 158 |
| Starboy | 6 | 148 |

### 2. Artistas Por Artista Seguido

Arquivo: `cypher-queries/recommended_artist_by_artist.cypher`

A consulta parte de um artista, encontra usuários que seguem esse artista e recomenda outros artistas seguidos por esses mesmos usuários.

Resultado exportado em `csv-results/result_recommended_artist_by_artist.csv`:

| artist | usersWhoAlsoFollowed | accumulatedListens |
| --- | ---: | ---: |
| M83 | 6 | 200 |
| Taylor Swift | 6 | 161 |
| Harry Styles | 6 | 147 |
| Tame Impala | 6 | 118 |

### 3. Músicas Do Mesmo Artista

Arquivo: `cypher-queries/recommended_music_by_artist.cypher`

A consulta parte de `Blinding Lights`, identifica seu artista (`The Weeknd`) e recomenda outras músicas performadas pelo mesmo artista, ordenadas por audições acumuladas.

Resultado exportado em `csv-results/result_recommended_music_by_artist.csv`:

| music | usersWhoListened | accumulatedListens |
| --- | ---: | ---: |
| Save Your Tears | 15 | 308 |
| Starboy | 12 | 274 |

### 4. Músicas Do Mesmo Gênero

Arquivo: `cypher-queries/recommended_music_by_genre.cypher`

A consulta encontra gêneros de `Blinding Lights` e recomenda músicas que pertencem aos mesmos gêneros.

Resultado exportado em `csv-results/result_recommended_music_by_genre.csv`:

| music | usersWhoListened | accumulatedListens |
| --- | ---: | ---: |
| Style | 13 | 718 |
| Cruel Summer | 15 | 664 |
| Save Your Tears | 15 | 616 |
| Levitating | 16 | 368 |
| Bad Romance | 15 | 362 |
| Anti-Hero | 16 | 341 |
| Adore You | 14 | 328 |

## Observações

As consultas retornam tabelas, que são melhores para analisar ranking, contagem de usuários e soma de audições. Para visualização em grafo no Aura, a consulta precisa retornar nós e relacionamentos diretamente, por exemplo `target`, `u`, `recommended` e os relacionamentos entre eles.

Os nomes dos relacionamentos precisam bater com o script de população. Neste projeto, os nomes corretos são `LIKED`, `LISTENED`, `FOLLOWS`, `PERFORMED_BY` e `BELONGS_TO`.
