// Seed dataset for a music recommendation graph.
// Creates 30 users, 30 songs, 10 artists, and 10 genres.
// Relationships are pseudo-randomly spread and reinforced with taste cohorts
// so recommendation queries have meaningful overlap between users.

WITH [
  {name: "Paulo", age: 22},
  {name: "Ana", age: 25},
  {name: "Lucas", age: 19},
  {name: "Mariana", age: 28},
  {name: "Joao", age: 31},
  {name: "Julia", age: 21},
  {name: "Carlos", age: 34},
  {name: "Beatriz", age: 24},
  {name: "Rafael", age: 27},
  {name: "Camila", age: 20},
  {name: "Pedro", age: 29},
  {name: "Larissa", age: 23},
  {name: "Gabriel", age: 26},
  {name: "Fernanda", age: 32},
  {name: "Mateus", age: 18},
  {name: "Sofia", age: 30},
  {name: "Thiago", age: 35},
  {name: "Isabela", age: 22},
  {name: "Gustavo", age: 27},
  {name: "Amanda", age: 24},
  {name: "Felipe", age: 33},
  {name: "Bruna", age: 21},
  {name: "Diego", age: 28},
  {name: "Carolina", age: 25},
  {name: "Vinicius", age: 19},
  {name: "Renata", age: 31},
  {name: "Eduardo", age: 26},
  {name: "Natalia", age: 23},
  {name: "Henrique", age: 29},
  {name: "Leticia", age: 20}
] AS users
UNWIND users AS row
MERGE (u:User {name: row.name})
SET u.age = row.age;

WITH [
  "The Weeknd",
  "Dua Lipa",
  "Daft Punk",
  "Tame Impala",
  "M83",
  "Billie Eilish",
  "Harry Styles",
  "Taylor Swift",
  "Bruno Mars",
  "Lady Gaga"
] AS artists
UNWIND artists AS name
MERGE (:Artist {name: name});

WITH [
  "Pop",
  "Synthwave",
  "Dance",
  "Electronic",
  "Indie",
  "Rock",
  "R&B",
  "Funk",
  "Disco",
  "Alternative"
] AS genres
UNWIND genres AS name
MERGE (:Genre {name: name});

WITH [
  {title: "Blinding Lights", artist: "The Weeknd", genres: ["Synthwave", "Pop"]},
  {title: "Save Your Tears", artist: "The Weeknd", genres: ["Pop", "Synthwave"]},
  {title: "Starboy", artist: "The Weeknd", genres: ["Pop", "R&B"]},
  {title: "Levitating", artist: "Dua Lipa", genres: ["Pop", "Disco"]},
  {title: "Don't Start Now", artist: "Dua Lipa", genres: ["Pop", "Dance"]},
  {title: "Physical", artist: "Dua Lipa", genres: ["Pop", "Dance"]},
  {title: "One More Time", artist: "Daft Punk", genres: ["Electronic", "Dance"]},
  {title: "Get Lucky", artist: "Daft Punk", genres: ["Disco", "Funk"]},
  {title: "Instant Crush", artist: "Daft Punk", genres: ["Electronic", "Indie"]},
  {title: "The Less I Know the Better", artist: "Tame Impala", genres: ["Indie", "Alternative"]},
  {title: "Let It Happen", artist: "Tame Impala", genres: ["Indie", "Electronic"]},
  {title: "Borderline", artist: "Tame Impala", genres: ["Indie", "Pop"]},
  {title: "Midnight City", artist: "M83", genres: ["Synthwave", "Electronic"]},
  {title: "Wait", artist: "M83", genres: ["Alternative", "Electronic"]},
  {title: "Outro", artist: "M83", genres: ["Alternative", "Electronic"]},
  {title: "bad guy", artist: "Billie Eilish", genres: ["Pop", "Alternative"]},
  {title: "Happier Than Ever", artist: "Billie Eilish", genres: ["Alternative", "Rock"]},
  {title: "Ocean Eyes", artist: "Billie Eilish", genres: ["Pop", "Alternative"]},
  {title: "As It Was", artist: "Harry Styles", genres: ["Pop", "Rock"]},
  {title: "Watermelon Sugar", artist: "Harry Styles", genres: ["Pop", "Funk"]},
  {title: "Adore You", artist: "Harry Styles", genres: ["Pop", "R&B"]},
  {title: "Anti-Hero", artist: "Taylor Swift", genres: ["Pop", "Alternative"]},
  {title: "Cruel Summer", artist: "Taylor Swift", genres: ["Pop", "Synthwave"]},
  {title: "Style", artist: "Taylor Swift", genres: ["Pop", "Synthwave"]},
  {title: "Uptown Funk", artist: "Bruno Mars", genres: ["Funk", "Pop"]},
  {title: "Locked Out of Heaven", artist: "Bruno Mars", genres: ["Rock", "Funk"]},
  {title: "Treasure", artist: "Bruno Mars", genres: ["Disco", "Funk"]},
  {title: "Poker Face", artist: "Lady Gaga", genres: ["Pop", "Dance"]},
  {title: "Bad Romance", artist: "Lady Gaga", genres: ["Pop", "Dance"]},
  {title: "Rain On Me", artist: "Lady Gaga", genres: ["Dance", "Pop"]}
] AS songs
UNWIND songs AS row
MERGE (m:Music {title: row.title})
MERGE (a:Artist {name: row.artist})
MERGE (m)-[:PERFORMED_BY]->(a)
WITH m, row
UNWIND row.genres AS genreName
MERGE (g:Genre {name: genreName})
MERGE (m)-[:BELONGS_TO]->(g);

WITH [
  "Paulo", "Ana", "Lucas", "Mariana", "Joao", "Julia",
  "Carlos", "Beatriz", "Rafael", "Camila", "Pedro", "Larissa",
  "Gabriel", "Fernanda", "Mateus", "Sofia", "Thiago", "Isabela",
  "Gustavo", "Amanda", "Felipe", "Bruna", "Diego", "Carolina",
  "Vinicius", "Renata", "Eduardo", "Natalia", "Henrique", "Leticia"
] AS userNames,
[
  "The Weeknd", "Dua Lipa", "Daft Punk", "Tame Impala", "M83",
  "Billie Eilish", "Harry Styles", "Taylor Swift", "Bruno Mars", "Lady Gaga"
] AS artistNames
UNWIND range(0, size(userNames) - 1) AS i
WITH userNames, artistNames, i, userNames[i] AS userName
MATCH (u:User {name: userName})
UNWIND [0, 3, 6] AS offset
WITH u, artistNames[(i * 2 + offset) % size(artistNames)] AS artistName
MATCH (a:Artist {name: artistName})
MERGE (u)-[:FOLLOWS]->(a);

WITH [
  "Paulo", "Ana", "Lucas", "Mariana", "Joao", "Julia",
  "Carlos", "Beatriz", "Rafael", "Camila", "Pedro", "Larissa",
  "Gabriel", "Fernanda", "Mateus", "Sofia", "Thiago", "Isabela",
  "Gustavo", "Amanda", "Felipe", "Bruna", "Diego", "Carolina",
  "Vinicius", "Renata", "Eduardo", "Natalia", "Henrique", "Leticia"
] AS userNames,
[
  "Blinding Lights", "Save Your Tears", "Starboy", "Levitating", "Don't Start Now",
  "Physical", "One More Time", "Get Lucky", "Instant Crush", "The Less I Know the Better",
  "Let It Happen", "Borderline", "Midnight City", "Wait", "Outro",
  "bad guy", "Happier Than Ever", "Ocean Eyes", "As It Was", "Watermelon Sugar",
  "Adore You", "Anti-Hero", "Cruel Summer", "Style", "Uptown Funk",
  "Locked Out of Heaven", "Treasure", "Poker Face", "Bad Romance", "Rain On Me"
] AS songTitles
UNWIND range(0, size(userNames) - 1) AS i
WITH userNames, songTitles, i, userNames[i] AS userName
MATCH (u:User {name: userName})
UNWIND [0, 4, 9, 15, 23] AS offset
WITH u, i, offset, songTitles[(i * 7 + offset) % size(songTitles)] AS songTitle
MATCH (m:Music {title: songTitle})
MERGE (u)-[r:LISTENED]->(m)
SET r.times = 3 + ((i * 13 + offset * 5) % 28);

WITH [
  "Paulo", "Ana", "Lucas", "Mariana", "Joao", "Julia",
  "Carlos", "Beatriz", "Rafael", "Camila", "Pedro", "Larissa",
  "Gabriel", "Fernanda", "Mateus", "Sofia", "Thiago", "Isabela",
  "Gustavo", "Amanda", "Felipe", "Bruna", "Diego", "Carolina",
  "Vinicius", "Renata", "Eduardo", "Natalia", "Henrique", "Leticia"
] AS userNames,
[
  "Blinding Lights", "Save Your Tears", "Starboy", "Levitating", "Don't Start Now",
  "Physical", "One More Time", "Get Lucky", "Instant Crush", "The Less I Know the Better",
  "Let It Happen", "Borderline", "Midnight City", "Wait", "Outro",
  "bad guy", "Happier Than Ever", "Ocean Eyes", "As It Was", "Watermelon Sugar",
  "Adore You", "Anti-Hero", "Cruel Summer", "Style", "Uptown Funk",
  "Locked Out of Heaven", "Treasure", "Poker Face", "Bad Romance", "Rain On Me"
] AS songTitles
UNWIND range(0, size(userNames) - 1) AS i
WITH userNames, songTitles, i, userNames[i] AS userName
MATCH (u:User {name: userName})
UNWIND [0, 9, 23] AS offset
WITH u, i, songTitles[(i * 7 + offset) % size(songTitles)] AS songTitle
MATCH (m:Music {title: songTitle})
MERGE (u)-[:LIKED]->(m);

WITH [
  {
    users: ["Paulo", "Ana", "Lucas", "Mariana", "Joao", "Julia"],
    songs: ["Blinding Lights", "Save Your Tears", "Levitating", "Don't Start Now", "Cruel Summer", "Style"]
  },
  {
    users: ["Carlos", "Beatriz", "Rafael", "Camila", "Pedro", "Larissa"],
    songs: ["One More Time", "Get Lucky", "Instant Crush", "Midnight City", "Let It Happen", "Borderline"]
  },
  {
    users: ["Gabriel", "Fernanda", "Mateus", "Sofia", "Thiago", "Isabela"],
    songs: ["bad guy", "Happier Than Ever", "Ocean Eyes", "Anti-Hero", "As It Was", "Watermelon Sugar"]
  },
  {
    users: ["Gustavo", "Amanda", "Felipe", "Bruna", "Diego", "Carolina"],
    songs: ["Uptown Funk", "Locked Out of Heaven", "Treasure", "Poker Face", "Bad Romance", "Rain On Me"]
  },
  {
    users: ["Vinicius", "Renata", "Eduardo", "Natalia", "Henrique", "Leticia"],
    songs: ["Starboy", "Physical", "Adore You", "Wait", "Outro", "The Less I Know the Better"]
  },
  {
    users: ["Paulo", "Beatriz", "Gabriel", "Amanda", "Vinicius", "Natalia"],
    songs: ["Blinding Lights", "Midnight City", "bad guy", "Uptown Funk", "Starboy", "Rain On Me"]
  },
  {
    users: ["Ana", "Rafael", "Sofia", "Bruna", "Eduardo", "Henrique"],
    songs: ["Levitating", "Get Lucky", "Anti-Hero", "Poker Face", "Physical", "Cruel Summer"]
  },
  {
    users: ["Lucas", "Camila", "Thiago", "Diego", "Renata", "Leticia"],
    songs: ["Save Your Tears", "One More Time", "As It Was", "Bad Romance", "Adore You", "Style"]
  }
] AS cohorts
UNWIND range(0, size(cohorts) - 1) AS cohortIndex
WITH cohorts[cohortIndex] AS cohort, cohortIndex
UNWIND range(0, size(cohort.users) - 1) AS userIndex
WITH cohort, cohortIndex, userIndex, cohort.users[userIndex] AS userName
MATCH (u:User {name: userName})
UNWIND range(0, size(cohort.songs) - 1) AS songIndex
WITH u, cohortIndex, userIndex, songIndex, cohort.songs[songIndex] AS songTitle
MATCH (m:Music {title: songTitle})
MERGE (u)-[:LIKED]->(m)
MERGE (u)-[r:LISTENED]->(m)
SET r.times = 8 + ((cohortIndex * 11 + userIndex * 7 + songIndex * 5) % 35);

MATCH (u:User)
WITH count(u) AS users
MATCH (m:Music)
WITH users, count(m) AS songs
MATCH (a:Artist)
WITH users, songs, count(a) AS artists
MATCH (g:Genre)
WITH users, songs, artists, count(g) AS genres
MATCH ()-[r]->()
RETURN users, songs, artists, genres, count(r) AS relationships;
